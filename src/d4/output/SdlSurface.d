module d4.output.SdlSurface;

import derelict.sdl.sdl;
import d4.math.Color;
import d4.output.Surface;

final class SdlSurface : Surface {
public:
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

   void lock() {
      if ( m_locked ) {
         throw new Exception( "Could not lock SdlSurface because it was already locked." );
      }
      m_locked = true;
   }

   void unlock() {
      assert( m_locked );
      SDL_Flip( m_sdlSurface );
      m_locked = false;
   }

   Color* pixels() {
      assert( m_locked );
      return cast( Color* )m_sdlSurface.pixels;
   }

   Color pixel( uint x, uint y ) {
      return pixels()[ y * width() + x ];
   }

   void setPixel( uint x, uint y, Color color ) {
      assert( m_locked, "The surface must be locked to set pixel values." );
      assert( 0 <= x, "The x-coordinate must not be negative." );
      assert( x < width, "The x-coordinate must not exceed surface size." );
      assert( 0 <= y, "The y-coordinate must not be negative." );
      assert( y < height, "The y-coordinate must not exceed surface size." );
      pixels()[ y * width() + x ] = color;
   }

   void clear( Color clearColor ) {
      assert( m_locked );
      SDL_FillRect( m_sdlSurface, null, clearColor.value );
   }

private:
   SDL_Surface* m_sdlSurface;
   bool m_locked;
}