module d4.util.Application;

import tango.core.Array;
import tango.io.Stdout;
import tango.math.Math;
import Integer = tango.text.convert.Integer;
import tango.text.Util;
import d4.output.Surface;
import d4.util.Option;
import d4.util.Key;

/**
 * Provides basic functionality for all kinds of 3d applications
 * (event loop, key handling, ...).
 */
abstract class Application {
public:
   /**
    * Basic constructor.
    *
    * Params:
    *    args = The command line arguments passed to the application. Expects
    *       the first value to be the name of the application.
    */
   this( char[][] args ) {
      m_args = args;
   }

   /**
    * Executes the application main (event) loop.
    *
    * This function returns when the application has been closed.
    */
   final void run() {
      // Parse the command line arguments. We cannot do this in the
      // constructor, as this would require the subclasses to set up the
      // default values for the properties modifyable via the command line
      // *before* the super()-call, which is rather uncommon.
      parseCommandLineArgs();

      // Check here if the application is already finished to avoid
      // unnecessarily entering the main loop.
      if ( m_appFinished ) {
         return;
      }

      init();

      m_totalTicksPassed = 0;
      m_fpsSamplingDuration = 0;
      m_framesInSample = 0;

      Stdout.newline;
      Stdout( "Entering main loop." ).newline;

      // The tick count when the last frame started to measure the elapsed time.
      uint lastStartTicks = currentTicks();

      // The duration of the last frame to detect "slow" frames. Initializing
      // with a second lacking a better value (there have been no frames yet).
      uint lastDeltaTicks = 1000;

      while ( !m_appFinished ) {
         // Calculate the time elapsed since the last frame start.
         uint frameStartTicks = currentTicks();
         uint deltaTicks = frameStartTicks - lastStartTicks;
         lastStartTicks = frameStartTicks;

         // Keep track of the total time the app is running.
         m_totalTicksPassed += deltaTicks;

         // Average the framerate over FPS_UPDATE_INTERVAL.
         m_fpsSamplingDuration += deltaTicks;
         ++m_framesInSample;
         if ( m_fpsSamplingDuration > FPS_UPDATE_INTERVAL ) {
            // m_fpsSamplingDuration is measured in ticks, hence the
            // factor 1000 to convert the result to frames per second.
            m_fps = ( m_framesInSample * 1000.f ) / m_fpsSamplingDuration;

            Stdout.format( "{} frames per second", m_fps ).newline;

            m_fpsSamplingDuration = 0;
            m_framesInSample = 0;
         }

         // Process any events such as user input.
         processEvents();

         // Update and render the scene.
         render( deltaTicks / 1000.f );
      }

      shutdown();
   }

   ~this() {
      // Make sure that shutdown() is called even on irregular program
      // termination to make sure that e.g the video subsystem is shut down
      // correctly.
      if ( !m_appFinished ) {
         shutdown();
      }
   }

protected:
   /*
    * Functions to overwrite in subclasses with the concrete implementation.
    */

   /**
    * Initializes the application.
    *
    * Call the base class implementation in overwritten implementations.
    */
   abstract void init() {};

   /**
    * Ticks the world and renders the scene.
    *
    * Call the base class implementation in overwritten implementations.
    *
    * Params:
    *     deltaTime = The time which elapsed since the last frame.
    */
   abstract void render( float deltaTime ) {};

   /**
    * Shuts the application down.
    *
    * Call the base class implementation in overwritten implementations.
    */
   abstract void shutdown() {};


   /**
    * Returns: The surface whose contents are displayed on the screen.
    */
   abstract Surface screen();

   /**
    * Returns: The current time in milliseconds (only use it for relative
    * calculations).
    */
   abstract uint currentTicks();

   /**
    * Processes all events in some external event queue (OS, ...).
    */
   abstract void processEvents();


   /*
    * Internal functionality provided to subclasses.
    */

   /**
    * Causes the application to exit after the current frame is finished.
    */
   final void exit() {
      m_appFinished = true;
   }

   /**
    * Returns: The total amount of time the event loop was running (in milliseconds).
    */
   final uint totalTicksPassed() {
      return m_totalTicksPassed;
   }

   /**
    * Returns: The total amount of time the event loop was running (in seconds).
    */
   final float totalTimePassed() {
      return m_totalTicksPassed / 1000.f;
   }

   /**
    * Tests whether a key is currently pressed.
    *
    * Params:
    *     key = The questionable key.
    * Returns: true if the key is pressed, false if it isn't.
    */
   final bool isKeyDown( Key key ) {
      return m_keyDownList[ key ];
   }

   /**
    * Returns: The current (averaged) fps.
    */
   final float fps() {
      return m_fps;
   }


   /*
    * Argument handling
    */

   /**
    * Handles a »switch« command line argument, a command line option without
    * a value (e.g. »--enable-xyz«).
    *
    * Subclasses are expected to overwrite this to register command line
    * switches and to call the parent class implementation if they did not
    * process the switch.
    *
    * Params:
    *    name = The name of the command line switch (without the »-« or »--«
    *       prefix).
    */
   void handleSwitchArgument( char[] name ) {
      switch ( name ) {
         case "help":
            printHelp();
            m_appFinished = true;
            break;
         default:
            printHelp();
            throw new Exception( "Invalid argument: " ~ name );
      }
   }

   /**
    * Handles a value command line argument, a command line option which
    * includes an equals sign for value assignment (e.g. »--value=10«).
    *
    * Subclasses are expected to overwrite this to register value arguments
    * switches and to call the parent class implementation if they did not
    * process the argument.
    *
    * Params:
    *    name = The name of the command line argument (without the »-« or »--«
    *       prefix).
    *    value = The value of the argument (without the »=« sign).
    */
   void handleValueArgument( char[] name, char[] value ) {
      printHelp();
      throw new Exception( "Invalid argument: " ~ name );
   }

   /**
    * Handles unnamed command line arguments, arguments without a preceding »-«
    * or »--« (e.g. a path).
    *
    * Subclasses are expected to overwrite this to react to unnamed arguments
    * and to call the parent class implementation with any arguments they did
    * not process.
    *
    * Params:
    *    values = All unnamed arguments in the command line (which were not
    *       processed yet by a subclass).
    */
   void handleUnnamedArguments( char[][] values ) {
      if ( values.length > 0 ) {
         printHelp();
         throw new Exception( "Too many arguments!" );
      }
   }

   /**
    * Returns: A short description of the application which is part of the help
    *    text.
    */
   abstract char[] helpSummary();

   /**
    * Returns: A short command line usage hint which is part of the help text.
    */
   abstract char[] helpUsage();

   /**
    * Returns: A description of all possible command line options which is part
    *    of the help text.
    */
   Option[] helpOptions() {
      return [
        new Option( "help", "Display this help text and exit." )
      ];
   }

   /**
    * Prints a short help text to the standard output, consisting of the summary,
    * usage information and description of the available options.
    */
   void printHelp() {
      Stdout( helpSummary() ).newline;
      Stdout.newline;

      Stdout( "Usage: " )( m_args[ 0 ] )( " " )( helpUsage() ).newline;
      Stdout.newline;

      Stdout( "Options: " ).newline;
      Option[] options = helpOptions();
      options.sort();

      uint maxLength = 0;
      foreach ( option; options ) {
         maxLength = max( maxLength, option.name.length );
      }

      foreach ( option; options ) {
         Stdout.format( " --{0,-" ~ Integer.toString( maxLength ) ~ "} – {1}",
            option.name, option.description ).newline;
      }
      Stdout.newline;
   }

   /*
    * Callback functions for the key tracking system.
    */
   void handleKeyDown( Key key ) {
      m_keyDownList[ key ] = true;
   }

   void handleKeyUp( Key key ) {
      m_keyDownList[ key ] = false;

      if ( key == Key.ESCAPE ) {
         exit();
      }
   }

private:
   void parseCommandLineArgs() {
      char[][] unnamedArguments;

      foreach ( argument; m_args[ 1..$ ] ) {
         if ( locatePattern( argument, "-" ) == 0 ) {
            // If the argument is a »named« option (prefixed with - or --),
            // call handleValueArgument if a value was passed (the string
            // contains an equals-sign) or handleSwitchArgument otherwise.
            char[] stripped = stripl( argument, '-' );

            char[] value;
            char[] name = head( stripped, "=", value );

            if ( value is null ) {
               handleSwitchArgument( name );
            } else {
               handleValueArgument( name, value );
            }
         } else {
            // The argument is unnamed (e.g. a filename).
            unnamedArguments ~= argument;
         }
      }

      handleUnnamedArguments( unnamedArguments );
   }

   char[][] m_args;

   uint m_totalTicksPassed;
   bool m_appFinished;

   const uint FPS_UPDATE_INTERVAL = 3000;
   uint m_fpsSamplingDuration;
   uint m_framesInSample;
   float m_fps;

   bool[ Key.max + 1 ] m_keyDownList;
}
