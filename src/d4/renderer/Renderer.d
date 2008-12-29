module d4.renderer.Renderer;

import tango.io.Stdout;
import tango.math.Math : PI;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector3;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.DefaultShader;
import d4.renderer.IRasterizer;
import d4.renderer.SolidGouraudRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.renderer.ZBuffer;
import d4.scene.Vertex;

alias d4.renderer.IRasterizer.BackfaceCulling BackfaceCulling;

/**
 * The central interface to the rendering system.
 */
class Renderer {
public:
   this( Surface renderTarget ) {
      m_renderTarget = renderTarget;
      m_zBuffer = new ZBuffer( renderTarget.width, renderTarget.height );
      m_clearColor = Color( 0, 0, 0 );

      m_activeRasterizer = new SolidGouraudRasterizer!( DefaultShader )();
      m_activeRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );
      setProjection( PI / 2, 0.1f, 100.f );

      m_rendering = false;
      
      m_rasterizers[ RASTERIZER_SOLID_GOURAUD ] =  new SolidGouraudRasterizer!( DefaultShader )();
      m_rasterizers[ RASTERIZER_WIREFRAME ] = new WireframeRasterizer!( DefaultShader )();
   }

   void beginScene( bool clearColor = true, bool clearZ = true ) {
      assert( !m_rendering );
      m_rendering = true;
      m_renderTarget.lock();

      if ( clearColor ) {
         m_renderTarget.clear( m_clearColor );
      }
      if ( clearZ ) {
         m_zBuffer.clear();
      }
   }

   /**
    * Renders a set of indexed triangles.
    * 
    * Params:
    *     vertices = The vertices to render.
    *     indices = The indices referring to the passed vertex array.
    */
   void renderTriangleList( Vertex[] vertices, uint[] indices ) {
      assert( m_rendering );

      m_activeRasterizer.renderTriangleList( vertices, indices );
   }

   void endScene() {
      assert( m_rendering );
      m_renderTarget.unlock();
      m_rendering = false;
   }


   Matrix4 worldMatrix() {
      return m_activeRasterizer.worldMatrix;
   }

   void worldMatrix( Matrix4 worldMatrix ) {
      m_activeRasterizer.worldMatrix = worldMatrix;
   }

   Matrix4 viewMatrix() {
      return m_activeRasterizer.viewMatrix;
   }

   void viewMatrix( Matrix4 viewMatrix ) {
      m_activeRasterizer.viewMatrix = viewMatrix;
   }

   void setProjection( float fovRadians, float nearDistance, float farDistance ) {
      m_activeRasterizer.projectionMatrix = Matrix4.perspectiveProjection(
         fovRadians,
         cast( float ) m_renderTarget.width / m_renderTarget.height,
         nearDistance,
         farDistance
      );
   }
   
   BackfaceCulling backfaceCulling() {
      return m_activeRasterizer.backfaceCulling;
   }
   
   void backfaceCulling( BackfaceCulling cullingMode ) {
      m_activeRasterizer.backfaceCulling = cullingMode;
   }
   
   bool wireframe() {
      return m_activeRasterizer == m_rasterizers[ RASTERIZER_WIREFRAME ];
   }
   
   void wireframe( bool wireframe ) {
      if ( wireframe ) {
         setActiveRasterizer( m_rasterizers[ RASTERIZER_WIREFRAME ] );
      } else {
         setActiveRasterizer( m_rasterizers[ RASTERIZER_SOLID_GOURAUD ] );
      }
   }

   Color clearColor() {
      return m_clearColor;
   }

   void clearColor( Color clearColor ) {
      m_clearColor = clearColor;
   }
   
private:
   void setActiveRasterizer( IRasterizer rasterizer ) {
      if ( rasterizer == m_activeRasterizer ) {
         return;
      }
      
      rasterizer.worldMatrix = m_activeRasterizer.worldMatrix;
      rasterizer.viewMatrix = m_activeRasterizer.viewMatrix;
      rasterizer.projectionMatrix = m_activeRasterizer.projectionMatrix;
      rasterizer.backfaceCulling = m_activeRasterizer.backfaceCulling;
      
      m_activeRasterizer = rasterizer;
      m_activeRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );
   }
   
   IRasterizer[ 2 ] m_rasterizers;
   IRasterizer m_activeRasterizer;
   
   const RASTERIZER_SOLID_GOURAUD = 0;
   const RASTERIZER_WIREFRAME = 1;

   Surface m_renderTarget;
   ZBuffer m_zBuffer;

   Color m_clearColor;
   bool m_rendering;
}