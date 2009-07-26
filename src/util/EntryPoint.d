/**
 * Template for the entry point of a typical application.
 */
module util.EntryPoint;

template EntryPoint( ApplicationClass, bool TraceGc = false ) {
   import tango.core.Exception;
   import tango.core.Memory;
   import tango.core.Runtime;
   import tango.io.Console;
   import tango.io.Stdout;
   import tango.text.convert.Integer;

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

   uint collectedObjectsCount;
   bool countObject( Object object ) {
      ++collectedObjectsCount;
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

      static if ( TraceGc ) {
         // Show garbage collection activity while the program is running.
         Runtime.collectHandler = &printGlyph;
      }

      ApplicationClass app;
      try {
         app = new ApplicationClass( args );

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
         static if ( TraceGc ) {
            // Count objects collected on program end.
            collectedObjectsCount = 0;
            Runtime.collectHandler = &countObject;
         }

         // The application has to be deleted when the program ends, even if
         // something has gone wrong before, because some libraries like Derelict
         // cause a segfault if they are not unloaded properly.
         delete app;

         static if ( TraceGc ) {
            GC.collect();
            Stdout.newline;
            Stdout.format( "{} objects collected.", collectedObjectsCount ).newline;

            debug {
               // Print the class name if any objects are garbage collected after
               // this point in debug builds, which could be a sign for some unwanted
               // references.
               Runtime.collectHandler = &printClass;
            }
         }

         // On Windows, wait for user pressing <Enter> before exiting.
         version ( Windows ) {
            Stdout( "Press <Enter> to exit." ).newline;
            Cin.get();
         }
      }
   }
}