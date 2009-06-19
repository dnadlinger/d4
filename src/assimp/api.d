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
   aiScene* function( char* pFile, uint pFile ) aiImportFile;

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
   aiScene* function( char* pFile, uint pFlags, aiFileIO* pFS ) aiImportFileEx;

   // --------------------------------------------------------------------------------
   /** Apply post-processing to an already-imported scene.
    *
    * This is strictly equivalent to calling #aiImportFile()/#aiImportFileEx with the
    * same flags. However, you can use this separate function to inspect the imported
    * scene first to fine-tune your post-processing setup.
    * @param pScene Scene to work on.
    * @param pFlags Provide a bitwise combination of the #aiPostProcessSteps flags.
    * @return A pointer to the post-processed data. Post processing is done in-place,
    *   meaning this is still the same #aiScene which you passed for pScene. However,
    *   _if_ post-processing failed, the scene could now be NULL. That's quite a rare
    *   case, post processing steps are not really designed to 'fail'. To be exact,
    *   the #aiProcess_ValidateDS flag is currently the only post processing step
    *   which can actually cause the scene to be reset to NULL.
    */
   aiScene* function( aiScene* pScene, uint pFlags ) aiApplyPostProcessing;

   // TODO: Include logging system functions.

   // ---------------------------------------------------------------------------
   /** Releases all resources associated with the given import process.
    *
    * Call this function after you're done with the imported data.
    * @param pScene The imported data to release. NULL is a valid value.
    */
   void function( aiScene* pScene ) aiReleaseImport;

   // ---------------------------------------------------------------------------
   /** Returns the error text of the last failed import process.
    *
    * @return A textual description of the error that occurred at the last
    * import process. NULL if there was no error. There can't be an error if you
    * got a non-NULL #aiScene from #aiImportFile/#aiImportFileEx/#aiApplyPostProcessing.
    */
   char* function() aiGetErrorString;

   // ---------------------------------------------------------------------------
   /** Returns whether a given file extension is supported by ASSIMP
    *
    * @param szExtension Extension for which the function queries support for.
    * Must include a leading dot '.'. Example: ".3ds", ".md3"
    * @return AI_TRUE if the file extension is supported.
    */
   aiBool function( char* szExtension ) aiIsExtensionSupported;

   // ---------------------------------------------------------------------------
   /** Get a list of all file extensions supported by ASSIMP.
    *
    * If a file extension is contained in the list this does, of course, not
    * mean that ASSIMP is able to load all files with this extension.
    * @param szOut String to receive the extension list.
    * Format of the list: "*.3ds;*.obj;*.dae". NULL is not a valid parameter.
    */
   void function( aiString* szOut ) aiGetExtensionList;

   // ---------------------------------------------------------------------------
   /** Get the storage required by an imported asset
    * @param pIn Input asset.
    * @param in Data structure to be filled.
    */
   void function( aiScene* pIn, aiMemoryInfo* info ) aiGetMemoryRequirements;

   // ---------------------------------------------------------------------------
   /** Set an integer property.
    *
    *  This is the C-version of #Assimp::Importer::SetPropertyInteger(). In the C
    *  interface, properties are always shared by all imports. It is not possible to
    *  specify them per import.
    *
    * @param szName Name of the configuration property to be set. All supported
    *   public properties are defined in the aiConfig.h header file (#AI_CONFIG_XXX).
    * @param value New value for the property
    */
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
   /** Construct a quaternion from a 3x3 rotation matrix.
    *  @param quat Receives the output quaternion.
    *  @param mat Matrix to 'quaternionize'.
    *  @see aiQuaternion(const aiMatrix3x3& pRotMatrix)
    */
   void function( aiQuaternion* quat, aiMatrix3x3* mat ) aiCreateQuaternionFromMatrix;

   // ---------------------------------------------------------------------------
   /** Decompose a transformation matrix into its rotational, translational and
    *  scaling components.
    *
    * @param mat Matrix to decompose
    * @param scaling Receives the scaling component
    * @param rotation Receives the rotational component
    * @param position Receives the translational component.
    * @see aiMatrix4x4::Decompose (aiVector3D&, aiQuaternion&, aiVector3D&) const;
    */
   void function(
      aiMatrix4x4* mat,
      aiVector3D* scaling,
      aiQuaternion* rotation,
      aiVector3D* position
   ) aiDecomposeMatrix;


   // ---------------------------------------------------------------------------
   /*
    * Material system functions.
    */
   // ---------------------------------------------------------------------------

   // ---------------------------------------------------------------------------
   /** @brief Retrieve a material property with a specific key from the material
   *
   *  @param pMat Pointer to the input material. May not be NULL
   *  @param pKey Key to search for. One of the AI_MATKEY_XXX constants.
   *  @param type Specifies the type of the texture to be retrieved (
   *    e.g. diffuse, specular, height map ...)
   *  @param index Index of the texture to be retrieved.
   *  @param pPropOut Pointer to receive a pointer to a valid aiMaterialProperty
   *         structure or NULL if the key has not been found.
   */
   aiReturn function(
     aiMaterial* pMat,
     char* pKey,
     aiTextureType type,
     uint index,
     aiMaterialProperty** pPropOut
   ) aiGetMaterialProperty;

   // ---------------------------------------------------------------------------
   /** @brief Retrieve an array of float values with a specific key
   *  from the material
   *
   * Pass one of the AI_MATKEY_XXX constants for the last three parameters (the
   * example reads the #AI_MATKEY_UVTRANSFORM property of the first diffuse texture)
   * @code
   * aiUVTransform trafo;
   * unsigned int max = sizeof(aiUVTransform);
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
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      uint type,
      uint index,
      int* pOut,
      uint* pMax = null
   ) aiGetMaterialIntegerArray;

   alias aiGetMaterialIntegerArray aiGetMaterialInteger;

   // ---------------------------------------------------------------------------
   /** Retrieve a color value from the material property table
   *
   * See the sample for aiGetMaterialFloat for more information.
   */
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
   aiReturn function(
      aiMaterial* pMat,
      char* pKey,
      uint type,
      uint index,
      aiString* pOut
   ) aiGetMaterialString;

   // ---------------------------------------------------------------------------
   /** @brief Helper function to get a texture from a material structure.
    *
    *  This function is provided just for convenience. You could also read the
    *  texture by reading all of its properties manually. This function bundles
    *  all of them in a huge function-monster.
    *
    *  @param[in] mat Pointer to the input material. May not be NULL
    *  @param[in] type Specifies the type of the texture to read (e.g. diffuse,
    *     specular, height map ...).
    *  @param[in] index Index of the texture layer to be read. The function
    *      fails if the requested layer is not available.
    *  @param[out] path Receives the output path
    *      This parameter mist be non-null.
    *  @param mapping The texture mapping mode to be used.
    *      Pass NULL if you'e not interested in this information.
    *  @param[out] uvindex For UV-mapped textures: receives the index of the UV
    *      source channel. Unmodified otherwise.
    *      Pass NULL if you'e not interested in this information.
    *  @param[out] blend Receives the blend factor for the texture
    *      Pass NULL if you'e not interested in this information.
    *  @param[out] op Receives the texture blend operation to be perform between
    *       this texture and the previous texture.
    *      Pass NULL if you'e not interested in this information.
    *  @param[out] mapmode Receives the mapping modes to be used for the texture.
    *      Pass NULL if you'e not interested in this information. Otherwise,
    *      pass a pointer to an array of two aiTextureMapMode's (one for each
    *      axis, UV order).
    *  @return AI_SUCCESS on success, something else otherwise. Have fun.
    */
   aiReturn function(
      aiMaterial* mat,
      aiTextureType type,
      uint index,
      aiString* path,
      aiTextureMapping* mapping = null,
      uint* uvindex = null,
      float* blend = null,
      aiTextureOp* op = null,
      aiTextureMapMode* mapmode = null
   ) aiGetMaterialTexture;

   // ---------------------------------------------------------------------------
   /*
    * Versioning functions.
    */
   // ---------------------------------------------------------------------------

   // ---------------------------------------------------------------------------
   /** @brief Returns a string with legal copyright and licensing information
    *  about Assimp. The string may include multiple lines.
    *  @return Pointer to static string.
    */
   char* function() aiGetLegalString;

   // ---------------------------------------------------------------------------
   /** @brief Returns the current minor version number of Assimp.
    *  @return Minor version of the Assimp runtime the application was
    *    linked/built against
    */
   uint function() aiGetVersionMinor;

   // ---------------------------------------------------------------------------
   /** @brief Returns the current major version number of Assimp.
    *  @return Major version of the Assimp runtime the application was
    *    linked/built against
    */
   uint function() aiGetVersionMajor;

   // ---------------------------------------------------------------------------
   /** @brief Returns the repository revision of the Assimp runtime.
    *  @return SVN Repository revision number of the Assimp runtime the
    *    application was linked/built against
    */
   uint function() aiGetVersionRevision;

   // ---------------------------------------------------------------------------
   /** @brief Returns assimp's compile flags
    *  @return Any bitwise combination of the ASSIMP_CFLAGS_xxx constants.
    */
   uint function() aiGetCompileFlags;
}