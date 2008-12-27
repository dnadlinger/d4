module assimp.api;

import assimp.scene;

extern ( C ) {
   struct aiFileIO;
   struct aiString;
   struct aiMemoryInfo;

   // ---------------------------------------------------------------------------
   /** Reads the given file and returns its content.
   *
   * If the call succeeds, the imported data is returned in an aiScene structure.
   * The data is intended to be read-only, it stays property of the ASSIMP
   * library and will be stable until aiReleaseImport() is called. After you're
   * done with it, call aiReleaseImport() to free the resources associated with
   * this file. If the import fails, NULL is returned instead. Call
   * aiGetErrorString() to retrieve a human-readable error text.
   * @param pFile Path and filename of the file to be imported,
   *   expected to be a null-terminated c-string. NULL is not a valid value.
   * @param pFlags Optional post processing steps to be executed after
   *   a successful import. Provide a bitwise combination of the
   *   #aiPostProcessSteps flags.
   * @return Pointer to the imported data or NULL if the import failed.
   */
   // ---------------------------------------------------------------------------
   aiScene* aiImportFile( char* pFile, uint pFlags );

   // ---------------------------------------------------------------------------
   /** Reads the given file using user-defined I/O functions and returns
   *   its content.
   *
   * If the call succeeds, the imported data is returned in an aiScene structure.
   * The data is intended to be read-only, it stays property of the ASSIMP
   * library and will be stable until aiReleaseImport() is called. After you're
   * done with it, call aiReleaseImport() to free the resources associated with
   * this file. If the import fails, NULL is returned instead. Call
   * aiGetErrorString() to retrieve a human-readable error text.
   * @param pFile Path and filename of the file to be imported,
   *   expected to be a null-terminated c-string. NULL is not a valid value.
   * @param pFlags Optional post processing steps to be executed after
   *   a successful import. Provide a bitwise combination of the
   *   #aiPostProcessSteps flags.
   * @param pFS aiFileIO structure. Will be used to open the model file itself
   *   and any other files the loader needs to open.
   * @return Pointer to the imported data or NULL if the import failed.
   */
   // ---------------------------------------------------------------------------
   aiScene* aiImportFileEx( char* pFile, uint pFlags, aiFileIO* pFS );

   // ---------------------------------------------------------------------------
   /** Releases all resources associated with the given import process.
   *
   * Call this function after you're done with the imported data.
   * @param pScene The imported data to release. NULL is a valid value.
   */
   // ---------------------------------------------------------------------------
   void aiReleaseImport( aiScene* pScene );

   // ---------------------------------------------------------------------------
   /** Returns the error text of the last failed import process.
   *
   * @return A textual description of the error that occured at the last
   * import process. NULL if there was no error.
   */
   // ---------------------------------------------------------------------------
   char* aiGetErrorString();

   // ---------------------------------------------------------------------------
   /** Returns whether a given file extension is supported by ASSIMP
   *
   * @param szExtension Extension for which the function queries support.
   * Must include a leading dot '.'. Example: ".3ds", ".md3"
   * @return 1 if the extension is supported, 0 otherwise
   */
   // ---------------------------------------------------------------------------
   int aiIsExtensionSupported( char* szExtension );

   // ---------------------------------------------------------------------------
   /** Get a full list of all file extensions generally supported by ASSIMP.
   *
   * If a file extension is contained in the list this does, of course, not
   * mean that ASSIMP is able to load all files with this extension.
   * @param szOut String to receive the extension list.
   * Format of the list: "*.3ds;*.obj;*.dae". NULL is not a valid parameter.
   */
   // ---------------------------------------------------------------------------
   void aiGetExtensionList( aiString* szOut );

   // ---------------------------------------------------------------------------
   /** Get the storage required by an imported asset
   * \param pInput Input asset.
   * \param info Data structure to be filled.
   */
   // ---------------------------------------------------------------------------
   void aiGetMemoryRequirements( aiScene* pInput, aiMemoryInfo* info );

   // ---------------------------------------------------------------------------
   /** Set an integer property. This is the C-version of
   *  #Importer::SetPropertyInteger(). In the C-API properties are shared by
   *  all imports. It is not possible to specify them per asset.
   *
   * \param szName Name of the configuration property to be set. All constants
   *   are defined in the aiConfig.h header file.
   * \param value New value for the property
   */
   // ---------------------------------------------------------------------------
   void aiSetImportPropertyInteger( char* szName, int value );

   // ---------------------------------------------------------------------------
   /**  @see aiSetImportPropertyInteger()
   */
   void aiSetImportPropertyFloat( char* szName, float value );

   // ---------------------------------------------------------------------------
   /**  @see aiSetImportPropertyInteger()
   */
   void aiSetImportPropertyString( char* szName, aiString* st );
}

// Tell DSSS to link against the assimp lib.
version ( build ) {
   pragma( link, "stdc++" );
   pragma( link, "Irrlicht" );
   pragma( link, "assimp" );
}
