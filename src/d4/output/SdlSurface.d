module d4.output.SdlSurface;

import derelict.sdl.sdl;
import d4.math.Color;
import d4.output.Surface;

class SdlSurface : Surface {
   this( SDL_Surface* sdlSurface ) {
      m_sdlSurface = sdlSurface;
      m_locked = false;
   }
   
   uint width() {
      return m_sdlSurface.w;
   }
   
   uint height() {
      return m_sdlSurface.h;
   }
   
   bool lock() {
      if ( m_locked ) {
         return false;
      }
      m_locked = true;
      return true;
   }
   
   void unlock() {
      assert( m_locked );
      SDL_Flip( m_sdlSurface );
   }
   
   Color pixel( uint x, uint y ) {
      return pixels()[ y * width() + x ];
   }
   
   void setPixel( uint x, uint y, Color color ) {
      assert( m_locked );
      pixels()[ y * width() + x ] = color;
   }
   
   void clear( Color clearColor ) {
      assert( m_locked );
      SDL_FillRect( m_sdlSurface, null, clearColor.value );
   }
   
private:
   Color* pixels() {
      return cast( Color* )m_sdlSurface.pixels;
   }

   SDL_Surface* m_sdlSurface;
   bool m_locked;
}