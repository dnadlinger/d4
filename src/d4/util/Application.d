module d4.util.Application;

import tango.io.Stdout;
import d4.output.Surface;
import d4.util.Key;

/**
 * Provides basic functionality for all kinds of 3d applications
 * (event loop, key handling, ...).
 */
abstract class Application {
public:
   /**
    * Executes the application main (event) loop.
    *
    * This function returns when the application has been closed.
    */
   final void run() {
      m_appFinished = false;

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

         // Detect slow frames – frames that have took siginficantely longer
         // than the previous one. Could be a hint to certain problems like
         // unwanted garbage collector activity.
         const triggerLevel = 9;
         if ( deltaTicks > ( lastDeltaTicks * triggerLevel ) ) {
            Stdout.format( "Possible slow frame detected ({} ms).", deltaTicks ).newline;
         }
         lastDeltaTicks = deltaTicks;

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

protected:
   /*
    * Functions to overwrite in subclasses with the concrete implementation.
    */

   /**
    * Initializes the application.
    */
   abstract void init();

   /**
    * Ticks the world and renders the scene.
    *
    * Params:
    *     deltaTime = The time which elapsed since the last frame.
    */
   abstract void render( float deltaTime );

   /**
    * Shuts the application down.
    */
   abstract void shutdown();


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


   /**
    * Causes the application to exit after the current frame is finished.
    */
   final void exit() {
      m_appFinished = true;
   }


   /*
    * Internal functionality provided to subclasses.
    */

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
   uint m_totalTicksPassed;
   bool m_appFinished;

   const uint FPS_UPDATE_INTERVAL = 3000;
   uint m_fpsSamplingDuration;
   uint m_framesInSample;
   float m_fps;

   bool[ Key.max + 1 ] m_keyDownList;
}
