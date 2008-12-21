module d4.util.Application;

import d4.output.Surface;
import d4.util.keys;

abstract class Application {
   final void run() {
      init();
      
      m_totalTicksPassed = 0;
      m_appFinished = false;
      uint lastStartTicks = currentTicks();
      
      while ( !m_appFinished ) {
         uint frameStartTicks = currentTicks();
         uint deltaTicks = ( frameStartTicks - lastStartTicks );
         m_totalTicksPassed += deltaTicks;
         lastStartTicks = frameStartTicks;
      
         processEvents();
         
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
   
   final bool isKeyDown( Keycode key ) {
      return m_keyDownList[ key ];
   }
   
   
   final void handleKeyDown( Keycode key ) {
      m_keyDownList[ key ] = true;
   }
   
   final void handleKeyUp( Keycode key ) {   
      m_keyDownList[ key ] = false;
      
      if ( key == KEY_ESCAPE ) {
         exit();
      }
   }
   
   
private:
   uint m_totalTicksPassed;
   bool m_appFinished;
   bool[ KEY_LAST ] m_keyDownList;
}