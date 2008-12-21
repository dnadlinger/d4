module main;

import tango.math.Math : sin;
import d4.math.Color;
import d4.util.SdlApplication;

class MainApplication : SdlApplication {
   override void init() {
   }
   
   override void render( float deltaTime ) {
      screen().lock();
      
      float time = totalTimePassed();
      ubyte red = 128 + cast( ubyte )( 128 * sin( time ) );
      ubyte green = 128 + cast( ubyte )( 128 * sin( time - 1 ) );
      ubyte blue = 128 + cast( ubyte )( 128 * sin( time + 1 ) );
      screen().clear( Color( red, green, blue ) );

      screen().unlock();
   }
   
   override void shutdown() {
   }
}

void main() {
   scope auto app = new MainApplication();
   app.run();
}