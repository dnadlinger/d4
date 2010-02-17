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
 *
 * The chosen approach of attaching further data by subclassing has turned out
 * to be a major design flaw since it is very inflexible, and it does not really
 * belong into the »scene« package. A really clean solution has yet to be found,
 * however, – the main problem here is the incompatibilty of
 * the OOP-based scene graph system and the template-based renderer.
 *
 * Until then, this solution does not kill performance while allowing for some,
 * albeit very limited, flexibilty.
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
