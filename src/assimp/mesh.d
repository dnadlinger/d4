/** @file aiMesh.h
 *  @brief Declares the data structures in which the imported geometry is
    returned by ASSIMP: aiMesh, aiFace and aiBone data structures.
 */
module assimp.mesh;

import assimp.types;

extern ( C ) {
   // ---------------------------------------------------------------------------
   /** @brief A single face in a mesh, referring to multiple vertices.
    *
    * If mNumIndices is 3, we call the face 'triangle', for mNumIndices > 3
    * it's called 'polygon' (hey, that's just a definition!).
    *
    * aiMesh::mPrimitiveTypes can be queried to quickly examine which types of
    * primitive are actually present in a mesh. The #aiProcess_SortByPType flag
    * executes a special post-processing algorithm which splits meshes with
    * *different* primitive types mixed up (e.g. lines and triangles) in several
    * 'clean' submeshes. Furthermore there is a configuration option (
    * #AI_CONFIG_PP_SBP_REMOVE) to force #aiProcess_SortByPType to remove
    * specific kinds of primitives from the imported scene, completely and forever.
    *
    * In many cases you'll probably want to set this setting to
    * @code
    * aiPrimitiveType_LINE|aiPrimitiveType_POINT
    * @endcode
    *
    * Together with the #aiProcess_Triangulate flag you can then be sure that
    * #aiFace::mNumIndices is always 3.
    * @note Take a look at the @link data Data Structures page @endlink for
    * more information on the layout and winding order of a face.
    */
   struct aiFace {
      //! Number of indices defining this face. 3 for a triangle, >3 for polygon
      uint mNumIndices;

      //! Pointer to the indices array. Size of the array is given in numIndices.
      uint* mIndices;
   }


   // ---------------------------------------------------------------------------
   /** @brief A single influence of a bone on a vertex.
    */
   struct aiVertexWeight {
      //! Index of the vertex which is influenced by the bone.
      uint mVertexId;

      //! The strength of the influence in the range (0...1).
      //! The influence from all bones at one vertex amounts to 1.
      float mWeight;
   }


   // ---------------------------------------------------------------------------
   /** @brief A single bone of a mesh.
    *
    *  A bone has a name by which it can be found in the frame hierarchy and by
    *  which it can be addressed by animations. In addition it has a number of
    *  influences on vertices.
    */
   struct aiBone {
      //! The name of the bone.
      aiString mName;

      //! The number of vertices affected by this bone
      uint mNumWeights;

      //! The vertices affected by this bone
      aiVertexWeight* mWeights;

      //! Matrix that transforms from mesh space to bone space in bind pose
      aiMatrix4x4 mOffsetMatrix;
   }

   // ---------------------------------------------------------------------------
   /** @def AI_MAX_NUMBER_OF_COLOR_SETS
    *  Maximum number of vertex color sets per mesh.
    *
    *  Normally: Diffuse, specular, ambient and emissive
    *  However one could use the vertex color sets for any other purpose, too.
    *
    *  @note Some internal structures expect (and assert) this value
    *    to be at least 4. For the moment it is absolutely safe to assume that
    *    this will never change.
    */
   const uint AI_MAX_NUMBER_OF_COLOR_SETS = 0x4;

   /** @def AI_MAX_NUMBER_OF_TEXTURECOORDS
    *  Maximum number of texture coord sets (UV(W) channels) per mesh
    *
    *  The material system uses the AI_MATKEY_UVWSRC_XXX keys to specify
    *  which UVW channel serves as data source for a texture.
    *
    *  @note Some internal structures expect (and assert) this value
    *    to be at least 4. For the moment it is absolutely safe to assume that
    *    this will never change.
    */
   const uint AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x4;

   // ---------------------------------------------------------------------------
   /** @brief Enumerates the types of geometric primitives supported by Assimp.
   *
   *  @see aiFace Face data structure
   *  @see aiProcess_SortByPType Per-primitive sorting of meshes
   *  @see aiProcess_Triangulate Automatic triangulation
   *  @see AI_CONFIG_PP_SBP_REMOVE Removal of specific primitive types.
   */
   enum aiPrimitiveType : uint {
      /** A point primitive.
       *
       * This is just a single vertex in the virtual world,
       * #aiFace contains just one index for such a primitive.
       */
      POINT       = 0x1,

      /** A line primitive.
       *
       * This is a line defined through a start and an end position.
       * #aiFace contains exactly two indices for such a primitive.
       */
      LINE        = 0x2,

      /** A triangular primitive.
       *
       * A triangle consists of three indices.
       */
      TRIANGLE    = 0x4,

      /** A higher-level polygon with more than 3 edges.
       *
       * A triangle is a polygon, but polygon in this context means
       * "all polygons that are not triangles". The "Triangulate"-Step
       * is provided for your convinience, it splits all polygons in
       * triangles (which are much easier to handle).
       */
      POLYGON     = 0x8
   }

   // TODO: Integrate AI_PRIMITIVE_TYPE_FOR_N_INDICES(n)

   // ---------------------------------------------------------------------------
   /** @brief A mesh represents a geometry or model with a single material.
   *
   * It usually consists of a number of vertices and a series of primitives/faces
   * referencing the vertices. In addition there might be a series of bones, each
   * of them addressing a number of vertices with a certain weight. Vertex data
   * is presented in channels with each channel containing a single per-vertex
   * information such as a set of texture coords or a normal vector.
   * If a data pointer is non-null, the corresponding data stream is present.
   * From C++-programs you can also use the comfort functions Has*() to
   * test for the presence of various data streams.
   *
   * A Mesh uses only a single material which is referenced by a material ID.
   * @note The mPositions member is usually not optional. However, vertex positions
   * *could* be missing if the AI_SCENE_FLAGS_INCOMPLETE flag is set in
   * @code
   * aiScene::mFlags
   * @endcode
   */
   struct aiMesh {
      /** Bitwise combination of the members of the #aiPrimitiveType enum.
       * This specifies which types of primitives are present in the mesh.
       * The "SortByPrimitiveType"-Step can be used to make sure the
       * output meshes consist of one primitive type each.
       */
      uint mPrimitiveTypes;

      /** The number of vertices in this mesh.
      * This is also the size of all of the per-vertex data arrays
      */
      uint mNumVertices;

      /** The number of primitives (triangles, polygons, lines) in this  mesh.
      * This is also the size of the mFaces array
      */
      uint mNumFaces;

      /** Vertex positions.
      * This array is always present in a mesh. The array is
      * mNumVertices in size.
      */
      aiVector3D* mVertices;

      /** Vertex normals.
      * The array contains normalized vectors, NULL if not present.
      * The array is mNumVertices in size. Normals are undefined for
      * point and line primitives. A mesh consisting of points and
      * lines only may not have normal vectors. Meshes with mixed
      * primitive types (i.e. lines and triangles) may have normals,
      * but the normals for vertices that are only referenced by
      * point or line primitives are undefined and set to QNaN (WARN:
      * qNaN compares to inequal to *everything*, even to qNaN itself.
      * Use code like this
      * @code
      * #define IS_QNAN(f) (f != f)
      * @endcode
      * to check whether a field is qnan).
      * @note Normal vectors computed by Assimp are always unit-length.
      * However, this needn't apply for normals that have been taken
      *   directly from the model file.
      */
      aiVector3D* mNormals;

      /** Vertex tangents.
      * The tangent of a vertex points in the direction of the positive
      * X texture axis. The array contains normalized vectors, NULL if
      * not present. The array is mNumVertices in size. A mesh consisting
      * of points and lines only may not have normal vectors. Meshes with
      * mixed primitive types (i.e. lines and triangles) may have
      * normals, but the normals for vertices that are only referenced by
      * point or line primitives are undefined and set to QNaN.
      * @note If the mesh contains tangents, it automatically also
      * contains bitangents (the bitangent is just the cross product of
      * tangent and normal vectors).
      */
      aiVector3D* mTangents;

      /** Vertex bitangents.
      * The bitangent of a vertex points in the direction of the positive
      * Y texture axis. The array contains normalized vectors, NULL if not
      * present. The array is mNumVertices in size.
      * @note If the mesh contains tangents, it automatically also contains
      * bitangents.
      */
      aiVector3D* mBitangents;

      /** Vertex color sets.
      * A mesh may contain 0 to #AI_MAX_NUMBER_OF_COLOR_SETS vertex
      * colors per vertex. NULL if not present. Each array is
      * mNumVertices in size if present.
      */
      aiColor4D* mColors[ AI_MAX_NUMBER_OF_COLOR_SETS ];

      /** Vertex texture coords, also known as UV channels.
      * A mesh may contain 0 to AI_MAX_NUMBER_OF_TEXTURECOORDS per
      * vertex. NULL if not present. The array is mNumVertices in size.
      */
      aiVector3D* mTextureCoords[ AI_MAX_NUMBER_OF_TEXTURECOORDS ];

      /** Specifies the number of components for a given UV channel.
      * Up to three channels are supported (UVW, for accessing volume
      * or cube maps). If the value is 2 for a given channel n, the
      * component p.z of mTextureCoords[n][p] is set to 0.0f.
      * If the value is 1 for a given channel, p.y is set to 0.0f, too.
      * If this value is 0, 2 should be assumed.
      * @note 4D coords are not supported
      */
      uint mNumUVComponents[ AI_MAX_NUMBER_OF_TEXTURECOORDS ];

      /** The faces the mesh is contstructed from.
      * Each face referres to a number of vertices by their indices.
      * This array is always present in a mesh, its size is given
      * in mNumFaces. If the AI_SCENE_FLAGS_NON_VERBOSE_FORMAT
      * is NOT set each face references an unique set of vertices.
      */
      aiFace* mFaces;

      /** The number of bones this mesh contains.
      * Can be 0, in which case the mBones array is NULL.
      */
      uint mNumBones;

      /** The bones of this mesh.
      * A bone consists of a name by which it can be found in the
      * frame hierarchy and a set of vertex weights.
      */
      aiBone** mBones;

      /** The material used by this mesh.
      * A mesh does use only a single material. If an imported model uses
      * multiple materials, the import splits up the mesh. Use this value
      * as index into the scene's material list.
      */
      uint mMaterialIndex;
   }
}
