module d4.scene.IMaterial;

import d4.renderer.IRasterizer;
import d4.scene.Image;

/**
 * A material which is managed by the MaterialManager.
 * It controlls <em>all</em> aspects of appearance.
 */
interface IMaterial {
   /**
    * Creates an IRasterizer which is configured to draw the material.
    */
   IRasterizer createRasterizer();

   /**
    * Whether the material is drawn as a wireframe or solid.
    */
   bool wireframe();
   // TODO: Use general fallback material in MaterialManager instead?
   
   /// ditto
   void wireframe( bool useWireframe );

   /**
    * Wheter the material uses gouraud shading to interpolate between the
    * vertex variables.
    */
   bool gouraudShading();
   
   /// ditto
   void gouraudShading( bool interpolate );

   /**
    * The textures the material is using.
    */
   Image[] textures();
}