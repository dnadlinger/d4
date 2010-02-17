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

module d4.scene.WireframeMaterial;

import d4.renderer.IMaterial;
import d4.renderer.IRasterizer;
import d4.renderer.Renderer;
import d4.renderer.WireframeRasterizer;
import d4.shader.SingleColorShader;

/**
 * A simple material for rendering a white unlit wireframe model.
 */
class WireframeMaterial : IMaterial {
   IRasterizer createRasterizer() {
      return new WireframeRasterizer!( SingleColorShader )();
   }

   void prepareForRendering( Renderer renderer ) {
      // Nothing to do – we just need our rasterizer activated.
   }
}
