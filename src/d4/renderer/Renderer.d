module d4.renderer.Renderer;

import tango.io.Stdout;
import tango.math.Math : PI;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector3;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.Rasterizer;
import d4.renderer.Vertex;
import d4.renderer.ZBuffer;

class Renderer {
public:
   this( Surface renderTarget ) {
      m_renderTarget = renderTarget;
      m_zBuffer = new ZBuffer( renderTarget.width, renderTarget.height );

      m_worldMatrix = Matrix4.identity;
      m_viewMatrix = Matrix4.identity;
      updateWorldViewMatrix();
      setProjection( PI / 2, 0.1f, 10.f );

      m_rendering = false;

      m_backfaceCulling = true;
   }

   void beginScene( bool clear = true ) {
      assert( !m_rendering );
      m_rendering = true;
      m_renderTarget.lock();

      if ( clear ) {
         m_renderTarget.clear( m_clearColor );
      }
   }

   void renderTriangleList( Vertex[] vertices, uint[] indices ) {
      assert( m_rendering );

      // There must be no incomplete triangles.
      assert( indices.length % 3 == 0 );

      // Clipping

      Vector3[] positions = transformVertices( vertices );

      // Clipping?

      for ( uint i = 0; i < indices.length; i += 3 ) {
         Vertex v0 = vertices[ indices[ i ] ];
         Vertex v1 = vertices[ indices[ i + 1 ] ];
         Vertex v2 = vertices[ indices[ i + 2 ] ];

         Vector3 p0 = positions[ indices[ i ] ];
         Vector3 p1 = positions[ indices[ i + 1 ] ];
         Vector3 p2 = positions[ indices[ i + 2 ] ];

         if ( m_backfaceCulling ) {
            // As we already have screen coordinates, looking at the z component
            // of the cross product is enough. If it is positive, the triangle normal
            // is pointing away from the camera and the triangle is hence culled.
            if ( ( p2.x - p0.x ) * ( p2.y - p1.y ) - ( p2.y - p0.y ) * ( p2.x - p1.x ) > 0 ) {
               continue;
            }
         }

         v0.position = p0;
         v1.position = p1;
         v2.position = p2;

         m_triangleRasterizer.drawTriangle( v0, v1, v2 );
      }
   }

   void endScene() {
      assert( m_rendering );
      m_renderTarget.unlock();
      m_rendering = false;
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

   void setProjection( float fovRadians, float nearDistance, float farDistance ) {
      m_projMatrix = Matrix4.scaling( m_renderTarget.width / 2, m_renderTarget.height / 2 );
      m_projMatrix *= Matrix4.translation( 1, 1 );

      m_projMatrix *= Matrix4.perspectiveProjection(
         fovRadians,
         cast( float )m_renderTarget.width / m_renderTarget.height,
         nearDistance,
         farDistance
      );
      updateWorldViewProjMatrix();
   }

   Color clearColor() {
      return m_clearColor;
   }

   void clearColor( Color clearColor ) {
      m_clearColor = clearColor;
   }

   bool backfaceCulling() {
      return m_backfaceCulling;
   }

   void backfaceCulling( bool performCulling ) {
      m_backfaceCulling = performCulling;
   }

   Rasterizer triangleRasterizer() {
      return m_triangleRasterizer;
   }

   void triangleRasterizer( Rasterizer triangleRasterizer ) {
      m_triangleRasterizer = triangleRasterizer;
      triangleRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );
   }

private:
   void updateWorldViewMatrix() {
      m_worldViewMatrix = m_viewMatrix * m_worldMatrix;
   }

   void updateWorldViewProjMatrix() {
      m_worldViewProjMatrix = m_projMatrix * m_worldViewMatrix;
   }

   Vector3[] transformVertices( Vertex[] vertices ) {
      Vector3[] result;
      result.length = vertices.length;

      foreach ( i, vertex; vertices ) {
         result[ i ] = ( m_worldViewProjMatrix * vertex.position ).homogenized();
      }

      return result;
   }

   Surface m_renderTarget;
   ZBuffer m_zBuffer;

   Matrix4 m_worldMatrix;
   Matrix4 m_viewMatrix;
   Matrix4 m_projMatrix;
   Matrix4 m_worldViewMatrix;
   Matrix4 m_worldViewProjMatrix;

   Color m_clearColor;
   bool m_rendering;

   bool m_backfaceCulling;

   Rasterizer m_triangleRasterizer;
}