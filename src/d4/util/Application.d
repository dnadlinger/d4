module d4.util.Application;

import tango.io.Stdout;
import d4.output.Surface;
import d4.util.Key;

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
      
      // The tick count when the last frame started to measure the elapsed time.
      uint lastStartTicks = currentTicks();
      
      // The duration of the last frame to detect "slow" frames. Initialized
      // with 30 in lack of a better value (there have been no previous frames).
      uint lastDeltaTicks = 30;

      while ( !m_appFinished ) {
         // Calculate the time elapsed since the last frame start.
         uint frameStartTicks = currentTicks();
         uint deltaTicks = ( frameStartTicks - lastStartTicks );
         lastStartTicks = frameStartTicks;

         // Keep track of the total time the app is running.
         m_totalTicksPassed += deltaTicks;
         
         // Detect slow frames – frames that have took siginficantely longer
         // than the previous one. Could be a hint to certain problems like
         // unwanted garbage collector activity.
         const triggerLevel = 10;
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
   abstract void init();
   abstract void render( float deltaTime );
   abstract void shutdown();

   abstract Surface screen();
   abstract uint currentTicks();
   abstract void processEvents();

   final void exit() {
      m_appFinished = true;
   }


   final uint totalTicksPassed() {
      return m_totalTicksPassed;
   }

   final float totalTimePassed() {
      return m_totalTicksPassed / 1000.f;
   }

   final bool isKeyDown( Key key ) {
      return m_keyDownList[ key ];
   }

   final float fps() {
      return m_fps;
   }

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

   const uint FPS_UPDATE_INTERVAL = 1000;
   uint m_fpsSamplingDuration;
   uint m_framesInSample;
   float m_fps;

   bool[ Key.LAST ] m_keyDownList;
}