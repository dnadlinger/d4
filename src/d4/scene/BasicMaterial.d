module d4.scene.BasicMaterial;

import d4.math.Color;
import d4.math.Texture;
import d4.math.Vector3;
import d4.renderer.IMaterial;
import d4.renderer.IRasterizer;
import d4.renderer.Renderer;
import d4.scene.IBasicRasterizerFactory;

/**
 * A simple IMaterial implementation.
 *
 * The only purpose of delegating the actual rasterizer creation to a seperate
 * instance (IBasicRasterizerFactory) is to avoid instancing RasterizerBase
 * several times for the generic default shaders if they are not nedeed (and so
 * bloating the resulting binary), but BasicMaterial is used (e.g. in the model
 * loader).
 */
class BasicMaterial : IMaterial {
public:
   /**
    * Constructs a new material with the default settings.
    */
   this( IBasicRasterizerFactory rasterizerFactory ) {
      m_rasterizerFactory = rasterizerFactory;

      m_wireframe = false;
      m_gouraudShading = true;
      m_vertexColors = false;
      m_lighting = false;

      m_diffuseTexture = null;
   }

   /**
    * Whether the material is drawn as a wireframe or solid.
    */
   bool wireframe() {
      return m_wireframe;
   }

   /// ditto
   void wireframe( bool wireframe ) {
      m_wireframe = wireframe;
   }

   /**
    * Whether the material uses gouraud shading to interpolate between the
    * vertex variables.
    */
   bool gouraudShading() {
      return m_gouraudShading;
   }

   /// ditto
   void gouraudShading( bool interpolate ) {
      m_gouraudShading = interpolate;
   }

   /**
    * Whether vertex colors should be respected.
    */
   bool vertexColors() {
      return m_vertexColors;
   }

   /// ditto
   void vertexColors( bool vertexColors ) {
      m_vertexColors = vertexColors;
   }


   /**
    * Whether lighting is enabled for the material.
    */
   bool lighting() {
      return m_lighting;
   }

   /// ditto
   void lighting( bool useLighting ) {
      m_lighting = useLighting;
   }

   /**
    * The diffuse texture for the material (null if none).
    */
   Texture diffuseTexture() {
      return m_diffuseTexture;
   }

   /// ditto
   void diffuseTexture( Texture texture ) {
      m_diffuseTexture = texture;
   }

   bool usesTextures() {
      return ( m_diffuseTexture !is null );
   }

  /**
   * Returns a reference to an IRasterizer which is configured
   * to draw the material.
   */
   IRasterizer getRasterizer() {
      return m_rasterizerFactory.getRasterizer( this );
   }

   void prepareForRendering( Renderer renderer ) {
      // Nothing to do here – we only need our rasterizer activated.
   }

private:
   IBasicRasterizerFactory m_rasterizerFactory;

   bool m_wireframe;
   bool m_gouraudShading;
   bool m_vertexColors;
   bool m_lighting;
   Texture m_diffuseTexture;
}
