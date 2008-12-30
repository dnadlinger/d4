module d4.renderer.Rasterizer;

import tango.io.Stdout;
import tango.math.IEEE : RoundingMode, setIeeeRounding;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Plane;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.IRasterizer;
import d4.renderer.ZBuffer;
import d4.scene.Vertex;
import d4.scene.ColoredVertex;

abstract class RasterizerBase( alias Shader ) : IRasterizer {
   this() {
      m_worldMatrix = Matrix4.identity;
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
      // when leaving the function.
      auto oldRoundingMode = setIeeeRounding( RoundingMode.ROUNDDOWN );
      scope ( exit ) setIeeeRounding( oldRoundingMode );

      // Invoke vertex shader to get the positions in clipping coordinates
      // and to compute any additional per-vertex data.
      TransformedVertex[] transformed;
      
      foreach ( vertex; vertices ) {
         TransformedVertex current;
         
         vertexShader( vertex, current.pos, current.vars );
         // Note: The positions are still not divided by w (»homogenzied«).
         
         transformed ~= current;
      }
      
      for ( uint i = 0; i < indices.length; i += 3 ) {
         renderTriangle( transformed[ indices[ i ] ], transformed[ indices[ i + 1 ] ], transformed[ indices[ i + 2 ] ] );
      }
   }
   
   void setRenderTarget( Surface colorBuffer, ZBuffer zBuffer ) {
      assert( colorBuffer.width == zBuffer.width, "ZBuffer width must match framebuffer width." );
      assert( colorBuffer.height == zBuffer.height, "ZBuffer height must match framebuffer height." );

      m_colorBuffer = colorBuffer;
      m_zBuffer = zBuffer;
   }   
   
   Matrix4 worldMatrix() {
      return m_worldMatrix;
   }

   void worldMatrix( Matrix4 worldMatrix ) {
      m_worldMatrix = worldMatrix;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
   }

   Matrix4 viewMatrix() {
      return m_viewMatrix;
   }

   void viewMatrix( Matrix4 viewMatrix ) {
      m_viewMatrix = viewMatrix;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
   }
   
   Matrix4 projectionMatrix() {
      return m_projMatrix;
   }

   void projectionMatrix( Matrix4 projectionMatrix ) {
      m_projMatrix = projectionMatrix;
      updateWorldViewProjMatrix();
   }

   BackfaceCulling backfaceCulling() {
      return m_backfaceCulling;
   }
   
   void backfaceCulling( BackfaceCulling cullingMode ) {
      m_backfaceCulling = cullingMode;
   }
   
protected:
   /**
    * Imports the shader template passed to the class template into the class
    * scope.
    * 
    * The shader has to provide:
    *  - void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables );
    *  - Color pixelShader( VertexVariables variables );
    *  - struct VertexVariables
    */
   mixin Shader;
   
   // TODO: String-unroll the loops.
   
   VertexVariables lerp( VertexVariables first, VertexVariables second, float position ) {
      return add( first, scale( substract( second, first ), position ) );
   }
   
   VertexVariables scale( VertexVariables variables, float factor ) {
      VertexVariables result;
      for ( uint i = 0; i < result.values.length; ++i ) {
         result.values[ i ] = variables.values[ i ] * factor;
      }
      return result;
   }
   
   VertexVariables add( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      for ( uint i = 0; i < result.values.length; ++i ) {
         result.values[ i ] = first.values[ i ] + second.values[ i ];
      }
      return result;
   }
   
   VertexVariables substract( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      for ( uint i = 0; i < result.values.length; ++i ) {
         result.values[ i ] = first.values[ i ] - second.values[ i ];
      }
      return result;
   }
   
   /+template scaleComponent( variables, float factor, uint index ) {
      variables.values;
      static if ( index > 0 ) {
         const scaleComponent = scaleComponent!( variables, factor, index - 1 );
      } else {
         const scaleComponent = variables;
      }
   }+/
   
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
   
   void renderTriangle( TransformedVertex vertex0, TransformedVertex vertex1, TransformedVertex vertex2 ) {
      TransformedVertex[] vertices = [ vertex0, vertex1, vertex2 ];
      
      const CLIPPING_PLANES = [
         Plane( 1, 0, 0, 1 ),   // Left
         Plane( -1, 0, 0, 1 ),  // Right
         Plane( 0, -1, 0, 1 ),  // Top
         Plane( 0, 1, 0, 1 ),   // Bottom
         Plane( 0, 0, 1, 0 ),   // Near
         Plane( 0, 0, 1, 1 )   // Far
      ];
      
      foreach ( i, plane; CLIPPING_PLANES ) {
         vertices = clipToPlane( vertices, plane );
         if ( vertices.length < 3 ) {
            // There is nothing left to be drawn.
            return;
         }
      }
      
      foreach ( inout vertex; vertices ) {
         // Divide the vertex coordinates by w to get the »normal« (projected) positions.
         float invW = 1 / vertex.pos.w;
         vertex.pos.x *= invW;
         vertex.pos.y *= invW;
         vertex.pos.z *= invW;
         
         // Additionally, divide all vertex variables by w so that we can linearely
         // interpolate between them in screen space. Save invW to the w coordinate
         // so that we can reconstruct the original values later.
         vertex.vars = scale( vertex.vars, invW );
         vertex.pos.w = invW;
         
         // Transform the position into viewport coordinates. We have to invert the
         // y-coordinate because the y-axis is pointing in the other direction in 
         // the viewport coordinate system.
         // FIXME: The substaction of 1 is a temporary workaround for off-by-one error. 
         vertex.pos.x = ( vertex.pos.x + 1 ) / 2 * ( m_colorBuffer.width - 1 );
         vertex.pos.y = ( 1 - vertex.pos.y ) / 2 * ( m_colorBuffer.height - 1 );
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
         if ( ( m_backfaceCulling == BackfaceCulling.CULL_CCW ) && ( crossZ > 0 ) ) {
            return;
         }
         
         if ( ( m_backfaceCulling == BackfaceCulling.CULL_CW ) && ( crossZ < 0 ) ) {
            return;
         }
      }
      
      uint triangleCount = vertices.length - 2;
      for ( uint i = 0; i < triangleCount; ++i ) {
         drawTriangle( [ vertices[ 0 ].pos, vertices[ i + 1 ].pos, vertices[ i + 2 ].pos ],
            [ vertices[ 0 ].vars, vertices[ i + 1 ].vars, vertices[ i + 2 ].vars ] );
      }
   }
   
   
   TransformedVertex[] clipToPlane( TransformedVertex[] vertices, Plane plane ) {
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
      
      TransformedVertex[] result;
      
      for ( uint i = 0, j = 1; i < vertices.length; ++i, ++j ) {
         if ( j == vertices.length ) {
            // "Wrap" over the end to clip the last->first edge.
            j = 0;
         }
         
         // Distances of the current and the next vertex to the clipping plane.
         float currDist = plane.classifyHomogenous( vertices[ i ].pos );
         float nextDist = plane.classifyHomogenous( vertices[ j ].pos );
         
         if ( currDist >= 0.f ) {
            // The current vertex is »inside«, append it to the result.
            result ~= vertices[ i ];
            
            if ( nextDist < 0.f ) {
               // The edge to the next vertex is crossing the plane, interpolate the 
               // vertex which is exactly on the plane and append it to the result.
               result ~= lerpVertex( vertices[ i ], vertices[ j ], currDist / ( currDist - nextDist ) );
            }
         } else if ( nextDist >= 0.f ) {
            // The next vertex is inside, also append the vertex on the plane.
            result ~= lerpVertex( vertices[ i ], vertices[ j ], currDist / ( currDist - nextDist ) );
         }
      }
      
      return result;
   }   
   
   Matrix4 m_worldMatrix;
   Matrix4 m_worldNormalMatrix;
   Matrix4 m_viewMatrix;
   Matrix4 m_projMatrix;
   Matrix4 m_worldViewMatrix;
   Matrix4 m_worldViewProjMatrix;
   
   BackfaceCulling m_backfaceCulling;
}

char[] str( uint number ) {
   char digits[];
   if ( number > 10 ) {
      digits = str( number / 10 );
   }
   
   digits ~= cast( char )( '0' + number % 10 );
   return digits;
}

template vector3Variable( char[] name, uint index ) {
   const char[] vector3Variable =
      "Vector3 " ~ name ~ "() { "
         "return Vector3( values[" ~ str( index ) ~  "], values[" ~ str( index + 1 ) ~ "], values[" ~ str( index + 2 ) ~ "] );"
      "}"
      "void " ~ name ~ "( Vector3 vector ) { "
         "values[" ~ str( index ) ~  "] = vector.x;"
         "values[" ~ str( index + 1 ) ~  "] = vector.y;"
         "values[" ~ str( index + 2 ) ~  "] = vector.z;"
      "}";
}

template colorVariable( char[] name, uint index ) {
   const char[] colorVariable =
      "Color " ~ name ~ "() {"
         "Color result;"
         "result.a = cast( ubyte )( values[" ~ str( index ) ~  "] * 255 );"
         "result.r = cast( ubyte )( values[" ~ str( index + 1 ) ~  "] * 255 );"
         "result.g = cast( ubyte )( values[" ~ str( index + 2 ) ~  "] * 255 );"
         "result.b = cast( ubyte )( values[" ~ str( index + 3 ) ~  "] * 255 );"
         "return result;"
      "}"
      "void " ~ name ~ "( Color color ) {"
         "values[" ~ str( index ) ~  "] = cast( float ) color.a / 255f;"
         "values[" ~ str( index + 1 ) ~  "] = cast( float ) color.r / 255f;"
         "values[" ~ str( index + 2 ) ~  "] = cast( float ) color.g / 255f;"
         "values[" ~ str( index + 3 ) ~  "] = cast( float ) color.b / 255f;"
      "}";
}
