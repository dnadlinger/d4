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

module d4.scene.TexturedNormalVertex;

import d4.math.Vector2;
import d4.scene.NormalVertex;

/**
 * A vertex consisting of a position vector, a normal vector, and a pair of
 * texture coordinates.
 *
 * This is the standard for lit, textured models.
 */
class TexturedNormalVertex : NormalVertex {
public:
   /**
    * The vertex texture coordinates.
    */
   Vector2 texCoords() {
      return m_texCoords;
   }

   /// ditto
   void texCoords( Vector2 texCoords ) {
      m_texCoords = texCoords;
   }

private:
   Vector2 m_texCoords;
}
