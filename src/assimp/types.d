module assimp.types;

extern ( C ) {
   /** Maximum dimension for strings, ASSIMP strings are zero terminated. */
   const size_t MAXLEN = 1024;
   
   /** Our own C boolean type */
   enum aiBool : int {
      FALSE = 0,
      TRUE = 1
   }

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
   /** Represents a quaternion in a 4D vector. */
   struct aiQuaternion {
      float w, x, y, z;
   }

   // ---------------------------------------------------------------------------
   /** @brief Represents a row-major 3x3 matrix
   *
   *  There's much confusion about matrix layouts (colum vs. row order).
   *  This is *always* a row-major matrix. Even with the
   *  aiProcess_ConvertToLeftHanded flag.
   */
   struct aiMatrix3x3 {
      float a1, a2, a3;
      float b1, b2, b3;
      float c1, c2, c3;
   }

   // ---------------------------------------------------------------------------
   /** @brief Represents a row-major 4x4 matrix, use this for homogeneous
    *   coordinates.
    *
    *  There's much confusion about matrix layouts (colum vs. row order).
    *  This is *always* a row-major matrix. Even with the
    *  aiProcess_ConvertToLeftHanded flag.
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
   /** Represents a string, zero byte terminated.
    *
    *  We use this representation to be C-compatible. The length of such a string
    *  is limited to MAXLEN characters (excluding the terminal zero).
   */
   struct aiString {
      //! Length of the string excluding the terminal 0
      size_t length;

      //! String buffer. Size limit is MAXLEN
      char data[ MAXLEN ];
   }

   // ---------------------------------------------------------------------------
   /**  Standard return type for some library functions.
    * Rarely used, and if, mostly in the C API.
    */
   enum aiReturn : uint {
      /** Indicates that a function was successful */
      SUCCESS = 0x0,

      /** Indicates that a function failed */
      FAILURE = -0x1,

      /** Indicates that not enough memory was available
       * to perform the requested operation
       */
      OUTOFMEMORY = -0x3
   }
   
   // ---------------------------------------------------------------------------
   /** Seek origins (for the virtual file system API).
    *  Much cooler than using SEEK_SET, SEEK_CUR or SEEK_END.
    */
   enum aiOrigin : uint {
    /** Beginning of the file */
      SET = 0x0,

    /** Current position of the file pointer */
      CUR = 0x1,

    /** End of the file, offsets must be negative */
      END = 0x2
   }
   
   // TODO: Include aiDefaultLogStream.

   // ---------------------------------------------------------------------------
   /** Stores the memory requirements for different components (e.g. meshes, materials,
    *  animations) of an import. All sizes are in bytes.
    *  @see Importer::GetMemoryRequirements()
    */
   struct aiMemoryInfo {
      /** Storage allocated for texture data */
      uint textures;
      
      /** Storage allocated for material data  */
      uint materials;
      
      /** Storage allocated for mesh data */
      uint meshes;
      
      /** Storage allocated for node data */
      uint nodes;
      
      /** Storage allocated for animation data */
      uint animations;
      
      /** Storage allocated for camera data */
      uint cameras;
      
      /** Storage allocated for light data */
      uint lights;
      
      /** Total storage allocated for the full import. */
      uint total;
   }
}