module d4.renderer.RasterizerBase;

import tango.math.Math : rndint;
import tango.math.IEEE : RoundingMode, setIeeeRounding;
import util.ArrayAllocation;
import util.StringMixinUtils;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Plane;
import d4.math.Vector2;
import d4.math.Vector3;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.IRasterizer;
import d4.renderer.ZBuffer;
import d4.scene.Image;
import d4.scene.Vertex;
import d4.shader.VertexVariableUtils;

/**
 * Provides common basic functionality for most kinds of rasterizers.
 * This includes: shader support, matrix caching, clipping, backface culling, ...
 * 
 * The concrete subclasses only need to implement <code>drawTriangle</code>,
 * every thing else is handled by this class.
 */
abstract class RasterizerBase( bool PrepareForPerspectiveCorrection, alias Shader, ShaderParams... ) : IRasterizer {
   /**
    * Initializes the render states and transformation matrices
    * with sane default values.
    */
   this() {
      m_worldMatrix = Matrix4.identity;
      m_worldNormalMatrix = Matrix4.identity;
      m_viewMatrix = Matrix4.identity;
      m_projMatrix = Matrix4.identity;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
      
      m_backfaceCulling = BackfaceCulling.CULL_CW;
   }
   
   /**
    * Renders a set of indexed triangles using the stored transformations.
    * 
    * The results are written to the Frame-/Z-Buffer specified by
    * <code>setRenderTarget</code>.
    * 
    * Params:
    *     vertices = The vertices to render.
    *     indices = The indices referring to the passed vertex array.
    */
   void renderTriangleList( Vertex[] vertices, uint[] indices ) {
      assert( ( indices.length % 3 == 0 ), "There must be no incomplete triangles." );
      
      // Set the FPU to truncation rounding. We have to restore the old state
      // when leaving the function, otherwise really strange things happen
      // (most probably, the machine crashes).
      // TODO: Fix rounding mode issues.
      // auto oldRoundingMode = setIeeeRounding( RoundingMode.ROUNDDOWN );
      // scope ( exit ) setIeeeRounding( oldRoundingMode );

      // Invoke vertex shader to get the positions in clipping coordinates
      // and to compute any additional per-vertex data.
      TransformedVertex[] transformed;
      allocate( transformed, vertices.length );
      
      foreach ( i, vertex; vertices ) {
         TransformedVertex current;
         
         vertexShader( vertex, current.pos, current.vars );
         // Note: The positions are still not divided by w (»homogenzied«).

         transformed[ i ] = current;
      }
      
      for ( uint i = 0; i < indices.length; i += 3 ) {
         renderTriangle( transformed[ indices[ i ] ], transformed[ indices[ i + 1 ] ], transformed[ indices[ i + 2 ] ] );
      }

      free( transformed );
   }
   
   /**
    * Sets the render target to use, which is a framebuffer and its z buffer
    * companion.
    * 
    * Params:
    *     colorBuffer = The framebuffer to use. 
    *     zBuffer = The z buffer to use.
    */
   void setRenderTarget( Surface colorBuffer, ZBuffer zBuffer ) {
      assert( colorBuffer.width == zBuffer.width, "ZBuffer width must match framebuffer width." );
      assert( colorBuffer.height == zBuffer.height, "ZBuffer height must match framebuffer height." );

      m_colorBuffer = colorBuffer;
      m_zBuffer = zBuffer;
   }
   
   
   /**
    * The world matrix to use.
    */
   Matrix4 worldMatrix() {
      return m_worldMatrix;
   }

   /// ditto
   void worldMatrix( Matrix4 worldMatrix ) {
      m_worldMatrix = worldMatrix;
      m_worldNormalMatrix = worldMatrix.inversed().transposed();
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
   }

   /**
    * The view matrix to use.
    */
   Matrix4 viewMatrix() {
      return m_viewMatrix;
   }

   /// ditto
   void viewMatrix( Matrix4 viewMatrix ) {
      m_viewMatrix = viewMatrix;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
   }
   
   /**
    * The projection matrix to use.
    */   
   Matrix4 projectionMatrix() {
      return m_projMatrix;
   }
   
   /// ditto
   void projectionMatrix( Matrix4 projectionMatrix ) {
      m_projMatrix = projectionMatrix;
      updateWorldViewProjMatrix();
   }

   /**
    * The backface culling mode to use.
    */
   BackfaceCulling backfaceCulling() {
      return m_backfaceCulling;
   }
   
   /// ditto
   void backfaceCulling( BackfaceCulling cullingMode ) {
      m_backfaceCulling = cullingMode;
   }

   /**
    * The textures to use.
    */
   Image[] textures() {
      return m_textures;
   }

   /// ditto
   void textures( Image[] textures ) {
      m_textures = textures;
      m_textureDataPointers = [];
      m_shiftedWidths = [];
      m_shiftedHeights = [];
      m_shiftedXLimits = [];
      m_shiftedYLimits = [];
      
      foreach ( i, texture; textures ) {
         m_textureDataPointers ~= texture.colorData;
         m_texWidths ~= texture.width;
         m_texHeights ~= texture.height;
         m_shiftedWidths ~= texture.width << TEX_COORD_SHIFT;
         m_shiftedHeights ~= texture.height << TEX_COORD_SHIFT;
         m_shiftedXLimits ~= ( texture.width - 1 ) << TEX_COORD_SHIFT;
         m_shiftedYLimits ~= ( texture.height - 1 ) << TEX_COORD_SHIFT;
      }
   }

protected:
   /**
    * Imports the shader template passed to the class template into the class
    * scope.
    * 
    * The shader has to provide:
    *  - void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables );
    *  - Color pixelShader( VertexVariables variables );
    *  - struct VertexVariables presenting an array of float values[].
    */
   mixin Shader!( ShaderParams );
   
   // ----
   // Shader interface
   Matrix4 worldNormalMatrix() {
      return m_worldNormalMatrix;
   }

   Matrix4 worldViewProjMatrix() {
      return m_worldViewProjMatrix;
   }

   Color readTexture( bool bilinearInterpolation = false, bool tile = true )
      ( uint textureIndex, Vector2 texCoords ) {
      
      // Parts of the interpolation code shamelessly taken from DShade
      // (http://h3.team0xf.com/proj/).
      int u;
      int v;
      
      static if ( tile ) {
         // Tile.
         u = rndint( texCoords.x * m_shiftedXLimits[ textureIndex ] ) % m_shiftedWidths[ textureIndex ];
         v = rndint( texCoords.y * m_shiftedYLimits[ textureIndex ] ) % m_shiftedHeights[ textureIndex ];
         if ( u < 0 ) {
            u += m_shiftedWidths[ textureIndex ];
         }
         if ( v < 0 ) {
            v += m_shiftedHeights[ textureIndex ];
         }
      } else {
         // Clamp.
         u = rndint( texCoords.x * m_shiftedXLimits[ textureIndex ] );
         v = rndint( texCoords.y * m_shiftedYLimits[ textureIndex ] );
         if ( u < 0 ) {
            u = 0;
         } else if ( u > m_shiftedXLimits[ textureIndex ] ) {
            u = m_shiftedXLimits[ textureIndex ];
         }
         if ( v < 0 ) {
            v = 0;
         } else if ( v > m_shiftedYLimits[ textureIndex ] ) {
            v = m_shiftedYLimits[ textureIndex ];
         }
      }
      
      // Remove the low extra bits.
      int u0 = u >> TEX_COORD_SHIFT;
      int v0 = v >> TEX_COORD_SHIFT;

      static if ( !bilinearInterpolation ) {
         return m_textureDataPointers[ textureIndex ][ v0 * m_texWidths[ textureIndex ] + u0 ];
      } else {
         // Calculate the indices of the two neighbour pixels.
         int u1 = ( u0 + 1 ) % m_texWidths[ textureIndex ];
         int v1 = ( v0 + 1 ) % m_texHeights[ textureIndex ];

         // Read the four surrounding pixels.
         Color c00 = m_textureDataPointers[ textureIndex ][ u0 + m_texWidths[ textureIndex ] * v0 ];
         Color c10 = m_textureDataPointers[ textureIndex ][ u1 + m_texWidths[ textureIndex ] * v0 ];
         Color c01 = m_textureDataPointers[ textureIndex ][ u0 + m_texWidths[ textureIndex ] * v1 ];
         Color c11 = m_textureDataPointers[ textureIndex ][ u1 + m_texWidths[ textureIndex ] * v1 ];

         // Use only the low, added bits to calculate the interpolation point.
         int uoff = u & ( ( 1 << TEX_COORD_SHIFT ) - 1 );
         int voff = v & ( ( 1 << TEX_COORD_SHIFT ) - 1 );

         return Color(
             (((cast(uint)c00.r * ((1 << TEX_COORD_SHIFT) - uoff) + uoff * c10.r))
                 * ((1 << TEX_COORD_SHIFT) - voff)
             + ((cast(uint)c01.r * ((1 << TEX_COORD_SHIFT) - uoff) + uoff * c11.r))
                 * voff) >> TEX_COORD_SHIFT*2,
             (((cast(uint)c00.g * ((1 << TEX_COORD_SHIFT) - uoff) + uoff * c10.g))
                 * ((1 << TEX_COORD_SHIFT) - voff)
             + ((cast(uint)c01.g * ((1 << TEX_COORD_SHIFT) - uoff) + uoff * c11.g))
                 * voff) >> TEX_COORD_SHIFT*2,
             (((cast(uint)c00.b * ((1 << TEX_COORD_SHIFT) - uoff) + uoff * c10.b))
                 * ((1 << TEX_COORD_SHIFT) - voff)
             + ((cast(uint)c01.b * ((1 << TEX_COORD_SHIFT) - uoff) + uoff * c11.b))
                 * voff) >> TEX_COORD_SHIFT*2
         );
      }
   }
   // ----

   VertexVariables lerp( VertexVariables first, VertexVariables second, float position ) {
      return add( first, scale( substract( second, first ), position ) );
   }
   
   VertexVariables scale( VertexVariables variables, float factor ) {
      VertexVariables result;
      // for ( uint i = 0; i < result.values.length; ++i ) {
      //   result.values[ i ] = variables.values[ i ] * factor;
      // }
      mixin( stringUnroll( "result.values[", "] = variables.values[", "] * factor;",
         result.values.length ) );
      return result;
   }
   
   VertexVariables add( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      // for ( uint i = 0; i < result.values.length; ++i ) {
      //   result.values[ i ] = first.values[ i ] + second.values[ i ];
      // }
      mixin( stringUnroll( "result.values[", "] = first.values[", "] + second.values[", "];",
         result.values.length ) );
      return result;
   }
   
   VertexVariables substract( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      // for ( uint i = 0; i < result.values.length; ++i ) {
      //   result.values[ i ] = first.values[ i ] - second.values[ i ];
      // }
      mixin( stringUnroll( "result.values[", "] = first.values[", "] - second.values[", "];",
         result.values.length ) );
      return result;
   }

   /**
    * Convinience struct for storing the transformed vertices.
    */
   struct TransformedVertex {
      Vector4 pos;
      VertexVariables vars;
   }

   /**
    * Rasters the specified triangle to the screen.
    * 
    * The values of the per-vertex data at the pixel position are interpolated and
    * feeded into the pixel shader to compute the color value.
    * 
    * Params:
    *   positions = The vertex positions in screen coordinates.
    *   variables = The per-vertex variables.
    */
   abstract void drawTriangle( Vector4[ 3 ] positions, VertexVariables[ 3 ] variables );
   
   /**
    * The color buffer to write the output to.
    * It is set by setRenderTarget.
    */
   Surface m_colorBuffer;
   /**
    * The Z buffer to use for the visibility calculations.
    * It is set by <code>setRenderTarget</code>.
    */
   ZBuffer m_zBuffer;
   
private:
   /**
    * Recalculates the cached world-view combo matrix.
    */
   void updateWorldViewMatrix() {
      m_worldViewMatrix = m_viewMatrix * m_worldMatrix;
   }

   /**
    * Recalculates the cached world-view-projection combo matrix.
    */
   void updateWorldViewProjMatrix() {
      m_worldViewProjMatrix = m_projMatrix * m_worldViewMatrix;
   }
   
   /**
    * View frustrum (clipping) planes for homogeneous clipping.
    */
   const CLIPPING_PLANES = [
      Plane( 1, 0, 0, 1 ),   // Left
      Plane( -1, 0, 0, 1 ),  // Right
      Plane( 0, -1, 0, 1 ),  // Top
      Plane( 0, 1, 0, 1 ),   // Bottom
      Plane( 0, 0, 1, 0 ),   // Near
      Plane( 0, 0, 1, 1 )    // Far
   ];

   /**
    * The maximum number of vertices a clipped triangle can have.
    * 8 because the triangle can be clipped by up to 4 sides of the viewing volume.
    */
   const CLIPPING_BUFFER_SIZE = 8;

   void renderTriangle( TransformedVertex vertex0, TransformedVertex vertex1, TransformedVertex vertex2 ) {
      // Clip all vertices against the view frustrum, which is now a cuboid from
      // [ -1; -1; 0 ] to [ 1, 1, 1 ]. To do this, we us homogeneous clipping,
      // which is fast and happens before the coordinates are divided by w.
      // We (legitimately?) assume that there are never more than
      // CLIPPING_BUFFER_SIZE vertices created during clipping.
      // TODO: Allocate as class member?
      TransformedVertex[ CLIPPING_BUFFER_SIZE ] vertices;
      TransformedVertex[ CLIPPING_BUFFER_SIZE ] clippingBuffer;
      
      vertices[ 0 ] = vertex0;
      vertices[ 1 ] = vertex1;
      vertices[ 2 ] = vertex2;

      uint vertexCount = 3;
      
      foreach ( i, plane; CLIPPING_PLANES ) {
         if ( i & 1 ) {
            // Even pass (first pass -> i=0).
            vertexCount = clipToPlane( clippingBuffer, vertices, vertexCount, plane );
         } else {
            // Uneven pass.
            vertexCount = clipToPlane( vertices, clippingBuffer, vertexCount, plane );
         }
         if ( vertexCount < 3 ) {
            // There is nothing left to be drawn.
            return;
         }
      }
      
      // FIXME: The substaction of 1 is a (temporary?) workaround for off-by-one error.
      float halfViewportWidth = 0.5f * cast( float )( m_colorBuffer.width - 1 );
      float halfViewportHeight = 0.5f * cast( float )( m_colorBuffer.height - 1 );
      
      for( uint i = 0; i < vertexCount; ++i ) {
         // TODO: How to use a ref instead of a pointer?
         TransformedVertex* vertex = &vertices[ i ];

         // Divide the vertex coordinates by w to get the »normal« (projected) positions.
         float invW = 1 / vertex.pos.w;
         vertex.pos.x *= invW;
         vertex.pos.y *= invW;
         vertex.pos.z *= invW;
         
         static if ( PrepareForPerspectiveCorrection ) {
            // Additionally, divide all vertex variables by w so that we can linearely
            // interpolate between them in screen space. Save invW to the w coordinate
            // so that we can reconstruct the original values later.
            vertex.vars = scale( vertex.vars, invW );
            vertex.pos.w = invW;
         }
         
         // Transform the position into viewport coordinates. We have to invert the
         // y-coordinate because the y-axis is pointing in the other direction in 
         // the viewport coordinate system.
         vertex.pos.x = ( vertex.pos.x + 1f ) * halfViewportWidth;
         vertex.pos.y = ( 1f - vertex.pos.y ) * halfViewportHeight;
      }
      
      // As we already have screen coordinates, looking at the z component
      // of the cross product of two triangle sides is enough. If it is positive,
      // the triangle normal is pointing away from the camera (screen) which 
      // means that the triangle can be culled.
      // TODO: Better position for this.
      if ( m_backfaceCulling != BackfaceCulling.NONE ) {
         Vector4 p0 = vertices[ 0 ].pos;
         Vector4 p1 = vertices[ 1 ].pos;
         Vector4 p2 = vertices[ 2 ].pos;
         
         float crossZ = ( p1.x - p0.x ) * ( p2.y - p0.y ) - ( p1.y - p0.y ) * ( p2.x - p0.x );
         if ( ( m_backfaceCulling == BackfaceCulling.CULL_CCW ) && ( crossZ < 0 ) ) {
            return;
         }
         
         if ( ( m_backfaceCulling == BackfaceCulling.CULL_CW ) && ( crossZ > 0 ) ) {
            return;
         }
      }
      
      uint triangleCount = vertexCount - 2;
      for ( uint i = 0; i < triangleCount; ++i ) {
         drawTriangle( [ vertices[ 0 ].pos, vertices[ i + 1 ].pos, vertices[ i + 2 ].pos ],
            [ vertices[ 0 ].vars, vertices[ i + 1 ].vars, vertices[ i + 2 ].vars ] );
      }
   }
   
   /**
    * Clips a polygon against a plane using homogeneous clipping.
    * 
    * Params:
    *     sourceBuffer = The buffer to read the source vertices from.
    *     targetBuffer = The buffer to write the clipped vertices to.
    *     vertexCount = The number of vertices in the source buffer.
    *     plane = The plane to clip against.
    * Returns: The number of vertices in the target buffer.
    */
   uint clipToPlane( TransformedVertex[] sourceBuffer, TransformedVertex[] targetBuffer,
      uint vertexCount, Plane plane ) {
      // Due to some function overloading strangeness, we have to alias the other
      // interpolation functions.
      // TODO: Why is this necessary?
      alias d4.math.Vector4.lerp lerpVector;
      alias lerp lerpVars;
      
      TransformedVertex lerpVertex( TransformedVertex first, TransformedVertex second, float position ) {
         TransformedVertex result;
         result.pos = lerpVector( first.pos, second.pos, position );
         result.vars = lerpVars( first.vars, second.vars, position );
         return result;
      }
      
      uint newCount = 0;
      
      for ( uint i = 0, j = 1; i < vertexCount; ++i, ++j ) {
         if ( j == vertexCount ) {
            // "Wrap" over the end to clip the last->first edge.
            j = 0;
         }
         
         // Distances of the current and the next vertex to the clipping plane.
         float currDist = plane.classifyHomogenous( sourceBuffer[ i ].pos );
         float nextDist = plane.classifyHomogenous( sourceBuffer[ j ].pos );
         
         if ( currDist >= 0.f ) {
            // The current vertex is »inside«, append it to the result.
            assert( newCount < CLIPPING_BUFFER_SIZE, "Created too many vertices during clipping!" );
            targetBuffer[ newCount++ ] = sourceBuffer[ i ];
            
            if ( nextDist < 0.f ) {
               // The edge to the next vertex is crossing the plane, interpolate the 
               // vertex which is exactly on the plane and append it to the result.
               assert( newCount < CLIPPING_BUFFER_SIZE, "Created too many vertices during clipping!" );
               targetBuffer[ newCount++ ] = lerpVertex( sourceBuffer[ i ], sourceBuffer[ j ],
                  currDist / ( currDist - nextDist ) );
            }
         } else if ( nextDist >= 0.f ) {
            // The next vertex is inside, also append the vertex on the plane.
            assert( newCount < CLIPPING_BUFFER_SIZE, "Created too many vertices during clipping!" );
            targetBuffer[ newCount++ ] = lerpVertex( sourceBuffer[ i ], sourceBuffer[ j ],
               currDist / ( currDist - nextDist ) );
         }
      }

      return newCount;
   }   
   
   Matrix4 m_worldMatrix;
   Matrix4 m_worldNormalMatrix;
   Matrix4 m_viewMatrix;
   Matrix4 m_projMatrix;
   Matrix4 m_worldViewMatrix;
   Matrix4 m_worldViewProjMatrix;
   
   BackfaceCulling m_backfaceCulling;

   Image[] m_textures;
   Color[][] m_textureDataPointers;
   
   // Shift the coordinates to the left to be able to perfom the subpixel
   // calculations using integer arithmetic.
   const TEX_COORD_SHIFT = 8;
   uint[] m_shiftedWidths;
   uint[] m_shiftedHeights;   
   uint[] m_shiftedXLimits;
   uint[] m_shiftedYLimits;
   uint[] m_texWidths;
   uint[] m_texHeights;   
}
