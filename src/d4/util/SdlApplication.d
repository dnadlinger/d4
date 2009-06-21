module d4.util.SdlApplication;

import tango.io.Stdout;
import tango.stdc.stringz : fromStringz, toStringz;
import derelict.sdl.sdl;
import d4.math.Color;
import d4.output.Surface;
import d4.output.SdlSurface;
import d4.util.Application;
import d4.util.Key;

/**
 * Implements the parts of Application for which SDL can be used.
 */
abstract class SdlApplication : Application {
protected:
   abstract override void init() {
      super.init();

      Stdout( "Loading SDL library... " );
      DerelictSDL.load();
      Stdout( "done." ).newline;

      initVideo();

      SDL_WM_SetCaption( toStringz( "d4" ), null );
   }

   abstract override void shutdown() {
      super.shutdown();

      destroyVideo();
      SDL_Quit();
      DerelictSDL.unload();
   }

   final override uint currentTicks() {
      return SDL_GetTicks();
   }

   final override Surface screen() {
      return m_screen;
   }

   final override void processEvents() {
      SDL_Event event;

      while ( SDL_PollEvent( &event ) ) {
         switch ( event.type ) {
            case SDL_QUIT:
               exit();
               break;

            case SDL_KEYDOWN:
               handleKeyDown( cast( Key )event.key.keysym.sym );
               break;

            case SDL_KEYUP:
               handleKeyUp( cast( Key )event.key.keysym.sym );
               break;

            default:
               break;
         }
      }
   }

private:
   void initVideo() {
      Stdout( "Initializing SDL video subsystem... " );

      // TODO: Make configurable.
      const uint screenWidth = 800;
      const uint screenHeight = 500;
      const uint videoFlags = SDL_HWSURFACE | SDL_DOUBLEBUF;
      const uint bitsPerPixel = 32;

      if ( SDL_InitSubSystem( SDL_INIT_VIDEO ) != 0 ) {
         throw new Exception( "Could not initialize SDL video subsystem: " ~ fromStringz( SDL_GetError() ) );
      }

      SDL_Surface* surface = SDL_SetVideoMode( screenWidth, screenHeight, bitsPerPixel, videoFlags );
      if ( !surface ) {
         throw new Exception( "Could not set SDL video mode: " ~ fromStringz( SDL_GetError() ) );
      }

      if ( surface.format.BitsPerPixel != bitsPerPixel ) {
         throw new Exception( "Could not initialze SDL video surface in the correct bit depth." );
      }

      if ( ( surface.format.Rmask != Color.RED_MASK ) ||
         ( surface.format.Gmask != Color.GREEN_MASK ) ||
         ( surface.format.Bmask != Color.BLUE_MASK ) ) {
         Stdout.format(
            "Wrong screen surface format: {} bits, rmask: {}, gmask: {}, bmask: {}, amask: {}",
            surface.format.BitsPerPixel, surface.format.Rmask, surface.format.Gmask,
            surface.format.Bmask, surface.format.Amask ).newline;
         throw new Exception( "SDL video surface pixel format mismatch." );
      }

      if ( SDL_MUSTLOCK( surface ) ) {
         throw new Exception( "SDL video surface has to be locked, which is not implemeted yet." );
      }

      m_screen = new SdlSurface( surface );
      Stdout( "done." ).newline;
   }

   void destroyVideo() {
      SDL_QuitSubSystem( SDL_INIT_VIDEO );
   }

   SdlSurface m_screen;
}
