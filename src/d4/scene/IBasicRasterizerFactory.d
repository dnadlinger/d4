module d4.scene.IBasicRasterizerFactory;

import d4.scene.BasicMaterial;
import d4.renderer.IRasterizer;

/**
 * Serves as an extra layer of indirection between BasicMaterial and the default
 * shader creation.
 *
 * The rationale behind this is to avoid instancing RasterizerBase several times
 * for the generic default shaders if they are not nedeed (and so bloating the
 * resulting binary), but BasicMaterial is used (e.g. in the model loader).
 */
interface IBasicRasterizerFactory {
   /**
    * Creates a rasterizer fitting the properties of the given BasicMaterial.
    *
    * Params:
    *    material = The material to create the IRasterizer for.
    * Returns:
    *    The newly created rasterizer.
    */
   IRasterizer getRasterizer( BasicMaterial material );
}
