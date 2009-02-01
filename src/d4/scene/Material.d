module d4.scene.Material;

import d4.math.Color;
import d4.math.Vector3;
import d4.renderer.IRasterizer;
import d4.renderer.SolidFlatRasterizer;
import d4.renderer.SolidGouraudRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.scene.Image;
import d4.scene.IMaterial;
import d4.shader.LitVertexColorShader;
import d4.shader.LitSingleColorShader;
import d4.shader.LitTextureShader;
import d4.shader.SingleColorShader;
import d4.shader.TextureShader;
import d4.shader.VertexColorShader;

class Material : IMaterial {
public:
   this() {
      m_wireframe = false;
      m_gouraudShading = true;
      m_vertexColors = false;
      m_lighting = false;

      m_diffuseTexture = null;
   }

   bool wireframe() {
      return m_wireframe;
   }

   void wireframe( bool wireframe ) {
      m_wireframe = wireframe;
   }

   bool gouraudShading() {
      return m_gouraudShading;
   }

   void gouraudShading( bool interpolate ) {
      m_gouraudShading = interpolate;
   }

   bool vertexColors() {
      return m_wireframe;
   }

   void vertexColors( bool vertexColors ) {
      m_vertexColors = vertexColors;
   }

   bool lighting() {
      return m_lighting;
   }

   void lighting( bool useLighting ) {
      m_lighting = useLighting;
   }

   Image diffuseTexture() {
      return m_diffuseTexture;
   }

   void diffuseTexture( Image texture ) {
      m_diffuseTexture = texture;
   }

   Image[] textures() {
      if ( m_diffuseTexture !is null ) {
         return [ m_diffuseTexture ];
      } else {
         return null;
      }
   }

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
               return new SolidGouraudRasterizer!( LitVertexColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidGouraudRasterizer!( VertexColorShader )();
            }
         } else if ( m_diffuseTexture !is null ) {
            if ( m_lighting ) {
               return new SolidGouraudRasterizer!( LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidGouraudRasterizer!( TextureShader )();
            }
         } else {
            if ( m_lighting ) {
               return new SolidGouraudRasterizer!( LitSingleColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               // See above.
               // return new SolidGouraudRasterizer!( SingleColorShader, Color() )();
               return new SolidGouraudRasterizer!( SingleColorShader )();
            }
         }
      } else {
         if ( m_vertexColors ) {
            if ( m_lighting ) {
               return new SolidFlatRasterizer!( LitVertexColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidFlatRasterizer!( VertexColorShader )();
            }
         } else if ( m_diffuseTexture !is null ) {
            if ( m_lighting ) {
               return new SolidFlatRasterizer!( LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidFlatRasterizer!( TextureShader )();
            }
         } else {
            if ( m_lighting ) {
               return new SolidFlatRasterizer!( LitSingleColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidFlatRasterizer!( SingleColorShader )();
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
