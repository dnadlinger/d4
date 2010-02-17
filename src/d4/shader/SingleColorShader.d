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

/**
 * A shader which simply paints all objects white.
 *
 * Vertex types: any.
 */
module d4.shader.SingleColorShader;

/*
 * A command like this:
 * new SolidGouraudRasterizer!( SingleColorShader, Color() )();
 * will somehow cause dmd to abort with a segfault. Just removed the color
 * parameter for now.
 *
 * The intended declaration was:
 * template SingleColorShader( alias surfaceColor )
 */
template SingleColorShader() {
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      position = worldViewProjMatrix * vertex.position;
   }

   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255 );
   }

   struct VertexVariables {}
}
