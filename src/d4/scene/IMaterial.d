module d4.scene.IMaterial;

import d4.renderer.IRasterizer;

interface IMaterial {
   IRasterizer createRasterizer();
   
   bool wireframe();
   void wireframe( bool wireframe );
}