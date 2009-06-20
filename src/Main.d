/**
 * The entry point for the application. The functions here deal with
 * rather low-level stuff, the "real" application lies in the
 * <code>MainApplication</code> package.
 */
module Main;

import tango.core.Array;
import tango.core.Exception;
import tango.core.Memory;
import tango.core.Runtime;
import tango.io.Console;
import tango.io.Stdout;
import tango.text.convert.Integer;
import MainApplication;

/**
 * Converts assertion errors to exceptions to be able to wait for user input
 * in Windows before the program is closed.
 */
void assertHandler( char[] file, size_t line, char[] assertionMessage = null ) {
   char[] message = "Assertion false in " ~ file ~ ", line " ~ toString( line );
   
   if ( assertionMessage !is null ) {
      message ~= ": " ~ assertionMessage;
   } else {
      message ~= "!";
   }
   
   throw new Exception( message );
}

/**
 * Print a glyph to stdout whenever an object is garbage collected.
 */
bool printGlyph( Object object ) {
   // Not immediately flushing to save time.
   Stdout( "›" );
   return true;
}

uint collectedObjects;
bool countObject( Object object ) {
   ++collectedObjects;
   return true;
}

bool printClass( Object object ) {
   Stdout( "Collecting remaining object: " ~ object.classinfo.name ).newline;
   return true;
}

/**
 * The entry point for the application.
 */
void main( char[][] args ) {
   // Execute asm "int 3" when encountering a false assert to be able to debug it.
   setAssertHandler( &assertHandler );

   // Show garbage collection activity while the program is running.
   Runtime.collectHandler = &printGlyph;

   MainApplication app;
   try {
      app = new MainApplication();
      
      // Parse command line options.
      if ( args.length < 2 ) {
         throw new Exception( "Please specify a model file at the command line" );
      }
      
      app.sceneFile = args[ 1 ];
   
      if ( contains( args[ 2..$ ], "smoothNormals" ) ) {
         app.generateSmoothNormals = true;
      }
      
      if ( contains( args[ 2..$ ], "fakeColors" ) ) {
         app.fakeColors = true;
      }
      
      // Start the application main loop.
      app.run();
   } catch ( Exception e ) {
      Stdout( "ERROR: " )( e ).newline;
      
      // In a debug build, set off the debugger trap/signal.
      debug {
         asm {
            // int 3 (0xCC) invokes the attached debugger if any.
            int 3;
         }
      }
   } finally {
      // Count objects collected on program end.
      collectedObjects = 0;
      Runtime.collectHandler = &countObject;

      // The application has to be deleted when tho program ends, even if something
      // has gone wrong before, because Derelict causes a segfault if not
      // unloaded properly.
      delete app;
      GC.collect();

      Stdout.newline;
      Stdout.format( "{} objects collected.", collectedObjects ).newline;

      debug {
         // Print the class name if any objects are garbage collected after
         // this point in debug builds, which could be a sign for some unwanted
         // references.
         Runtime.collectHandler = &printClass;
      }

      // On Windows, wait for user pressing <Enter> before exiting.
      version ( Windows ) {
         Stdout( "Press <Enter> to exit." ).newline;
         Cin.get();
      }
   }
}
