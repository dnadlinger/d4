module d4.renderer.Rasterizer;

import d4.output.Surface;
import d4.renderer.PixelShader;
import d4.renderer.TransformedTriangle;
import d4.renderer.ZBuffer;

abstract class Rasterizer {
public:
   abstract void drawTriangle( TransformedTriangle triangle );

   void setRenderTarget( Surface renderTarget, ZBuffer zBuffer ) {
      assert( renderTarget.width == zBuffer.width, "ZBuffer width must match framebuffer width." );
      assert( renderTarget.height == zBuffer.height, "ZBuffer height must match framebuffer height." );

      m_renderTarget = renderTarget;
      m_zBuffer = zBuffer;
   }

   PixelShader pixelShader() {
      return m_shader;
   }

   void pixelShader( PixelShader shader ) {
      m_shader = shader;
   }

protected:
   Surface m_renderTarget;
   ZBuffer m_zBuffer;
   PixelShader m_shader;
}
