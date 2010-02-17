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

module d4.output.Surface;

import d4.math.Color;

/**
 * An output surface (screen, texture, ...).
 */
abstract class Surface {
   /**
    * Locks the surface.
    *
    * The surface has to be locked in order to alter it. If it is already
    * locked, an exception is thrown.
    */
   void lock() {
      if ( m_locked ) {
         throw new Exception(
            "Could not lock the Surface because it was already locked." );
      }
      m_locked = true;
   }

   /**
    * Unlocks the surface again.
    *
    * Always unlock the surface after modifying it.
    */
   void unlock() {
      assert( m_locked );
      m_locked = false;
   }

   /**
    * The width (in pixels) of the surface.
    * Returns: The width.
    */
   abstract uint width();

   /**
    * The height (in pixels) of the surface.
    * Returns: The height.
    */
   abstract uint height();

   /**
    * Returns a pointer to the pixel data through which it can be directly
    * modified.
    *
    * Use this only where performance is critical, because you loose all safety
    * checks.
    *
    * Returns: A pointer to the pixel data.
    */
   abstract Color* pixels();

   /**
    * Returns the color of the pixel at the specified coordinates.
    *
    * Params:
    *    x = The x-coordinate of the pixel (zero-based).
    *    y = The y-coordinate of the pixel (zero-based).
    * Returns: The color of the pixel.
    */
   Color pixel( uint x, uint y ) {
      assert( 0 <= x, "The x-coordinate must not be negative." );
      assert( x < width(), "The x-coordinate must not exceed surface size." );
      assert( 0 <= y, "The y-coordinate must not be negative." );
      assert( y < height(), "The y-coordinate must not exceed surface size." );

      return pixels()[ y * width() + x ];
   }

   /**
    * Sets the pixel at the specified coordinates to the specified color.
    *
    * Params:
    *    x = The x-coordinate of the pixel (zero-based).
    *    y = The y-coordinate of the pixel (zero-based).
    *    color = The new color of the pixel.
    */
   void setPixel( uint x, uint y, Color color ) {
      assert( m_locked, "The surface must be locked to set pixel values." );
      assert( 0 <= x, "The x-coordinate must not be negative." );
      assert( x < width(), "The x-coordinate must not exceed surface size." );
      assert( 0 <= y, "The y-coordinate must not be negative." );
      assert( y < height(), "The y-coordinate must not exceed surface size." );

      pixels()[ y * width() + x ] = color;
   }

   /**
    * Fills all pixels of the surface with the specified color.
    *
    * Params:
    *    clearColor = The color to fill the surface with.
    */
   void clear( Color clearColor ) {
      assert( m_locked );

      Color* currentPixel = pixels();
      uint pixelCount = width() * height();
      while ( pixelCount-- ) {
         (*currentPixel) = clearColor;
         ++currentPixel;
      }
   }

protected:
   bool m_locked;
}
