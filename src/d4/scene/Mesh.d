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

module d4.scene.Mesh;

import d4.renderer.IMaterial;
import d4.scene.ISceneElement;
import d4.scene.ISceneVisitor;
import d4.scene.Vertex;

/**
 * A mesh consisting of an indexed triangle list and a material used for
 * rendering it.
 */
class Mesh : ISceneElement {
public:
   void accept( ISceneVisitor visitor ) {
      visitor.visitMesh( this );
   }

   /**
    * The vertex buffer of the mesh.
    */
   Vertex[] vertices;

   /**
    * The incides for the vertex buffer.
    *
    * The size of this must always be dividable by three, because there are
    * only completed trinagles allowed.
    */
   size_t[] indices;

   /**
    * The material to use for the mesh.
    */
   IMaterial material;
}
