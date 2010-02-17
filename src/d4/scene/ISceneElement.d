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

module d4.scene.ISceneElement;

import d4.scene.ISceneVisitor;

/**
 * A part of a scene which can be visited by an ISceneVisitor.
 *
 * This is a remnant of the idea to design the scene graph as a pure composite,
 * but later it showed that this would integrate badly with the already present
 * Mesh/Node classes. Because the scenes handled here are nowhere complex, this
 * half-baken composite pattern suffices.
 *
 * If I were to overhaul the design, I would definately have a new take on the
 * scene representation.
 */
interface ISceneElement {
   /**
    * Accepts an ISceneVisitor, calling its handling methods.
    *
    * Look up the Visitor pattern for details.
    */
   void accept( ISceneVisitor visitor );
}
