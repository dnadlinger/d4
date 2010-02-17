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

module d4.output.SdlSurface;

import derelict.sdl.sdl;
import d4.math.Color;
import d4.output.Surface;

/**
 * A Surface implementation using the SDL_Surface functionality.
 */
class SdlSurface : Surface {
public:
   /**
    * Constructs a new instance.
    *
    * Params:
    *    sdlSurface = A pointer to the target SDL surface structure.
    *    mustLock = Whether the SDL surface must be locked before accessing it.
    */
   this( SDL_Surface* sdlSurface, bool mustLock ) {
      m_sdlSurface = sdlSurface;
      m_mustLock = mustLock;
   }

   override uint width() {
      return m_sdlSurface.w;
   }

   override uint height() {
      return m_sdlSurface.h;
   }

   override void lock() {
      super.lock();
      if ( m_mustLock ) {
         SDL_LockSurface( m_sdlSurface );
      }
   }

   override void unlock() {
      super.unlock();
      if ( m_mustLock ) {
         SDL_UnlockSurface( m_sdlSurface );
      }
      SDL_Flip( m_sdlSurface );
   }

   override Color* pixels() {
      assert( m_locked );
      return cast( Color* )m_sdlSurface.pixels;
   }

   override void clear( Color clearColor ) {
      assert( m_locked );
      SDL_FillRect( m_sdlSurface, null, clearColor.value );
   }

private:
   SDL_Surface* m_sdlSurface;
   bool m_mustLock;
}
