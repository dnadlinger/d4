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

module d4.scene.NormalVertex;

import d4.math.Vector3;
import d4.scene.Vertex;

class NormalVertex : Vertex {
public:
   this( Vector3 position = Vector3(), Vector3 normal = Vector3() ) {
      super( position );
      m_normal = normal;
   }

   /**
    * The vertex normal vector.
    */
   Vector3 normal() {
      return m_normal;
   }

   /// ditto
   void normal( Vector3 normal ) {
      m_normal = normal;
   }

private:
   Vector3 m_normal;
}
