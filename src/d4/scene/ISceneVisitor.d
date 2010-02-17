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

module d4.scene.ISceneVisitor;

import d4.scene.Mesh;
import d4.scene.Node;

/**
 * Visits the elements of a scene, invoking an arbitrary action on them.
 *
 * Look up the Vistor pattern for an explanation.
 */
interface ISceneVisitor {
   /**
    * Visits a scene Mesh.
    *
    * Params:
    *     mesh = The mesh to visit.
    */
   void visitMesh( Mesh mesh );

   /**
    * Visits a scene Node.
    *
    * Params:
    *     node = The node to visit.
    */
   void visitNode( Node node );
}
