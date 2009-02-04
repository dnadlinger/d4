module assimp.api;

import assimp.material;
import assimp.scene;
import assimp.types;

extern ( C ) {
   struct aiFileIO;
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
   aiScene* function( char*, uint ) aiImportFile;

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
   aiScene* function( char* pFile, uint pFlags, aiFileIO* pFS ) aiImportFileEx;

   // ---------------------------------------------------------------------------
   /** Releases all resources associated with the given import process.
   *
   * Call this function after you're done with the imported data.
   * @param pScene The imported data to release. NULL is a valid value.
   */
   // ---------------------------------------------------------------------------
   void function( aiScene* pScene ) aiReleaseImport;

   // ---------------------------------------------------------------------------
   /** Returns the error text of the last failed import process.
   *
   * @return A textual description of the error that occured at the last
   * import process. NULL if there was no error.
   */
   // ---------------------------------------------------------------------------
   char* function() aiGetErrorString;

   // ---------------------------------------------------------------------------
   /** Returns whether a given file extension is supported by ASSIMP
   *
   * @param szExtension Extension for which the function queries support.
   * Must include a leading dot '.'. Example: ".3ds", ".md3"
   * @return 1 if the extension is supported, 0 otherwise
   */
   // ---------------------------------------------------------------------------
   int function( char* szExtension ) aiIsExtensionSupported;

   // ---------------------------------------------------------------------------
   /** Get a full list of all file extensions generally supported by ASSIMP.
   *
   * If a file extension is contained in the list this does, of course, not
   * mean that ASSIMP is able to load all files with this extension.
   * @param szOut String to receive the extension list.
   * Format of the list: "*.3ds;*.obj;*.dae". NULL is not a valid parameter.
   */
   // ---------------------------------------------------------------------------
   void function( aiString* szOut ) aiGetExtensionList;

   // ---------------------------------------------------------------------------
   /** Get the storage required by an imported asset
   * \param pInput Input asset.
   * \param info Data structure to be filled.
   */
   // ---------------------------------------------------------------------------
   void function( aiScene* pInput, aiMemoryInfo* info ) aiGetMemoryRequirements;

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
   void function( char* szName, int value ) aiSetImportPropertyInteger;

   // ---------------------------------------------------------------------------
   /**  @see aiSetImportPropertyInteger()
   */
   void function( char* szName, float value ) aiSetImportPropertyFloat;

   // ---------------------------------------------------------------------------
   /**  @see aiSetImportPropertyInteger()
   */
   void function( char* szName, aiString* st ) aiSetImportPropertyString;



   // ---------------------------------------------------------------------------
   /*
    * Material system functions.
    */
   // ---------------------------------------------------------------------------

   // ---------------------------------------------------------------------------
   /** Retrieve a material property with a specific key from the material
   *
   *  @param pMat Pointer to the input material. May not be NULL
   *  @param pKey Key to search for. One of the AI_MATKEY_XXX constants.
   *  @param pPropOut Pointer to receive a pointer to a valid aiMaterialProperty
   *         structure or NULL if the key has not been found.
   */
   // ---------------------------------------------------------------------------
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      aiTextureType type,
      uint index,
      aiMaterialProperty** pPropOut
   ) aiGetMaterialProperty;


   // ---------------------------------------------------------------------------
   /** Retrieve an array of float values with a specific key
   *  from the material
   *
   * Pass one of the AI_MATKEY_XXX constants for the last three parameters (the
   * example reads the AI_MATKEY_UVTRANSFORM property of the first diffuse texture)
   * @begincode
   *
   * aiUVTransform trafo;
   * uint max = sizeof(aiUVTransform);
   * if (AI_SUCCESS != aiGetMaterialFloatArray(mat, AI_MATKEY_UVTRANSFORM(aiTextureType_DIFFUSE,0),
   *    (float*)&trafo, &max) || sizeof(aiUVTransform) != max)
   * {
   *   // error handling
   * }
   * @endcode
   *
   * @param pMat Pointer to the input material. May not be NULL
   * @param pKey Key to search for. One of the AI_MATKEY_XXX constants.
   * @param pOut Pointer to a buffer to receive the result.
   * @param pMax Specifies the size of the given buffer, in float's.
   *        Receives the number of values (not bytes!) read.
   * @param type (see the code sample above)
   * @param index (see the code sample above)
   * @return Specifies whether the key has been found. If not, the output
   *   arrays remains unmodified and pMax is set to 0.
   */
   // ---------------------------------------------------------------------------
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      uint type,
      uint index,
      float* pOut,
      uint* pMax = null
   ) aiGetMaterialFloatArray;

   alias aiGetMaterialFloatArray aiGetMaterialFloat;

   // ---------------------------------------------------------------------------
   /** Retrieve an array of integer values with a specific key
   *  from a material
   *
   * See the sample for aiGetMaterialFloatArray for more information.
   */
   // ---------------------------------------------------------------------------
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      uint  type,
      uint  index,
      int* pOut,
      uint* pMax = null
   ) aiGetMaterialIntegerArray;

   alias aiGetMaterialIntegerArray aiGetMaterialInteger;

   // ---------------------------------------------------------------------------
   /** Retrieve a color value from the material property table
   *
   * See the sample for aiGetMaterialFloat for more information.
   */
   // ---------------------------------------------------------------------------
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      uint type,
      uint index,
      aiColor4D* pOut
   ) aiGetMaterialColor;


   // ---------------------------------------------------------------------------
   /** Retrieve a string from the material property table
   *
   * See the sample for aiGetMaterialFloat for more information.
   */
   // ---------------------------------------------------------------------------
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      uint type,
      uint index,
      aiString* pOut
   ) aiGetMaterialString;


   // ---------------------------------------------------------------------------
   /** Helper function to get a texture from a material structure.
   *
   *  This function is provided just for convinience.
   *  @param mat Pointer to the input material. May not be NULL
   *  @param index Index of the texture to retrieve. If the index is too
   *    large the function fails.
   *  @param type Specifies the type of the texture to retrieve (e.g. diffuse,
   *     specular, height map ...)
   *  @param path Receives the output path
   *    NULL is no allowed as value
   *  @param uvindex Receives the UV index of the texture.
   *    NULL is allowed as value. The return value is
   *  @param blend Receives the blend factor for the texture
   *    NULL is allowed as value.
   *  @param op Receives the texture operation to perform between
   *    this texture and the previous texture. NULL is allowed as value.
   *  @param mapmode Receives the mapping modes to be used for the texture.
   *      The parameter may be NULL but if it is a valid pointer it MUST
   *      point to an array of 3 aiTextureMapMode variables (one for each
   *      axis: UVW order (=XYZ)).
   */
   // ---------------------------------------------------------------------------
   aiReturn function(
      aiMaterial* mat,
      aiTextureType type,
      uint  index,
      aiString* path,
      aiTextureMapping* mapping = null,
      uint* uvindex = null,
      float* blend = null,
      aiTextureOp* op = null,
      aiTextureMapMode* mapmode = null
   ) aiGetMaterialTexture;
}