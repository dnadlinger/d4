/** @file  aiVersion.h
 *  @brief Functions to query the version of the Assimp runtime, check
 *    compile flags, ...
 */
module assimp.versionInfo;

extern ( C ) {
   //! Assimp was compiled as a shared object (Windows: DLL)
   uint ASSIMP_CFLAGS_SHARED = 0x1;
   //! Assimp was compiled against STLport
   uint ASSIMP_CFLAGS_STLPORT = 0x2;
   //! Assimp was compiled as a debug build
   uint ASSIMP_CFLAGS_DEBUG = 0x4;

   //! Assimp was compiled with ASSIMP_BUILD_BOOST_WORKAROUND defined
   uint ASSIMP_CFLAGS_NOBOOST = 0x8;
   //! Assimp was compiled with ASSIMP_BUILD_SINGLETHREADED defined
   uint ASSIMP_CFLAGS_SINGLETHREADED = 0x10;

   // ---------------------------------------------------------------------------
   // Functions have been moved into assimp.api.
}
