module d4.scene.WireframeMaterial;

import d4.renderer.IMaterial;
import d4.renderer.IRasterizer;
import d4.renderer.Renderer;
import d4.renderer.WireframeRasterizer;
import d4.shader.SingleColorShader;

/**
 * A simple material for rendering a white unlit wireframe model.
 */
class WireframeMaterial : IMaterial {
   IRasterizer createRasterizer() {
      return new WireframeRasterizer!( SingleColorShader )();
   }

   void prepareForRendering( Renderer renderer ) {
      // Nothing to do – we just need our rasterizer activated.
   }
}
