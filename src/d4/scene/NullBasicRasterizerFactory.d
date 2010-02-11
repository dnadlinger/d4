module d4.scene.NullBasicRasterizerFactory;

import d4.renderer.IRasterizer;
import d4.scene.BasicMaterial;
import d4.scene.IBasicRasterizerFactory;

/**
 * A stub IBasicRasterizerFactory which just returns null when
 * <code>getRasterizer</code> is called. This avoids bloat if you do not intend
 * to use the <code>BasicMaterial</code>s created by e.g. a model importer for
 * rendering.
 */
class NullBasicRasterizerFactory : IBasicRasterizerFactory {
   IRasterizer getRasterizer( BasicMaterial material ) {
      return null;
   }
}
