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

module d4.scene.CollectPointsVisitor;

import d4.math.Vector3;
import d4.math.Matrix4;
import d4.scene.ISceneVisitor;
import d4.scene.Mesh;
import d4.scene.Node;

class CollectPointsVisitor : ISceneVisitor {
public:
   this() {
      m_result = [];
   }

   void visitNode( Node node ) {
      m_currentWorldMatrix = node.worldMatrix();
   }

   void visitMesh( Mesh mesh ) {
      foreach ( vertex; mesh.vertices ) {
         m_result ~= m_currentWorldMatrix.transformLinear( vertex.position );
      }
   }

   Vector3[] result() {
      return m_result;
   }

private:
   Vector3[] m_result;
   Matrix4 m_currentWorldMatrix;
}