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
 * A shader which applies a single diffuse texture.
 *
 * Vertex type: TexturedNormalVertex.
 */
module d4.shader.TextureShader;

template TextureShader() {
   import d4.scene.TexturedNormalVertex;

   void vertexShader( in Vertex vertex,
      out Vector4 position, out VertexVariables variables ) {

      // TODO: Allow other vertex types.
      // This is a direct consequence of the design flaw mentioned in the
      // documentation for Vertex.
      TexturedNormalVertex tnv = cast( TexturedNormalVertex ) vertex;
      assert( tnv !is null );

      position = worldViewProjMatrix * tnv.position;
      variables.texCoords = tnv.texCoords;
   }

   Color pixelShader( VertexVariables variables ) {
      return readTexture!( true, true )( 0, variables.texCoords );
   }

   struct VertexVariables {
      Vector2 texCoords;
   }
}
