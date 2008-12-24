module d4.renderer.Rasterizer;

import d4.output.Surface;
import d4.renderer.Vertex;
import d4.renderer.ZBuffer;

abstract class Rasterizer {
public:
   abstract void drawTriangle( Vertex v0, Vertex v1, Vertex v2 );

   void setRenderTarget( Surface renderTarget, ZBuffer zBuffer ) {
      assert( renderTarget.width == zBuffer.width );
      assert( renderTarget.height == zBuffer.height );

      m_renderTarget = renderTarget;
      m_zBuffer = zBuffer;
   }

protected:
   Surface m_renderTarget;
   ZBuffer m_zBuffer;
}