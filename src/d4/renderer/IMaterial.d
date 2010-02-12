module d4.renderer.IMaterial;

import d4.renderer.IRasterizer;
import d4.renderer.Renderer;

/**
 * A material which controlls <em>all</em> aspects of the appearance of a
 * rendered object.
 *
 * Only use with <strong>one</strong> Renderer instance at a time.
 */
interface IMaterial {
   /**
    * Returns a reference to an IRasterizer which is configured
    * to draw the material.
    */
   IRasterizer getRasterizer();

   void prepareForRendering( Renderer renderer );
}
