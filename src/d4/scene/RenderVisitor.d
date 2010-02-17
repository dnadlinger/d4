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

module d4.scene.RenderVisitor;

import d4.renderer.Renderer;
import d4.scene.ISceneVisitor;
import d4.scene.Mesh;
import d4.scene.Node;

/**
 * An ISceneVisitor which renders the scene using the materials which are stored
 * with each mesh.
 */
class RenderVisitor : ISceneVisitor {
public:
   /**
    * Constructs a new instance.
    *
    * Params:
    *     renderer = The target renderer.
    */
   this( Renderer renderer ) {
      m_renderer = renderer;
   }

   void visitNode( Node node ) {
      m_renderer.worldMatrix = node.worldMatrix;
   }

   void visitMesh( Mesh mesh ) {
      m_renderer.activateMaterial( mesh.material );
      m_renderer.renderTriangleList( mesh.vertices, mesh.indices );
   }

private:
   Renderer m_renderer;
}
