module d4.scene.Material;

import d4.math.Color;
import d4.math.Vector3;
import d4.renderer.IRasterizer;
import d4.renderer.SolidRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.scene.Image;
import d4.scene.IMaterial;
import d4.shader.LitVertexColorShader;
import d4.shader.LitSingleColorShader;
import d4.shader.LitTextureShader;
import d4.shader.SingleColorShader;
import d4.shader.TextureShader;
import d4.shader.VertexColorShader;

/**
 * A simple, straightforward IMaterial implementation.
 */
class Material : IMaterial {
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
   Image diffuseTexture() {
      return m_diffuseTexture;
   }

   /// ditto
   void diffuseTexture( Image texture ) {
      m_diffuseTexture = texture;
   }

   /**
    * The textures the material is using (just the diffuse texture if any, null
    * otherwise).
    */
   Image[] textures() {
      if ( m_diffuseTexture !is null ) {
         return [ m_diffuseTexture ];
      } else {
         return null;
      }
   }

   /**
    * Whether the material uses gouraud shading to interpolate between the
    * vertex variables.
    */
   IRasterizer createRasterizer() {
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
               return new SolidRasterizer!( true, LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( true, TextureShader )();
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
               return new SolidRasterizer!( false, LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( false, TextureShader )();
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
   
   const AMBIENT_LIGHT_LEVEL = 0.1;

   bool m_wireframe;
   bool m_gouraudShading;
   bool m_vertexColors;
   bool m_lighting;
   Image m_diffuseTexture;
}
