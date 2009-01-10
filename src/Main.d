module Main;

import tango.core.Array;
import tango.core.Exception;
import tango.core.Memory;
import tango.core.Runtime;
import tango.io.Stdout;
import MainApplication;

void assertHandler( char[] file, size_t line, char[] msg = null ) {
   asm {
      // int 3 (0x33) invokes the attached debugger if any.
      int 3;
   }
}

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

void main( char[][] args ) {
   // Execute asm "int 3" when encountering a false assert to be able to debug it.
   setAssertHandler( &assertHandler );

   // Show garbage collection activity while the program is running.
   Runtime.collectHandler = &printGlyph;

   auto app = new MainApplication();
   // The application has to be deleted when tho program ends, even if something
   // has gone wrong before, because Derelict causes a segfault if not
   // unloaded properly.
   scope ( exit ) {
      // Count objects collected on program end.
      collectedObjects = 0;
      Runtime.collectHandler = &countObject;

      delete app;
      GC.collect();

      Stdout.format( "{} objects collected.", collectedObjects ).newline;

      // Print the class name if any remaining object should be collected,
      // because this should not happen.
      Runtime.collectHandler = &printClass;
   }
   
   // Parse command line options.
   try {
      app.modelFile = args[ 1 ];
   } catch ( Exception e ) {
      throw new Exception( "Please specify a model file at the command line" );
   }
   
   if ( contains( args[ 2..$ ], "smoothNormals" ) ) {
      app.normalType = NormalType.GENERATE_SMOOTH;
   } else if ( contains( args[ 2..$ ], "fileNormals" ) ) {
      app.normalType = NormalType.FILE;
   } else {
      app.normalType = NormalType.GENERATE;
   }
   
   if ( contains( args[ 2..$ ], "fakeColors" ) ) {
      app.fakeColors = true;
   }
   
   // Start the application main loop.
   app.run();
}