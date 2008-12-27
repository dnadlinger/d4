module assimp.types;

extern ( C ) {
   /** Maximum dimension for strings, ASSIMP strings are zero terminated */
   const size_t MAXLEN = 1024;

   // ---------------------------------------------------------------------------
   /** Represents a two-dimensional vector. */
   struct aiVector2D {
   align ( 1 ):
      float x, y;
   }

   // ---------------------------------------------------------------------------
   /** Represents a three-dimensional vector. */
   struct aiVector3D {
   align ( 1 ):
      float x, y, z;
   }

   // ---------------------------------------------------------------------------
   /** Represents a row-major 3x3 matrix
   */
   struct aiMatrix3x3 {
      float a1, a2, a3;
      float b1, b2, b3;
      float c1, c2, c3;
   }

   // ---------------------------------------------------------------------------
   /** Represents a row-major 4x4 matrix,
   *  use this for homogenious coordinates
   */
   struct aiMatrix4x4 {
   align ( 1 ):
      float a1, a2, a3, a4;
      float b1, b2, b3, b4;
      float c1, c2, c3, c4;
      float d1, d2, d3, d4;
   }

   // ---------------------------------------------------------------------------
   /** Represents a plane in a three-dimensional, euclidean space
   */
   struct aiPlane {
   align ( 1 ):
      //! Plane equation
      float a, b, c, d;
   }

   // ---------------------------------------------------------------------------
   /** Represents a ray
   */
   struct aiRay {
   align ( 1 ):
      //! Position and direction of the ray
      aiVector3D pos, dir;
   }

   // ---------------------------------------------------------------------------
   /** Represents a color in Red-Green-Blue space.
   */
   struct aiColor3D {
   align ( 1 ):
      //! Red, green and blue color values
      float r, g, b;
   }

   // ---------------------------------------------------------------------------
   /** Represents a color in Red-Green-Blue space including an
   *   alpha component.
   */
   struct aiColor4D {
   align ( 1 ):
      //! Red, green, blue and alpha color values
      float r, g, b, a;
   }

   // ---------------------------------------------------------------------------
   /** Represents a string, zero byte terminated
   */
   struct aiString {
      //! Length of the string excluding the terminal 0
      size_t length;

      //! String buffer. Size limit is MAXLEN
      char data[ MAXLEN ];
   }

   // ---------------------------------------------------------------------------
   /**   Standard return type for all library functions.
   *
   * To check whether or not a function failed check against
   * AI_SUCCESS. The error codes are mainly used by the C-API.
   */
   enum aiReturn {
      //! Indicates that a function was successful
      AI_SUCCESS = 0x0,

      //! Indicates that a function failed
      AI_FAILURE = -0x1,

      //! Indicates that a file was invalid
      AI_INVALIDFILE = -0x2,

      //! Indicates that not enough memory was available
      //! to perform the requested operation
      AI_OUTOFMEMORY = -0x3,

      //! Indicates that an illegal argument has been
      //! passed to a function. This is rarely used,
      //! most functions assert in this case.
      AI_INVALIDARG = -0x4
   }

   // ---------------------------------------------------------------------------
   /** Stores the memory requirements for different parts (e.g. meshes, materials,
   *  animations) of an import.
   *  @see Importer::GetMemoryRequirements()
   */
   struct aiMemoryInfo {
      //! Storage allocated for texture data, in bytes
      uint textures;

      //! Storage allocated for material data, in bytes
      uint materials;

      //! Storage allocated for mesh data, in bytes
      uint meshes;

      //! Storage allocated for node data, in bytes
      uint nodes;

      //! Storage allocated for animation data, in bytes
      uint animations;

      //! Storage allocated for camera data, in bytes
      uint cameras;

      //! Storage allocated for light data, in bytes
      uint lights;

      //! Storage allocated for the import, in bytes
      uint total;
   }

}