module d4.renderer.Rasterizer;

import tango.io.Stdout;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.IRasterizer;
import d4.renderer.ZBuffer;
import d4.scene.Vertex;

abstract class RasterizerBase( alias Shader ) : IRasterizer {
   this() {
      m_worldMatrix = Matrix4.identity;
      m_viewMatrix = Matrix4.identity;
      m_projMatrix = Matrix4.identity;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
      
      m_backfaceCulling = BackfaceCulling.CW;
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

      // Clipping

      Vector4[] positions;
      VertexVariables[] variables;
      
      foreach ( vertex; vertices ) {
         Vector4 currentPosition;
         VertexVariables currentVariables;
         
         vertexShader( vertex, currentPosition, currentVariables );
         
         currentPosition.homogenize();
         
         positions ~= currentPosition;
         variables ~= currentVariables;
      }

      // Clipping?
      
      // Transform the projected positions into viewport coordinates.
      float halfViewportWidth = m_colorBuffer.width / 2;
      float halfViewportHeight = m_colorBuffer.height / 2;
      foreach ( inout pos; positions ) {
         pos.x += 1;
         pos.y += 1;
         pos.x *= halfViewportWidth;
         pos.y *= halfViewportHeight;
      }
      
      for ( uint i = 0; i < indices.length; i += 3 ) {
         uint i0 = indices[ i ];
         uint i1 = indices[ i + 1 ];
         uint i2 = indices[ i + 2 ];
         
         Vector4 p0 = positions[ i0 ];
         Vector4 p1 = positions[ i1 ];
         Vector4 p2 = positions[ i2 ];

         // As we already have screen coordinates, looking at the z component
         // of the cross product of two triangle sides is enough. If it is positive,
         // the triangle normal is pointing away from the camera (screen) which 
         // means that the triangle can be culled.
         if ( m_backfaceCulling == BackfaceCulling.CCW ) {
            if ( ( p1.x - p0.x ) * ( p2.y - p0.y ) - ( p1.y - p0.y ) * ( p2.x - p0.x ) > 0 ) {
               continue;
            }
         } else if ( m_backfaceCulling == BackfaceCulling.CW ) {
            if ( ( p0.x - p1.x ) * ( p0.y - p2.y ) - ( p0.y - p1.y ) * ( p0.x - p2.x ) > 0 ) {
               continue;
            }
         }
         
//       Stdout.format( "Drawing triangle: ({}, {}); ({}, {}); ({}, {})",
//            p0.x, p0.y, p1.x, p1.y, p2.x, p2.y ).newline;
         
         drawTriangle( p0, variables[ i0 ], p1, variables[ i1 ], p2, variables[ i2 ] );
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
    *  - VertexVariables interpolate( ... );
    */
   mixin Shader;
   
   /**
    * Rasters the specified triangle to the screen.
    * 
    * The values of the per-vertex data at the pixel position are interpolated and
    * feeded into the pixel shader to compute the color value. 
    * 
    * Params:
    *     pos0 = Position of the first vertex. 
    *     vars0 = Variable values of the first vertex.
    *     pos1 = Position of the second vertex.
    *     vars1 = Variable values of the second vertex.
    *     pos2 = Position of the third vertex.
    *     vars2 = Variable values of the third vertex.
    */
   abstract void drawTriangle(
      Vector4 pos0, VertexVariables vars0,
      Vector4 pos1, VertexVariables vars1,
      Vector4 pos2, VertexVariables vars2
   );
   
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
   
   Matrix4 m_worldMatrix;
   Matrix4 m_viewMatrix;
   Matrix4 m_projMatrix;
   Matrix4 m_worldViewMatrix;
   Matrix4 m_worldViewProjMatrix;
   
   BackfaceCulling m_backfaceCulling;
}
