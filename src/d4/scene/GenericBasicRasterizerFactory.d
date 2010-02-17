/*
 * Copyright © 2010, klickverbot <klickverbot@gmail.com>.
 *
 * This file is part of d4, which is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * d4 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * d4. If not, see <http://www.gnu.org/licenses/>.
 */

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
   IRasterizer createRasterizer( BasicMaterial m ) {
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
