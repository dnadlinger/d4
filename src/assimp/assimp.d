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

import tango.sys.SharedLib;

/**
 * Loader for the Assimp library (http://assimp.sf.net), rev 425.
 * 
 * Headers still missing: aiAnim.h, aiCamera.h, aiConfig.h, aiFileIO.h, aiLight.h
 */
struct Assimp {
public:
   static void load() {
      if ( m_sRefCount == 0 ) {
         version ( Win32 ) {
            m_sLibrary = SharedLib.load( "Assimp32.dll" );
         }
         version ( Posix ) {
            m_sLibrary = SharedLib.load( "libassimp.so" );
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
      }
      ++m_sRefCount;
   }

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
   
   static uint m_sRefCount;
   static SharedLib m_sLibrary;
}