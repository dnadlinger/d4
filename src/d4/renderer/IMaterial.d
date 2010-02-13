module d4.renderer.IMaterial;

import d4.renderer.IRasterizer;
import d4.renderer.Renderer;

/**
 * A material which controlls <em>all</em> aspects of the appearance of a
 * rendered object.
 *
 * Only use with <strong>one</strong> <code>Renderer</code> instance at a time
 * for now, this may change in the future though.
 */
interface IMaterial {
   /**
    * Returns an <code>IRasterizer</code> which is configured to draw this
    * material.
    *
    * By design, it is assumed that this operation can be very expensive.
    */
   IRasterizer createRasterizer();

   /**
    * Prepares the material for rendering.
    *
    * This is an opportunity to execute any tasks every time the material is
    * activated by a <code>Renderer</code>.
    *
    * TODO: Is passing the Renderer really the right thing?
    * Maybe passing the used IRasterizer instance would be a better idea.
    *
    * Params:
    *    renderer = The renderer which uses the material.
    */
   void prepareForRendering( Renderer renderer );
}
