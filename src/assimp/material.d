/** @file aiMaterial.h
 *  @brief Defines the material system of the library
 */
module assimp.material;

import assimp.types;

extern ( C ) {
// Name for default materials (2nd is used if meshes have UV coords)
   char* AI_DEFAULT_MATERIAL_NAME = "aiDefaultMat";
   char* AI_DEFAULT_TEXTURED_MATERIAL_NAME = "TexturedDefaultMaterial";

   // ---------------------------------------------------------------------------
   /** @brief Defines how the Nth texture of a specific type is combined with
    *  the result of all previous layers.
    *
    *  Example (left: key, right: value): <br>
    *  @code
    *  DiffColor0     - gray
    *  DiffTextureOp0 - aiTextureOpMultiply
    *  DiffTexture0   - tex1.png
    *  DiffTextureOp0 - aiTextureOpAdd
    *  DiffTexture1   - tex2.png
    *  @endcode
    *  Written as equation, the final diffuse term for a specific pixel would be:
    *  @code
    *  diffFinal = DiffColor0 * sampleTex(DiffTexture0,UV0) +
    *     sampleTex(DiffTexture1,UV0) * diffContrib;
    *  @endcode
    *  where 'diffContrib' is the intensity of the incoming light for that pixel.
    */
   enum aiTextureOp : uint {
      /** T = T1 * T2 */
      Multiply = 0x0,

      /** T = T1 + T2 */
      Add = 0x1,

      /** T = T1 - T2 */
      Subtract = 0x2,

      /** T = T1 / T2 */
      Divide = 0x3,

      /** T = (T1 + T2) - (T1 * T2) */
      SmoothAdd = 0x4,

      /** T = T1 + (T2-0.5) */
      SignedAdd = 0x5
   }

   // ---------------------------------------------------------------------------
   /** @brief Defines how UV coordinates outside the [0...1] range are handled.
    *
    *  Commonly refered to as 'wrapping mode'.
    */
   enum aiTextureMapMode : uint {
      /** A texture coordinate u|v is translated to u%1|v%1
       */
      Wrap = 0x0,

      /** Texture coordinates outside [0...1]
       *  are clamped to the nearest valid value.
       */
      Clamp = 0x1,

      /** If the texture coordinates for a pixel are outside [0...1]
       *  the texture is not applied to that pixel
       */
      Decal = 0x3,

      /** A texture coordinate u|v becomes u%1|v%1 if (u-(u%1))%2 is zero and
       *  1-(u%1)|1-(v%1) otherwise
       */
      Mirror = 0x2
   }

   // ---------------------------------------------------------------------------
   /** @brief Defines how the mapping coords for a texture are generated.
    *
    *  Real-time applications typically require full UV coordinates, so the use of
    *  the aiProcess_GenUVCoords step is highly recommended. It generates proper
    *  UV channels for non-UV mapped objects, as long as an accurate description
    *  how the mapping should look like (e.g spherical) is given.
    *  See the #AI_MATKEY_MAPPING property for more details.
    */
   enum aiTextureMapping : uint {
      /** The mapping coordinates are taken from an UV channel.
      *
      *  The AI_MATKEY_UVSRC key specifies from which (remember,
      *  meshes can have more than one UV channel).
      */
      UV = 0x0,

      /** Spherical mapping */
      SPHERE = 0x1,

      /** Cylindrical mapping */
      CYLINDER = 0x2,

      /** Cubic mapping */
      BOX = 0x3,

      /** Planar mapping */
      PLANE = 0x4,

      /** Undefined mapping. Have fun. */
      OTHER = 0x5
   }

   // ---------------------------------------------------------------------------
   /** @brief Defines the purpose of a texture
    *
    *  This is a very difficult topic. Different 3D packages support different
    *  kinds of textures. For very common texture types, such as bumpmaps, the
    *  rendering results depend on implementation details in the rendering
    *  pipelines of these applications. Assimp loads all texture references from
    *  the model file and tries to determine which of the predefined texture
    *  types below is the best choice to match the original use of the texture
    *  as closely as possible.
    *
    *  In content pipelines you'll usually define how textures have to be handled,
    *  and the artists working on models have to conform to this specification,
    *  regardless which 3D tool they're using.
    */
   enum aiTextureType : uint {
      /** Dummy value.
       *
       * No texture, but the value to be used as 'texture semantic'
       *  (#aiMaterialProperty::mSemantic) for all material properties
       *  *not* related to textures.
       */
      NONE = 0x0,

      /** The texture is combined with the result of the diffuse
       * lighting equation.
       */
      DIFFUSE = 0x1,

      /** The texture is combined with the result of the specular
       * lighting equation.
       */
      SPECULAR = 0x2,

      /** The texture is combined with the result of the ambient
       * lighting equation.
       */
      AMBIENT = 0x3,

      /** The texture is added to the result of the lighting
       *  calculation. It isn't influenced by incoming light.
       */
      EMISSIVE = 0x4,

      /** The texture is a height map.
       *
       * By convention, higher grey-scale values stand for
       * higher elevations from the base height.
       */
      HEIGHT = 0x5,

      /** The texture is a (tangent space) normal-map.
       *
       * Again, there are several conventions for tangent-space
       * normal maps. Assimp does (intentionally) not
       * differenciate here.
       */
      NORMALS = 0x6,

      /** The texture defines the glossiness of the material.
       *
       *  The glossiness is in fact the exponent of the specular
       *  (phong) lighting equation. Usually there is a conversion
       *  function defined to map the linear color values in the
       *  texture to a suitable exponent. Have fun.
       */
      SHININESS = 0x7,

      /** The texture defines per-pixel opacity.
       *
       *  Usually 'white' means opaque and 'black' means
       * 'transparency'. Or quite the opposite. Have fun.
       */
      OPACITY = 0x8,

      /** Displacement texture
       *
       * The exact purpose and format is application-dependent.
       * Higher color values stand for higher vertex displacements.
       */
      DISPLACEMENT = 0x9,

      /** Lightmap texture (aka Ambient Occlusion)
       *
       * Both 'Lightmaps' and dedicated 'ambient occlusion maps' are
       * covered by this material property. The texture contains a
       * scaling value for the final color value of a pixel. It's
       * intensity is not affected by incoming light.
       */
     LIGHTMAP = 0xA,

     /** Reflection texture
      *
      * Contains the color of a perfect mirror reflection.
      * Rarely used, almost nevery for real-time applications.
      */
     REFLECTION = 0xB,

     /** Unknown texture
      *
      * A texture reference that does not match any of the definitions
      * above is considered to be 'unknown'. It is still imported,
      * but is excluded from any further postprocessing.
      */
     UNKNOWN = 0xC
   }

   // ---------------------------------------------------------------------------
   /** @brief Defines all shading models supported by the library
    *
    *  The list of shading modes has been taken from Blender.
    *  See Blender documentation for more information. The API does
    *  not distinguish between "specular" and "diffuse" shaders (thus the
    *  specular term for diffuse shading models like Oren-Nayar remains
    *  undefined).
    *
    *  Again, this value is just a hint. Assimp tries to select the shader whose
    *  most common implementation matches the original rendering results of the
    *  3D modeller which wrote a particular model as closely as possible.
    */
   enum aiShadingMode : uint {
      /** Flat shading. Shading is done on per-face base,
       *  diffuse only. Also known as 'faceted shading'.
       */
      Flat = 0x1,

      /** Simple Gouraud shading.
       */
      Gouraud =   0x2,

      /** Phong-Shading
       */
      Phong = 0x3,

      /** Phong-Blinn-Shading
       */
      Blinn = 0x4,

      /** Toon-Shading per pixel
       *
       *  Also known as 'comic' shader.
       */
      Toon = 0x5,

      /** OrenNayar-Shading per pixel
       *
       *  Extension to standard Lambertian shading, taking the
       *  roughness of the material into account
       */
      OrenNayar = 0x6,

      /** Minnaert-Shading per pixel
       *
       *  Extension to standard Lambertian shading, taking the
       *  "darkness" of the material into account
       */
      Minnaert = 0x7,

      /** CookTorrance-Shading per pixel
       *
       *  Special shader for metallic surfaces.
       */
      CookTorrance = 0x8,

      /** No shading at all. Constant light influence of 1.0.
       */
      NoShading = 0x9,

      /** Fresnel shading
      */
      Fresnel = 0xa
   }

   // ---------------------------------------------------------------------------
   /** @brief Defines some mixed flags for a particular texture.
     *
     *  Usually you'll instruct your cg artists how textures have to look like ...
     *  and how they will be processed in your application. However, if you use
     *  Assimp for completely generic loading purposes you might also need to
     *  process these flags in order to display as many 'unknown' 3D models as
     *  possible correctly.
     *
     *  This corresponds to the #AI_MATKEY_TEXFLAGS property.
     */
   enum aiTextureFlags : uint {
     /** The texture's color values have to be inverted (componentwise 1-n)
      */
     Invert = 0x1,

     /** Explicit request to the application to process the alpha channel
      *  of the texture.
      *
      *  Mutually exclusive with #aiTextureFlags_IgnoreAlpha. These
      *  flags are set if the library can say for sure that the alpha
      *  channel is used/is not used. If the model format does not
      *  define this, it is left to the application to decide whether
      *  the texture alpha channel - if any - is evaluated or not.
      */
     UseAlpha = 0x2,

     /** Explicit request to the application to ignore the alpha channel
      *  of the texture.
      *
      *  Mutually exclusive with #aiTextureFlags_UseAlpha.
      */
      IgnoreAlpha = 0x4
   }


   // ---------------------------------------------------------------------------
   /** @brief Defines alpha-blend flags.
    *
    *  If you're familiar with OpenGL or D3D, these flags aren't new to you.
    *  The define *how* the final color value of a pixel is computed, basing
    *  on the previous color at that pixel and the new color value from the
    *  material.
    *  The blend formula is:
    *  @code
    *    SourceColor * SourceBlend + DestColor * DestBlend
    *  @endcode
    *  where <DestColor> is the previous color in the framebuffer at this
    *  position and <SourceColor> is the material colro before the transparency
    *  calculation.<br>
    *  This corresponds to the #AI_MATKEY_BLEND_FUNC property.
   */
   enum aiBlendMode :uint {
      /**
       * Formula:
       *  @code
       *  SourceColor*SourceAlpha + DestColor*(1-SourceAlpha)
       *  @endcode
       */
      Default = 0x0,

      /** Additive blending
       *
       *  Formula:
       *  @code
       *  SourceColor*1 + DestColor*1
       *  @endcode
       */
      Additive = 0x1
   };

   // ---------------------------------------------------------------------------
   /** Defines how an UV channel is transformed.
   *
   *  This is just a helper structure for the AI_MATKEY_UVTRANSFORM key.
   *  See its documentation for more details.
   */
   struct aiUVTransform {
   align ( 1 ) :
      /** Translation on the u and v axes.
       *
       *  The default value is (0|0).
       */
      aiVector2D mTranslation;

      /** Scaling on the u and v axes.
       *
       *  The default value is (1|1).
       */
      aiVector2D mScaling;

      /** Rotation - in counter-clockwise direction.
       *
       *  The rotation angle is specified in radians. The
       *  rotation center is 0.5f|0.5f. The default value
       *  is 0.f.
       */
      float mRotation;
   }

   // ---------------------------------------------------------------------------
   /** @brief A very primitive RTTI system to store the data type of a
    *         material property.
    */
   enum aiPropertyTypeInfo : uint {
      /** Array of single-precision (32 Bit) floats
       *
       * It is possible to use aiGetMaterialInteger[Array]() (or the C++-API
       * aiMaterial::Get()) to query properties stored in floating-point format.
       * The material system performs the type conversion automatically.
       */
      Float = 0x1,

      /** The material property is an aiString.
       *
       * Arrays of strings aren't possible, aiGetMaterialString() (or the
       * C++-API aiMaterial::Get()) *must* be used to query a string property.
       */
      String = 0x3,

      /** Array of (32 bit) integers
       *
       *  It is possible to use aiGetMaterialFloat[Array]() (or the C++-API
       *  aiMaterial::Get()) to query properties stored in integer format.
       *  The material system performs the type conversion automatically.
       */
      Integer = 0x4,

      /** Simple binary buffer, content undefined. Not convertible to anything.
       */
      Buffer = 0x5
   }

   // ---------------------------------------------------------------------------
   /** @brief Data structure for a single material property
    *
    *  As an user, you'll probably never need to deal with this data structure.
    *  Just use the provided aiGetMaterialXXX() or aiMaterial::Get() family
    *  of functions to query material properties easily. Processing them
    *  manually is faster, but it is not the recommended way. It isn't worth
    *  the effort. <br>
    *  Material property names follow a simple scheme:
    *  @code
    *    $<name>
    *    ?<name>
    *       A public property, there must be corresponding AI_MATKEY_XXX define
    *       2nd: Public, but ignored by the #aiProcess_RemoveRedundantMaterials
    *       post-processing step.
    *    ~<name>
    *       A temporary property for internal use.
    *  @endcode
    *  @see aiMaterial
    */
   struct aiMaterialProperty {
      /** Specifies the name of the property (key)
       *  Keys are generally case insensitive.
       */
      aiString mKey;

      /** Textures: Specifies the exact usage semantic.
       *  For non-texture properties, this member is always 0
       *  (or, better-said, #aiTextureType_NONE).
       */
      uint mSemantic;

      /** Textures: Specifies the index of the texture
       *  For non-texture properties, this member is always 0.
       */
      uint mIndex;

      /** Size of the buffer mData is pointing to, in bytes.
       *  This value may not be 0.
       */
      uint mDataLength;

      /** Type information for the property.
       *
       * Defines the data layout inside the data buffer. This is used
       * by the library internally to perform debug checks and to
       * utilize proper type conversions.
       * (It's probably a hacky solution, but it works.)
       */
      aiPropertyTypeInfo mType;

      /** Binary buffer to hold the property's value
       * The size of the buffer is always mDataLength.
       */
      char* mData;
   }

   // ---------------------------------------------------------------------------
   /** @brief Data structure for a material
    *
    *  Material data is stored using a key-value structure. A single key-value
    *  pair is called a 'material property'. C++ users should use the provided
    *  member functions of aiMaterial to process material properties, C users
    *  have to stick with the aiMaterialGetXXX family of unbound functions.
    *  The library defines a set of standard keys (AI_MATKEY_XXX).
    */
   struct aiMaterial {
      /** List of all material properties loaded.
      */
      aiMaterialProperty** mProperties;

      /** Number of properties loaded
      */
      uint mNumProperties;
      uint mNumAllocated;
   }


   // ---------------------------------------------------------------------------
   char* AI_MATKEY_NAME = "?mat.name";
   char* AI_MATKEY_TWOSIDED = "$mat.twosided";
   char* AI_MATKEY_SHADING_MODEL = "$mat.shadingm";
   char* AI_MATKEY_ENABLE_WIREFRAME = "$mat.wireframe";
   char* AI_MATKEY_BLEND_FUNC = "$mat.blend";
   char* AI_MATKEY_OPACITY = "$mat.opacity";
   char* AI_MATKEY_BUMPSCALING = "$mat.bumpscaling";
   char* AI_MATKEY_SHININESS = "$mat.shininess";
   char* AI_MATKEY_SHININESS_STRENGTH = "$mat.shinpercent";
   char* AI_MATKEY_REFRACTI = "$mat.refracti";
   char* AI_MATKEY_COLOR_DIFFUSE = "$clr.diffuse";
   char* AI_MATKEY_COLOR_AMBIENT = "$clr.ambient";
   char* AI_MATKEY_COLOR_SPECULAR = "$clr.specular";
   char* AI_MATKEY_COLOR_EMISSIVE = "$clr.emissive";
   char* AI_MATKEY_COLOR_TRANSPARENT = "$clr.transparent";
   char* AI_MATKEY_COLOR_REFLECTIVE = "$clr.reflective";
   char* AI_MATKEY_GLOBAL_BACKGROUND_IMAGE = "?bg.global";

   // Pure key names for all texture-related properties
   char* _AI_MATKEY_TEXTURE_BASE = "$tex.file";
   char* _AI_MATKEY_UVWSRC_BASE = "$tex.uvwsrc";
   char* _AI_MATKEY_TEXOP_BASE = "$tex.op";
   char* _AI_MATKEY_MAPPING_BASE = "$tex.mapping";
   char* _AI_MATKEY_TEXBLEND_BASE = "$tex.blend";
   char* _AI_MATKEY_MAPPINGMODE_U_BASE = "$tex.mapmodeu";
   char* _AI_MATKEY_MAPPINGMODE_V_BASE = "$tex.mapmodev";
   char* _AI_MATKEY_TEXMAP_AXIS_BASE = "$tex.mapaxis";
   char* _AI_MATKEY_UVTRANSFORM_BASE = "$tex.uvtrafo";
   char* _AI_MATKEY_TEXFLAGS_BASE = "$tex.flags";

   // ---------------------------------------------------------------------------
   // Functions have been moved into assimp.api.
}
