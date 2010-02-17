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

module d4.scene.NullBasicRasterizerFactory;

import d4.renderer.IRasterizer;
import d4.scene.BasicMaterial;
import d4.scene.IBasicRasterizerFactory;

/**
 * A stub IBasicRasterizerFactory which just returns null when
 * <code>createRasterizer</code> is called. This avoids bloat if you do not
 * intend to use the <code>BasicMaterial</code>s created by e.g. a model
 * importer for rendering.
 */
class NullBasicRasterizerFactory : IBasicRasterizerFactory {
   IRasterizer createRasterizer( BasicMaterial material ) {
      return null;
   }
}
