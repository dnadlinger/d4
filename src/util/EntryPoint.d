/*
 * Copyright © 2010, klickverbot <klickverbot@gmail.com>.
 *
 * This file is part of d4, which is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * d4 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * d4. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Template for the entry point of a typical application.
 */
module util.EntryPoint;

debug {
   version = TraceGc;
}

template EntryPoint( ApplicationClass ) {
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

      version ( TraceGc ) {
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
         version ( TraceGc ) {
            // Count objects collected on program end.
            collectedObjectsCount = 0;
            Runtime.collectHandler = &countObject;
         }

         // The application has to be deleted when the program ends, even if
         // something has gone wrong before, because some libraries like Derelict
         // cause a segfault if they are not unloaded properly.
         delete app;

         version ( TraceGc ) {
            GC.collect();
            Stdout.newline;
            Stdout.format( "{} objects collected.", collectedObjectsCount ).newline;

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
}
