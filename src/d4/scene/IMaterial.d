module d4.scene.IMaterial;

import d4.renderer.IRasterizer;
import d4.scene.Image;

interface IMaterial {
   IRasterizer createRasterizer();

   bool wireframe();
   // TODO: Use general fallback material in MaterialManager instead?
   void wireframe( bool useWireframe );

   bool gouraudShading();
   void gouraudShading( bool interpolate );

   Image[] textures();
}