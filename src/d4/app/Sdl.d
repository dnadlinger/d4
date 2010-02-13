module d4.app.Sdl;

import tango.io.Stdout;
import tango.stdc.stringz : fromStringz, toStringz;
import tango.text.convert.Integer : toInt;
import derelict.sdl.sdl;
import d4.app.Key;
import d4.app.Option;
import d4.math.Color;
import d4.output.Surface;
import d4.output.SdlSurface;

/**
 * Implements the parts of Application for which SDL can be used.
 */
abstract class Sdl( alias Base ) : Base {
public:
   this( char[][] args ) {
      super( args );

      // Default values for the options accessible via the command line.
      m_screenWidth = 800;
      m_screenHeight = 500;
      m_videoFlags = SDL_HWSURFACE | SDL_DOUBLEBUF;
   }

protected:
   abstract override void init() {
      super.init();

      Stdout( "Loading SDL library... " );
      DerelictSDL.load();
      Stdout( "done." ).newline;
      m_sdlLoaded = true;

      initVideo();

      SDL_WM_SetCaption( toStringz( "d4" ), null );
   }

   abstract override void shutdown() {
      super.shutdown();

      destroyVideo();

      if ( m_sdlLoaded ) {
         SDL_Quit();
         DerelictSDL.unload();
      }
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

   override void handleSwitchArgument( char[] name ) {
      switch ( name ) {
         case "fullscreen":
            m_videoFlags |= SDL_FULLSCREEN;
            break;
         default:
            super.handleSwitchArgument( name );
            break;
      }
   }

   override void handleValueArgument( char[] name, char[] value ) {
      switch ( name ) {
         case "width":
            int width;
            try {
               width = toInt( value );
            } catch ( Exception e ) {
               throw new Exception( "Invalid value passed for screen width." );
            }
            if ( ( width < MIN_SCREEN_WIDTH ) || ( width > MAX_SCREEN_WIDTH ) ) {
               throw new Exception( "Specified screen width is out of bounds." );
            }
            m_screenWidth = width;
            break;
         case "height":
            int height;
            try {
               height = toInt( value );
            } catch ( Exception e ) {
               throw new Exception( "Invalid value passed for screen width." );
            }
            if ( ( height < MIN_SCREEN_HEIGHT ) || ( height > MAX_SCREEN_HEIGHT ) ) {
               throw new Exception( "Specified screen width is out of bounds." );
            }
            m_screenHeight = height;
            break;
         default:
            super.handleValueArgument( name, value );
            break;
      }
   }

   override Option[] helpOptions() {
      return super.helpOptions() ~ [
         new Option( "fullscreen", "Use fullscreen mode." ),
         new Option( "width=SIZE", "Sets the output width to SIZE pixels." ),
         new Option( "height=SIZE", "Sets the output height to SIZE pixels." )
      ];
   }

private:
   void initVideo() {
      Stdout( "Initializing SDL video subsystem... " );

      if ( SDL_InitSubSystem( SDL_INIT_VIDEO ) != 0 ) {
         throw new Exception( "Could not initialize SDL video subsystem: " ~
            fromStringz( SDL_GetError() ) );
      }

      SDL_Surface* surface = SDL_SetVideoMode(
         m_screenWidth,
         m_screenHeight,
         BITS_PER_PIXEL,
         m_videoFlags
      );

      if ( !surface ) {
         throw new Exception( "Could not set SDL video mode: "
            ~ fromStringz( SDL_GetError() ) );
      }

      if ( surface.format.BitsPerPixel != BITS_PER_PIXEL ) {
         throw new Exception( "Could not initialze SDL video surface " ~
            "in the correct bit depth." );
      }

      if ( ( surface.format.Rmask != Color.RED_MASK ) ||
         ( surface.format.Gmask != Color.GREEN_MASK ) ||
         ( surface.format.Bmask != Color.BLUE_MASK ) ) {
         Stdout.format(
            "Wrong screen surface format: " ~
               "{} bits, rmask: {}, gmask: {}, bmask: {}, amask: {}",
            surface.format.BitsPerPixel,
            surface.format.Rmask,
            surface.format.Gmask,
            surface.format.Bmask,
            surface.format.Amask
         ).newline;
         throw new Exception( "SDL video surface pixel format mismatch." );
      }

      m_videoInitialized = true;

      m_screen = new SdlSurface( surface, SDL_MUSTLOCK( surface ) );
      Stdout( "done." ).newline;
   }

   void destroyVideo() {
      // Make sure that we quit the SDL video subsystem only if it is
      // initialized, SDL segfaults otherwise.
      if ( m_videoInitialized ) {
         SDL_QuitSubSystem( SDL_INIT_VIDEO );
      }

      m_videoInitialized = false;
   }

   uint m_screenWidth;
   const uint MIN_SCREEN_WIDTH = 1;
   const uint MAX_SCREEN_WIDTH = 2000;

   uint m_screenHeight;
   const uint MIN_SCREEN_HEIGHT = 1;
   const uint MAX_SCREEN_HEIGHT = 1500;

   uint m_videoFlags;
   // TODO: Also make bit depth configurable.
   const uint BITS_PER_PIXEL = 32;

   SdlSurface m_screen;
   bool m_sdlLoaded;
   bool m_videoInitialized;
}
