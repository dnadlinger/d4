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
 * A shader which simply uses the vertex colors to determine the pixel colors.
 *
 * Vertex type: ColoredVertex.
 */
module d4.shader.VertexColorShader;

// Apparently, each vertex type must be included once in the global space for
// the mixin stuff to work. Import it here.
import d4.scene.ColoredVertex;

template VertexColorShader() {
   import d4.scene.ColoredVertex;

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredVertex cv = cast( ColoredVertex ) vertex;
      assert( cv !is null );

      position = worldViewProjMatrix * cv.position;
      variables.color = colorToVector3( cv.color );
   }

   Color pixelShader( VertexVariables variables ) {
      return vector3ToColor( variables.color );
   }

   struct VertexVariables {
      Vector3 color;
   }
}
