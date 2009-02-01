module d4.renderer.Renderer;

import tango.io.Stdout;
import tango.math.Math : PI;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Transformations;
import d4.math.Vector3;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.IRasterizer;
import d4.renderer.SolidGouraudRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.renderer.ZBuffer;
import d4.scene.Image;
import d4.scene.Vertex;

alias d4.renderer.IRasterizer.BackfaceCulling BackfaceCulling;

/**
 * Workaround for compiler bug if the shaders are instantiated in two different
 * modules. This is the same as SingleColorShader.
 */
template DefaultShader() {
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      position = worldViewProjMatrix * vertex.position;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255 );
   }
   
   struct VertexVariables {
      float[0] values;
   }
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

      m_rasterizers ~= new SolidGouraudRasterizer!( DefaultShader )();
      m_activeRasterizer = m_rasterizers[ 0 ];
      m_activeRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );
      setProjection( PI / 2, 0.1f, 100.f );

      m_rendering = false;
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
      m_activeRasterizer.projectionMatrix = perspectiveProjectionMatrix(
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
   
   Color clearColor() {
      return m_clearColor;
   }

   void clearColor( Color clearColor ) {
      m_clearColor = clearColor;
   }
   
   Image[] activeTextures() {
      return m_activeRasterizer.textures;
   }

   void activeTextures( Image[] textures ) {
      m_activeRasterizer.textures = textures;
   }

   uint registerRasterizer( IRasterizer rasterizer ) {
      assert( rasterizer !is null, "Cannot register null rasterizer." );
      m_rasterizers ~= rasterizer;
      return m_rasterizers.length - 1;
   }
   
   IRasterizer unregisterRasterizer( uint id ) {
      IRasterizer rasterizer = m_rasterizers[ id ];
      assert( rasterizer !is null, "Invalid rasterizer id (already unregistered?)." );
      
      // TODO: Better way to unregister without jumbling ids?
      // m_rasterizers[ id ] = m_rasterizers[ $ - 1 ];
      // m_rasterizers = m_rasterizers[ 0 .. ( $ - 1 ) ];
      m_rasterizers[ id ] = null;
      
      return rasterizer;
   }
   
   void useRasterizer( uint id ) {
      IRasterizer rasterizer = m_rasterizers[ id ];
      assert( rasterizer !is null );
      setActiveRasterizer( rasterizer );
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
      rasterizer.textures = m_activeRasterizer.textures;
      
      m_activeRasterizer = rasterizer;
      m_activeRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );
   }
   
   IRasterizer[] m_rasterizers;
   IRasterizer m_activeRasterizer;

   Surface m_renderTarget;
   ZBuffer m_zBuffer;

   Color m_clearColor;
   bool m_rendering;
}
