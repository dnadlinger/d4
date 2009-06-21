module d4.scene.BasicMaterial;

import d4.math.Color;
import d4.math.Texture;
import d4.math.Vector3;
import d4.renderer.IMaterial;
import d4.renderer.IRasterizer;
import d4.renderer.Renderer;
import d4.renderer.SolidRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.shader.LitVertexColorShader;
import d4.shader.LitSingleColorShader;
import d4.shader.LitTextureShader;
import d4.shader.SingleColorShader;
import d4.shader.TextureShader;
import d4.shader.VertexColorShader;

/**
 * A simple, straightforward IMaterial implementation.
 */
class BasicMaterial : IMaterial {
public:
   /**
    * Constructs a new material with the default settings.
    */
   this() {
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
      return m_wireframe;
   }

   /// ditto
   void vertexColors( bool vertexColors ) {
      m_vertexColors = vertexColors;
   }


   /**
    * Whether lighting is enable for the material.
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
      if ( m_wireframe ) {
         // This causes dmd to segfault:
         // return new WireframeRasterizer!( SingleColorShader, Color() )();
         return new WireframeRasterizer!( SingleColorShader )();
      }

      if ( gouraudShading ) {
         if ( m_vertexColors ) {
            if ( m_lighting ) {
               // Simply doing the following does not work:
               // return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, lightDirection )() );
               //
               // and doing this crashes gdc:
               // auto lightDirection = Vector3( 0, -1, 1 );
               // return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, lightDirection )() );
               return new SolidRasterizer!( true, LitVertexColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( true, VertexColorShader )();
            }
         } else if ( m_diffuseTexture !is null ) {
            if ( m_lighting ) {
               auto rasterizer = new SolidRasterizer!( true, LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
               rasterizer.textures = [ m_diffuseTexture ];
               return rasterizer;
            } else {
               auto rasterizer = new SolidRasterizer!( true, TextureShader )();
               rasterizer.textures = [ m_diffuseTexture ];
               return rasterizer;
            }
         } else {
            if ( m_lighting ) {
               return new SolidRasterizer!( true, LitSingleColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               // See above.
               // return new SolidRasterizer!( true, SingleColorShader, Color() )();
               return new SolidRasterizer!( true, SingleColorShader )();
            }
         }
      } else {
         if ( m_vertexColors ) {
            if ( m_lighting ) {
               return new SolidRasterizer!( false, LitVertexColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( false, VertexColorShader )();
            }
         } else if ( m_diffuseTexture !is null ) {
            if ( m_lighting ) {
               auto rasterizer = new SolidRasterizer!( false, LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
               rasterizer.textures = [ m_diffuseTexture ];
               return rasterizer;
            } else {
               auto rasterizer = new SolidRasterizer!( false, TextureShader )();
               rasterizer.textures = [ m_diffuseTexture ];
               return rasterizer;
            }
         } else {
            if ( m_lighting ) {
               return new SolidRasterizer!( false, LitSingleColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( false, SingleColorShader )();
            }
         }
      }
   }

   void prepareForRendering( Renderer renderer ) {
      // Nothing to do here – we only need our rasterizer activated.
   }

   const AMBIENT_LIGHT_LEVEL = 0.1;

   bool m_wireframe;
   bool m_gouraudShading;
   bool m_vertexColors;
   bool m_lighting;
   Texture m_diffuseTexture;
}
