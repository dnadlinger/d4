module d4.renderer.Renderer;

import d4.shader.SingleColorShader;
import tango.math.Math : PI;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Transformations;
import d4.math.Vector3;
import d4.math.Vector4;
import d4.output.Surface;
import d4.renderer.IRasterizer;
import d4.renderer.SolidRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.renderer.ZBuffer;
import d4.scene.Image;
import d4.scene.Vertex;

alias d4.renderer.IRasterizer.BackfaceCulling BackfaceCulling;

/**
 * The central interface to the rendering system.
 *
 * To render triangles, call <code>beginScene</code> first, then
 * <code>renderTriangleList</code> for any number of times and finally
 * <code>endScene</code> to finish the rendering process.
 */
class Renderer {
public:
   /**
    * Constructs a new renderer instance with the given render target.
    *
    * Params:
    *     renderTarget = The target to render to.
    */
   this( Surface renderTarget ) {
      m_renderTarget = renderTarget;
      m_zBuffer = new ZBuffer( renderTarget.width, renderTarget.height );
      m_clearColor = Color( 0, 0, 0 );

      m_rasterizers ~= new SolidRasterizer!( false, SingleColorShader )();
      m_activeRasterizer = m_rasterizers[ 0 ];
      m_activeRasterizer.setRenderTarget( m_renderTarget, m_zBuffer );
      setProjection( PI / 2, 0.1f, 100.f );

      m_rendering = false;
   }

   /**
    * Begins the rendering process.
    *
    * Params:
    *     clearColor = Whether to clear the framebuffer.
    *     clearZ = Whether to clear the z buffer.
    */
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

   /**
    * Ends the rendering process.
    *
    * You have to call this before calling <code>beginScene</code> again.
    */
   void endScene() {
      assert( m_rendering );
      m_renderTarget.unlock();
      m_rendering = false;
   }


   /**
    * The world matrix to use.
    */
   Matrix4 worldMatrix() {
      return m_activeRasterizer.worldMatrix;
   }

   /// ditto
   void worldMatrix( Matrix4 worldMatrix ) {
      m_activeRasterizer.worldMatrix = worldMatrix;
   }

   /**
    * The view matrix to use.
    */
   Matrix4 viewMatrix() {
      return m_activeRasterizer.viewMatrix;
   }

   /// ditto
   void viewMatrix( Matrix4 viewMatrix ) {
      m_activeRasterizer.viewMatrix = viewMatrix;
   }

   /**
    * Sets the (perspective) projection to use for rendering.
    *
    * Params:
    *     fovRadians = The vertical viewing angle (in radians).
    *     nearDistance = The distance of the near clipping plane (>0).
    *     farDistance = The distance of the far clipping plane (>nearDistance).
    */
   void setProjection( float fovRadians, float nearDistance, float farDistance ) {
      m_activeRasterizer.projectionMatrix = perspectiveProjectionMatrix(
         fovRadians,
         cast( float ) m_renderTarget.width / m_renderTarget.height,
         nearDistance,
         farDistance
      );
   }

   /**
    * Which type of backface culling to use.
    */
   BackfaceCulling backfaceCulling() {
      return m_activeRasterizer.backfaceCulling;
   }

   /// ditto
   void backfaceCulling( BackfaceCulling cullingMode ) {
      m_activeRasterizer.backfaceCulling = cullingMode;
   }

   /**
    * The color to clear the framebuffer with when a new frame is started.
    */
   Color clearColor() {
      return m_clearColor;
   }

   /// ditto
   void clearColor( Color clearColor ) {
      m_clearColor = clearColor;
   }

   /**
    * The textures needed for the active rasterizer.
    */
   Image[] activeTextures() {
      return m_activeRasterizer.textures;
   }

   /// ditto
   void activeTextures( Image[] textures ) {
      m_activeRasterizer.textures = textures;
   }


   /**
    * Registers a new rasterizer so that it can be activated later.
    *
    * Params:
    *     rasterizer = The rasterizer to register.
    * Returns: The rasterizer id which is used to activate the rasterizer later.
    */
   uint registerRasterizer( IRasterizer rasterizer ) {
      assert( rasterizer !is null, "Cannot register null rasterizer." );
      m_rasterizers ~= rasterizer;
      return m_rasterizers.length - 1;
   }

   /**
    * Unregister an already registered rasterizer because it is not needed
    * anymore.
    *
    * Params:
    *     id = The id of the rasterizer to unregister.
    * Returns: A reference to the unregistered rasterizer.
    */
   IRasterizer unregisterRasterizer( uint id ) {
      IRasterizer rasterizer = m_rasterizers[ id ];
      assert( rasterizer !is null, "Invalid rasterizer id (already unregistered?)." );

      // TODO: Better way to unregister without jumbling ids?
      // m_rasterizers[ id ] = m_rasterizers[ $ - 1 ];
      // m_rasterizers = m_rasterizers[ 0 .. ( $ - 1 ) ];
      m_rasterizers[ id ] = null;

      return rasterizer;
   }

   /**
    * Activates a rasterizer for rendering.
    *
    * Params:
    *     id = The rasterizer id which was returned by
    *     <code>registerRasterizer</code>.
    */
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
