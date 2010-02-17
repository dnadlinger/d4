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

module d4.renderer.ZBuffer;

import d4.util.ArrayAllocation;

/**
 * A floating point z buffer
 * (intended for z values from 0 to 1, where 1 is the farthest).
 */
class ZBuffer {
   /**
    * Constructs a new z buffer with the specified resolution.
    *
    * Params:
    *     width = The buffer width.
    *     height = The buffer height.
    */
   this( uint width, uint height ) {
      m_width = width;
      m_height = height;

      allocate( m_buffer, width * height );
      clear();
   }

   /**
    * Test a z value against the currently stored one. If the new value is
    * closer, the buffer is updated accordingly.
    *
    * Params:
    *     x = The x-coordinate of the value to look up.
    *     y = The y-coordinate of the value to look up.
    *     z = The z value.
    * Returns: If the pixel should be drawn.
    */
   bool testAndUpdate( uint x, uint y, float z ) {
      assert( x < width );
      assert( y < height );

      if ( z < m_buffer[ y * width + x ] ) {
         m_buffer[ y * width + x ] = z;
         return true;
      }
      return false;
   }

   /**
    * Clears the buffer (resets all values to 1).
    */
   void clear() {
      m_buffer[] = 1f;
   }

   /**
    * The buffer width.
    */
   uint width() {
      return m_width;
   }

   /**
    * The buffer height.
    */
   uint height() {
      return m_height;
   }

   /**
    * Direct access to the buffer data. This is provided solely for
    * performance reasons, do not use it if you don't have to.
    */
   float* data() {
      return cast( float* )m_buffer;
   }

private:
   uint m_width;
   uint m_height;
   float[] m_buffer;
}
