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

module d4.scene.Vertex;

import d4.math.Vector3;

/**
 * A basic vertex consisting only of a (three-dimensional) position vector.
 */
class Vertex {
   /**
    * Constructs a new vertex instance.
    *
    * Params:
    *     position = The vertex position.
    */
   this( Vector3 position = Vector3() ) {
      m_position = position;
   }

   /**
    * The vertex position.
    */
   Vector3 position() {
      return m_position;
   }

   /// ditto
   void position( Vector3 position ) {
      m_position = position;
   }

private:
   Vector3 m_position;
}
