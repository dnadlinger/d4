module d4.output.SdlSurface;

import derelict.sdl.sdl;
import d4.math.Color;
import d4.output.Surface;

/**
 * A Surface implementation using the SDL_Surface functionality.
 */
class SdlSurface : Surface {
public:
   this( SDL_Surface* sdlSurface ) {
      m_sdlSurface = sdlSurface;
   }

   override uint width() {
      return m_sdlSurface.w;
   }

   override uint height() {
      return m_sdlSurface.h;
   }

   override void unlock() {
      super.unlock();
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
}