module d4.renderer.Rasterizer;

import d4.output.Surface;
import d4.renderer.ZBuffer;
import d4.scene.Vertex;

abstract class Rasterizer {
public:
   abstract void drawTriangle( Vertex v0, Vertex v1, Vertex v2 );

   void setRenderTarget( Surface renderTarget, ZBuffer zBuffer ) {
      assert( renderTarget.width == zBuffer.width, "ZBuffer width must match framebuffer width." );
      assert( renderTarget.height == zBuffer.height, "ZBuffer height must match framebuffer height." );

      m_renderTarget = renderTarget;
      m_zBuffer = zBuffer;
   }

protected:
   Surface m_renderTarget;
   ZBuffer m_zBuffer;
}
