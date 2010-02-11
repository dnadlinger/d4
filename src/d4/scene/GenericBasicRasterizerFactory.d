module d4.scene.GenericBasicRasterizerFactory;

import d4.renderer.IRasterizer;
import d4.renderer.SolidRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.scene.BasicMaterial;
import d4.scene.IBasicRasterizerFactory;
import d4.shader.LitVertexColorShader;
import d4.shader.LitSingleColorShader;
import d4.shader.LitTextureShader;
import d4.shader.SingleColorShader;
import d4.shader.TextureShader;
import d4.shader.VertexColorShader;

/**
 * A IBasicRasterizerFactory which takes the gouradShading, vertexColors,
 * lighting and diffuseTexture material properties into account to choose from
 * a number of generic default shaders.
 *
 * If lighting is enabled, a single directional light source pointing to
 * (1, -1, -1) is used.
 */
class GenericBasicRasterizerFactory : IBasicRasterizerFactory {
   IRasterizer getRasterizer( BasicMaterial m ) {
      if ( m.wireframe ) {
         // This causes dmd to segfault:
         // return new WireframeRasterizer!( SingleColorShader, Color() )();
         return new WireframeRasterizer!( SingleColorShader )();
      }

      if ( m.gouraudShading ) {
         if ( m.vertexColors ) {
            if ( m.lighting ) {
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
         } else if ( m.diffuseTexture !is null ) {
            if ( m.lighting ) {
               auto rasterizer = new SolidRasterizer!( true, LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
               rasterizer.textures = [ m.diffuseTexture ];
               return rasterizer;
            } else {
               auto rasterizer = new SolidRasterizer!( true, TextureShader )();
               rasterizer.textures = [ m.diffuseTexture ];
               return rasterizer;
            }
         } else {
            if ( m.lighting ) {
               return new SolidRasterizer!( true, LitSingleColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               // See above.
               // return new SolidRasterizer!( true, SingleColorShader, Color() )();
               return new SolidRasterizer!( true, SingleColorShader )();
            }
         }
      } else {
         if ( m.vertexColors ) {
            if ( m.lighting ) {
               return new SolidRasterizer!( false, LitVertexColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( false, VertexColorShader )();
            }
         } else if ( m.diffuseTexture !is null ) {
            if ( m.lighting ) {
               auto rasterizer = new SolidRasterizer!( false, LitTextureShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
               rasterizer.textures = [ m.diffuseTexture ];
               return rasterizer;
            } else {
               auto rasterizer = new SolidRasterizer!( false, TextureShader )();
               rasterizer.textures = [ m.diffuseTexture ];
               return rasterizer;
            }
         } else {
            if ( m.lighting ) {
               return new SolidRasterizer!( false, LitSingleColorShader, AMBIENT_LIGHT_LEVEL, 1, -1, -1 )();
            } else {
               return new SolidRasterizer!( false, SingleColorShader )();
            }
         }
      }
   }

   const AMBIENT_LIGHT_LEVEL = 0.1;
}
