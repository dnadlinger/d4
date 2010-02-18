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

module d4.scene.IBasicRasterizerFactory;

import d4.math.Texture;
import d4.renderer.IRasterizer;

/**
 * Serves as an extra layer of indirection between BasicMaterial and the
 * creation of rasterizers for it.
 *
 * The rationale behind this is to avoid instancing RasterizerBase several times
 * for the generic default shaders if they are not nedeed (and so bloating the
 * resulting binary), but BasicMaterial is used (e.g. in the model loader).
 */
interface IBasicRasterizerFactory {
   /**
    * Creates a rasterizer with the given properties.
    *
    * Params:
    *    wireframe = Whether wireframe mode is used.
    *    lighting = Whether lighting is used.
    *    gouraudShading = Whether Gouraud shading is used.
    *    vertexColors = Whether vertex colors are used.
    *    diffuseTexture = The diffuse color textur, null for none.
    * Returns: The new rasterizer.
    */
   IRasterizer createRasterizer( bool wireframe, bool lighting,
      bool gouraudShading, bool vertexColors, Texture diffuseTexture );
}
