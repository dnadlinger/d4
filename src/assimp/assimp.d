/**
 * Bindings for the Assimp library (http://assimp.sf.net).
 *
 * There are still a few C headers missing, namely: aiAnim.h, aiCamera.h,
 * aiConfig.h, aiFileIO.h, aiLight.h.
 */
module assimp.assimp;

public {
   import assimp.api;
   import assimp.material;
   import assimp.mesh;
   import assimp.postprocess;
   import assimp.scene;
   import assimp.texture;
   import assimp.types;
}

import tango.io.Stdout;
import tango.sys.SharedLib;

/**
 * The SVN revision of Assimp the bindings were created against.
 *
 * Because the Assimp guys seemingly update the number by hand, it is not
 * necessarily the same as the SVN revision counter (although it should be).
 *
 * Current SVN revision: 425.
 */
const uint ASSIMP_BINDINGS_REVISION = 423;

/**
 * Loader class for dynamically loading the Assimp library.
 *
 * The library is »reference-counted«, meaning that the library is not
 * unloaded on a call to <code>unload()</code> if there are still other
 * references to it.
 */
struct Assimp {
public:
   /**
    * Loads the library if it is not already loaded and increases the
    * reference counter.
    *
    * The library file (<code>libassimp.so</code> on POSIX systems,
    * <code>Assimp32.dll</code> on Win32) is loaded via Tango's SharedLib
    * class.
    */
   static void load() {
      if ( m_sRefCount == 0 ) {
         Stdout( "Loading Assimp library... " );
         version ( Posix ) {
            m_sLibrary = SharedLib.load( "libassimp.so" );
         }
         version ( Win32 ) {
            m_sLibrary = SharedLib.load( "Assimp32.dll" );
         }

         // General API
         bind( aiImportFile )( "aiImportFile" );
         bind( aiImportFileEx )( "aiImportFileEx" );
         bind( aiApplyPostProcessing )( "aiApplyPostProcessing" );
         bind( aiReleaseImport )( "aiReleaseImport" );
         bind( aiGetErrorString )( "aiGetErrorString" );
         bind( aiIsExtensionSupported )( "aiIsExtensionSupported" );
         bind( aiGetExtensionList )( "aiGetExtensionList" );
         bind( aiGetMemoryRequirements )( "aiGetMemoryRequirements" );
         bind( aiSetImportPropertyInteger )( "aiSetImportPropertyInteger" );
         bind( aiSetImportPropertyFloat )( "aiSetImportPropertyFloat" );
         bind( aiSetImportPropertyString )( "aiSetImportPropertyString" );
         bind( aiCreateQuaternionFromMatrix )( "aiCreateQuaternionFromMatrix" );
         bind( aiDecomposeMatrix )( "aiDecomposeMatrix" );

         // Material system
         // TODO: Why is this not exported into the dll?
         // bind( aiGetMaterialProperty )( "aiGetMaterialProperty" );
         bind( aiGetMaterialFloatArray )( "aiGetMaterialFloatArray" );
         bind( aiGetMaterialIntegerArray )( "aiGetMaterialIntegerArray" );
         bind( aiGetMaterialColor )( "aiGetMaterialColor" );
         bind( aiGetMaterialString )( "aiGetMaterialString" );
         bind( aiGetMaterialTexture )( "aiGetMaterialTexture" );

         // Versioning
         bind( aiGetLegalString )( "aiGetLegalString" );
         bind( aiGetVersionMinor )( "aiGetVersionMinor" );
         bind( aiGetVersionMajor )( "aiGetVersionMajor" );
         bind( aiGetVersionRevision )( "aiGetVersionRevision" );
         bind( aiGetCompileFlags )( "aiGetCompileFlags" );

         Stdout( "done." ).newline;

         // TODO: Replace this with major/minor version check once Assimp's
         // API stable enough.
         if ( aiGetVersionRevision() != ASSIMP_BINDINGS_REVISION ) {
            Stdout.format( "WARNING: Assimp version mismatch (bindings: r{}, library: r{})!",
               ASSIMP_BINDINGS_REVISION, aiGetVersionRevision() ).newline;
         }
      }
      ++m_sRefCount;
   }

   /**
    * Decreases the reference counter and unloads the library if this was the
    * last reference.
    */
   static void unload() {
      assert( m_sRefCount > 0 );
      --m_sRefCount;

      if ( m_sRefCount == 0 ) {
         m_sLibrary.unload();
      }
   }

private:
   // The binding magic is shamelessly stolen from Derelict.
   struct Binder {
   public:
      static Binder opCall( void** functionPointerAddress ) {
         Binder binder;
         binder.m_functionPointerAddress = functionPointerAddress;
         return binder;
      }

      void opCall( char* name ) {
         *m_functionPointerAddress = m_sLibrary.getSymbol( name );
      }

   private:
       void** m_functionPointerAddress;
   }

   template bind( Function ) {
      static Binder bind( inout Function a ) {
         Binder binder = Binder( cast( void** ) &a );
         return binder;
      }
   }

   /// Current number of references to the library.
   static uint m_sRefCount;

   /// Library handle.
   static SharedLib m_sLibrary;
}
