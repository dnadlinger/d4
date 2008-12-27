module d4.renderer.Renderer;

import tango.io.Stdout;
import tango.math.Math : PI;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector3;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.DefaultShaders;
import d4.renderer.GeometryProcessor;
import d4.renderer.PixelShader;
import d4.renderer.Rasterizer;
import d4.renderer.SimpleWireframeRasterizer;
import d4.renderer.TransformedTriangle;
import d4.renderer.VertexShader;
import d4.renderer.ZBuffer;
import d4.scene.Vertex;

enum TriangleOrientation {
   CCW,
   CW
}

/**
 * The central interface to the rendering system.
 */
class Renderer {
public:
   this( Surface renderTarget ) {
      m_renderTarget = renderTarget;
      m_zBuffer = new ZBuffer( renderTarget.width, renderTarget.height );
      m_clearColor = Color( 0, 0, 0 );

      m_geometryProcessor = new GeometryProcessor();
      setProjection( PI / 2, 0.1f, 10.f );
      m_triangleRasterizer = new SimpleWireframeRasterizer();
      m_triangleRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );

      vertexShader( new DefaultVertexShader() );
      pixelShader( new DefaultPixelShader() );

      m_rendering = false;
   }

   void beginScene( bool clear = true ) {
      assert( !m_rendering );
      m_rendering = true;
      m_renderTarget.lock();

      if ( clear ) {
         m_renderTarget.clear( m_clearColor );
      }
   }

   /**
    * Renders a set of indexed triangles.
    * Params:
    *     vertices = The vertices to render.
    *     indices = The indices referring to the passed vertex array.
    */
   void renderTriangleList( Vertex[] vertices, uint[] indices ) {
      assert( m_rendering );

      TransformedTriangle[] triangles = m_geometryProcessor.transformTriangles( vertices, indices );

      float halfWidth = m_renderTarget.width / 2;
      float halfHeight = m_renderTarget.height / 2;

      void toViewportCoords( inout Vector4 pos ) {
         pos.x += 1;
         pos.y += 1;
         pos.x *= halfWidth;
         pos.y *= halfHeight;
      }

      foreach ( triangle; triangles ) {
         toViewportCoords( triangle.pos0 );
         toViewportCoords( triangle.pos1 );
         toViewportCoords( triangle.pos2 );
         m_triangleRasterizer.drawTriangle( triangle );
      }
   }

   void endScene() {
      assert( m_rendering );
      m_renderTarget.unlock();
      m_rendering = false;
   }


   Matrix4 worldMatrix() {
      return m_geometryProcessor.worldMatrix;
   }

   void worldMatrix( Matrix4 worldMatrix ) {
      m_geometryProcessor.worldMatrix = worldMatrix;
   }

   Matrix4 viewMatrix() {
      return m_geometryProcessor.viewMatrix;
   }

   void viewMatrix( Matrix4 viewMatrix ) {
      m_geometryProcessor.viewMatrix = viewMatrix;
   }

   void setProjection( float fovRadians, float nearDistance, float farDistance ) {
      m_geometryProcessor.projectionMatrix = Matrix4.perspectiveProjection(
         fovRadians,
         cast( float ) m_renderTarget.width / m_renderTarget.height,
         nearDistance,
         farDistance
      );
   }

   Color clearColor() {
      return m_clearColor;
   }

   void clearColor( Color clearColor ) {
      m_clearColor = clearColor;
   }

   bool cullBackfaces() {
      if ( m_triangleOrientation == TriangleOrientation.CCW ) {
         return m_geometryProcessor.backfaceCulling == BackfaceCulling.CW;
      } else if ( m_triangleOrientation == TriangleOrientation.CW ) {
         return m_geometryProcessor.backfaceCulling == BackfaceCulling.CCW;
      }
   }

   void cullBackfaces( bool performCulling ) {
      if( performCulling ) {
         if ( m_triangleOrientation == TriangleOrientation.CCW ) {
            m_geometryProcessor.backfaceCulling = BackfaceCulling.CW;
         } else if ( m_triangleOrientation == TriangleOrientation.CW ) {
            m_geometryProcessor.backfaceCulling = BackfaceCulling.CCW;
         }
      } else {
         m_geometryProcessor.backfaceCulling = BackfaceCulling.NONE;
      }
   }

   TriangleOrientation triangleOrientation() {
      return m_triangleOrientation;
   }

   void triangleOrientation( TriangleOrientation orientation ) {
      bool performCulling = cullBackfaces();
      m_triangleOrientation = orientation;
      cullBackfaces( performCulling );
   }

   VertexShader vertexShader() {
      return m_geometryProcessor.vertexShader;
   }

   void vertexShader( VertexShader shader ) {
      m_geometryProcessor.vertexShader = shader;
   }

   PixelShader pixelShader() {
      return m_triangleRasterizer.pixelShader;
   }

   void pixelShader( PixelShader shader ) {
      m_triangleRasterizer.pixelShader = shader;
   }

private:
   GeometryProcessor m_geometryProcessor;
   Rasterizer m_triangleRasterizer;

   Surface m_renderTarget;
   ZBuffer m_zBuffer;

   Color m_clearColor;
   bool m_rendering;

   TriangleOrientation m_triangleOrientation;
}