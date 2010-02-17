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

module d4.scene.ColoredNormalVertex;

import d4.math.Color;
import d4.scene.NormalVertex;

/**
 * A vertex consisting of a position vector, a vertex color and a normal vector.
 */
class ColoredNormalVertex : NormalVertex {
public:
   /**
    * The vertex color.
    */
   Color color() {
      return m_color;
   }

   /// ditto
   void color( Color color ) {
      m_color = color;
   }
private:
   Color m_color;
}
