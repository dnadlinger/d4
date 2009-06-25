module d4.output.SdlSurface;

import derelict.sdl.sdl;
import d4.math.Color;
import d4.output.Surface;

/**
 * A Surface implementation using the SDL_Surface functionality.
 */
class SdlSurface : Surface {
public:
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
