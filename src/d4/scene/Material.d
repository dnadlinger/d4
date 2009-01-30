module d4.scene.Material;

import d4.math.Vector3;
import d4.renderer.IRasterizer;
import d4.renderer.SolidGouraudRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.scene.Image;
import d4.scene.IMaterial;
import d4.shader.DefaultShader;
import d4.shader.ColorGouraudShader;
import d4.shader.ColorShader;
import d4.shader.TextureGouraudShader;

class Material : IMaterial {
public:
   this() {
      m_wireframe = false;
      m_useColor = false;
      m_gouraudLighting = false;

      m_diffuseTexture = null;
   }

   bool wireframe() {
      return m_wireframe;
   }

   void wireframe( bool wireframe ) {
      m_wireframe = wireframe;
   }

   bool useColor() {
      return m_wireframe;
   }

   void useColor( bool useColor ) {
      m_useColor = useColor;
   }

   bool gouraudLighting() {
      return m_gouraudLighting;
   }

   void gouraudLighting( bool useGouraudLighting ) {
      m_gouraudLighting = useGouraudLighting;
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
         return new WireframeRasterizer!( DefaultShader )();
      }

      if ( m_useColor ) {
         if ( m_gouraudLighting ) {
            // Simply doing the following does not work:
            // return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, lightDirection )() );
            // 
            // and doing this crashes gdc:
            // auto lightDirection = Vector3( 0, -1, 1 );
            // return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, lightDirection )() );
            return new SolidGouraudRasterizer!( ColorGouraudShader, 0.2, 1, -1, -1 )();
         } else {
            return new SolidGouraudRasterizer!( ColorShader )();
         }
      } else if ( m_diffuseTexture !is null ) {
         if ( m_gouraudLighting ) {
            return new SolidGouraudRasterizer!( TextureGouraudShader, 0.2, 1, -1, -1 )();
         } else {
            throw new Exception( "Texturing without gouraud lighting is currently not supported." );
         }
      } else {
         if ( m_gouraudLighting ) {
            throw new Exception( "Using gouraud lighting without coloring is currently not supported." );
         } else {
            return new SolidGouraudRasterizer!( DefaultShader )();
         }
      }
   }

   bool m_wireframe;
   bool m_useColor;
   bool m_gouraudLighting;

   Image m_diffuseTexture;
}
