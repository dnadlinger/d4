module assimp.material;

import assimp.types;

extern ( C ) {
   // Default material name
   char* AI_DEFAULT_MATERIAL_NAME = "aiDefaultMat";

   // ---------------------------------------------------------------------------
   /** Defines type identifiers for use within the material system.
   *
   */
   enum aiPropertyTypeInfo : uint {
      /** Array of single-precision floats
      */
      Float = 0x1,

      /** aiString data structure
      */
      String = 0x3,

      /** Array of Integers
      */
      Integer = 0x4,

      /** Simple binary buffer
      */
      Buffer = 0x5
   }

   // ---------------------------------------------------------------------------
   /** Defines how the Nth texture is combined with all previous textures.
   *
   */
   enum aiTextureOp : uint {
      /** T = T1 * T2
      */
      Multiply = 0x0,

      /** T = T1 + T2
      */
      Add = 0x1,

      /** T = T1 - T2
      */
      Subtract = 0x2,

      /** T = T1 / T2
      */
      Divide = 0x3,

      /** T = (T1 + T2) - (T1 * T2)
      */
      SmoothAdd = 0x4,

      /** T = T1 + (T2-0.5)
      */
      SignedAdd = 0x5
   }

   // ---------------------------------------------------------------------------
   /** Defines how UV coordinates beyond the valid range are handled.
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
   /** Defines how the mapping coords for a texture are generated.
   *
   *  See the AI_MATKEY_MAPPING property for more details
   */
   enum aiTextureMapping : uint {
      /** The mapping coordinates are taken from an UV channel.
      *
      *  The AI_MATKEY_UVSRC key specifies from which (remember,
      *  meshes can have more than one UV channel).
      */
      UV = 0x0 ,

      /** Spherical mapping
      */
      SPHERE = 0x1,

      /** Cylindrical mapping
      */
      CYLINDER = 0x2,

      /** Cubic mapping
      */
      BOX = 0x3,

      /** Planar mapping
      */
      PLANE = 0x4,

      /** Undefined mapping. Have fun.
      */
      OTHER = 0x5
   }

   // ---------------------------------------------------------------------------
   /** Defines which mesh axes are used to construct the projection shape
   *  for non-UV mappings around the model.
   *
   *  This corresponds to the AI_MATKEY_TEXMAP_AXIS property.
   */
   enum aiAxis : uint {
      X = 0x0,
      Y = 0x1,
      Z = 0x2
   }

   // ---------------------------------------------------------------------------
   /** Defines the purpose of a texture
   */
   enum aiTextureType : uint {
      /** The texture is combined with the result of the diffuse
      *  lighting equation.
      */
      DIFFUSE = 0x0,

      /** The texture is combined with the result of the specular
      *  lighting equation.
      */
      SPECULAR = 0x1,

      /** The texture is combined with the result of the ambient
      *  lighting equation.
      */
      AMBIENT = 0x2,

      /** The texture is added to the result of the lighting
      *  calculation. It isn't influenced by any lighting.
      */
      EMISSIVE = 0x3,

      /** The texture is a height map and serves as input for
      *  a normal map generator.
      */
      HEIGHT = 0x4,

      /** The texture is a (tangent space) normal-map.
      *
      *  If the normal map does also contain a height channel
      *  for use with techniques such as Parallax Occlusion Mapping
      *  it is registered once as a normalmap.
      */
      NORMALS = 0x5,

      /** The texture defines the glossiness of the material.
      *
      *  The glossiness is in fact the exponent of the specular
      *  lighting equation. Normally there is a conversion
      *  function define to map the linear color values in the
      *  texture to a suitable exponent. Have fun.
      */
      SHININESS = 0x6,

      /** The texture defines a per-pixel opacity.
      *
      *  Normally 'white' means opaque and 'black' means
      *  'transparency'. Or quite the opposite. Have fun.
      */
      OPACITY = 0x7
   }

   // ---------------------------------------------------------------------------
   /** Defines all shading models supported by the library
   *
   *  @note The list of shading modes has been taken from Blender3D.
   *  See Blender3D documentation for more information. The API does
   *  not distinguish between "specular" and "diffuse" shaders (thus the
   *  specular term for diffuse shading models like Oren-Nayar remains
   *  undefined)
   */
   enum aiShadingMode : uint {
      /** Flat shading. Shading is done on per-face base,
      *  diffuse only.
      */
      Flat = 0x1,

      /** Diffuse gouraud shading. Shading on per-vertex base
      */
      Gouraud =   0x2,

      /** Diffuse/Specular Phong-Shading
      *
      *  Shading is applied on per-pixel base. This is the
      *  slowest algorithm, but generates the best results.
      */
      Phong = 0x3,

      /** Diffuse/Specular Phong-Blinn-Shading
      *
      *  Shading is applied on per-pixel base. This is a little
      *  bit faster than phong and in some cases even
      *  more realistic
      */
      Blinn = 0x4,

      /** Toon-Shading per pixel
      *
      *  Shading is applied on per-pixel base. The output looks
      *  like a comic. Often combined with edge detection.
      */
      Toon = 0x5,

      /** OrenNayar-Shading per pixel
      *
      *  Extension to standard lambertian shading, taking the
      *  roughness of the material into account
      *
      */
      OrenNayar = 0x6,

      /** Minnaert-Shading per pixel
      *
      *  Extension to standard lambertian shading, taking the
      *  "darkness" of the material into account
      */
      Minnaert = 0x7,

      /** CookTorrance-Shading per pixel
      */
      CookTorrance = 0x8,

      /** No shading at all
      */
      NoShading = 0x9,

      /** Fresnel shading
      */
      Fresnel = 0xa
   }


   // ---------------------------------------------------------------------------
   /** Defines how an UV channel is transformed.
   *
   *  This is just a helper structure for the AI_MATKEY_UVTRANSFORM key.
   *  See its documentation for more details.
   */
   struct aiUVTransform {
   align ( 1 ) :
      /** Translation on the u and v axes.
      */
      aiVector2D mTranslation;

      /** Scaling on the u and v axes.
      */
      aiVector2D mScaling;

      /** Rotation - in counter-clockwise direction.
      *
      *  The rotation angle is specified in radians. The
      *  rotation center is 0.5f|0.5f.
      */
      float mRotation;
   }

   // ---------------------------------------------------------------------------
   /** Data structure for a single property inside a material
   *
   *  @see aiMaterial
   */
   struct aiMaterialProperty {
      /** Specifies the name of the property (key)
      *
      * Keys are case insensitive.
      */
      aiString mKey;

      /** Textures: Specifies the exact usage semantic
      */
      uint mSemantic;

      /** Textures: Specifies the index of the texture
      *
      *  Textures are counted per-type.
      */
      uint mIndex;

      /**  Size of the buffer mData is pointing to, in bytes
      * This value may not be 0.
      */
      uint mDataLength;

      /** Type information for the property.
      *
      * Defines the data layout inside the
      * data buffer. This is used by the library
      * internally to perform debug checks.
      */
      aiPropertyTypeInfo mType;

      /**  Binary buffer to hold the property's value
      *
      * The buffer has no terminal character. However,
      * if a string is stored inside it may use 0 as terminal,
      * but it would be contained in mDataLength. This member
      * is never 0
      */
      char* mData;
   }

   // ---------------------------------------------------------------------------
   /** Data structure for a material
   *
   *  Material data is stored using a key-value structure, called property
   *  (to guarant that the system is maximally flexible).
   *  The library defines a set of standard keys (AI_MATKEY) which should be
   *  enough for nearly all purposes.
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
   /** @def AI_MATKEY_NAME
   *  Defines the name of the material
   * <br>
   * <b>Type:</b> string (aiString)<br>
   * <b>Default value:</b> none <br>
   */
   char* AI_MATKEY_NAME = "$mat.name";


   /** @def AI_MATKEY_TWOSIDED
   *  Indicates that the material must be rendered two-sided
   * <br>
   * <b>Type:</b> int <br>
   * <b>Default value:</b> 0 <br>
   */
   char* AI_MATKEY_TWOSIDED = "$mat.twosided";


   /** @def AI_MATKEY_SHADING_MODE
   *  Defines the shading model to use (aiShadingMode)
   * <br>
   * <b>Type:</b> int (aiShadingMode)<br>
   * <b>Default value:</b> aiShadingMode_Gouraud <br>
   */
   char* AI_MATKEY_SHADING_MODEL = "$mat.shadingm";


   /** @def AI_MATKEY_ENABLE_WIREFRAM
   *  Integer property. 1 to enable wireframe for rendering
   * <br>
   * <b>Type:</b> int <br>
   * <b>Default value:</b> 0 <br>
   */
   char* AI_MATKEY_ENABLE_WIREFRAME = "$mat.wireframe";


   /** @def AI_MATKEY_OPACITY
   *  Defines the base opacity of the material
   * <br>
   * <b>Type:</b> float<br>
   * <b>Default value:</b> 1.0f <br>
   */
   char* AI_MATKEY_OPACITY = "$mat.opacity";


   /** @def AI_MATKEY_BUMPSCALING
   *  Defines the height scaling of a bump map (for stuff like Parallax
   *  Occlusion Mapping)
   * <br>
   * <b>Type:</b> float<br>
   * <b>Default value:</b> 1.0f <br>
   */
   char* AI_MATKEY_BUMPSCALING = "$mat.bumpscaling";


   /** @def AI_MATKEY_SHININESS
   *  Defines the base shininess of the material
   *  This is the exponent of the phong shading equation.
   * <br>
   * <b>Type:</b> float<br>
   * <b>Default value:</b> 0.0f <br>
   */
   char* AI_MATKEY_SHININESS = "$mat.shininess";


   /** @def AI_MATKEY_SHININESS_STRENGTH
   * Defines the strength of the specular highlight.
   * This is simply a multiplier to the specular color of a material
   * <br>
   * <b>Type:</b> float<br>
   * <b>Default value:</b> 1.0f <br>
   */
   char* AI_MATKEY_SHININESS_STRENGTH = "$mat.shinpercent";

   /** @def AI_MATKEY_REFRACTI
   * Index of refraction of the material. This is used by some shading models,
   * e.g. Cook-Torrance. The value is the ratio of the speed of light in a
   * vacuum to the speed of light in the material (always >= 1.0 in the real world).
   * <br>
   * <b>Type:</b> float<br>
   * <b>Default value:</b> 1.0f <br>
   */
   char* AI_MATKEY_REFRACTI = "$mat.refracti";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_COLOR_DIFFUSE
   *  Defines the diffuse base color of the material
   * <br>
   * <b>Type:</b> color (aiColor4D or aiColor3D)<br>
   * <b>Default value:</b> 0.0f|0.0f|0.0f|1.0f <br>
   */
   char* AI_MATKEY_COLOR_DIFFUSE = "$clr.diffuse";

   /** @def AI_MATKEY_COLOR_AMBIENT
   *  Defines the ambient base color of the material
   * <br>
   * <b>Type:</b> color (aiColor4D or aiColor3D)<br>
   * <b>Default value:</b> 0.0f|0.0f|0.0f|1.0f <br>
   */
   char* AI_MATKEY_COLOR_AMBIENT = "$clr.ambient";

   /** @def AI_MATKEY_COLOR_SPECULAR
   *  Defines the specular base color of the material
   * <br>
   * <b>Type:</b> color (aiColor4D or aiColor3D)<br>
   * <b>Default value:</b> 0.0f|0.0f|0.0f|1.0f <br>
   */
   char* AI_MATKEY_COLOR_SPECULAR = "$clr.specular";

   /** @def AI_MATKEY_COLOR_EMISSIVE
   *  Defines the emissive base color of the material
   * <br>
   * <b>Type:</b> color (aiColor4D or aiColor3D)<br>
   * <b>Default value:</b> 0.0f|0.0f|0.0f|1.0f <br>
   */
   char* AI_MATKEY_COLOR_EMISSIVE = "$clr.emissive";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_TEXTURE
   * Parameters: type, N<br>
   * Specifies the path to the <N>th texture of type <type>.
   * This can either be a path to the texture or a string of the form '*<i>'
   * where i is an index into the array of embedded textures that has been
   * imported along with the scene. See aiTexture for more details.
   * <b>Type:</b> String<br>
   * <b>Default value to be assumed if this key isn't there:</b>n/a<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_TEXTURE = "$tex.file";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_UVWSRC
   * Parameters: type, N<br>
   * Specifies which UV channel is used as source for the mapping coordinates
   * of the <N>th texture of type <type>.
   * <b>Type:</b> int<br>
   * <b>Default value to be assumed if this key isn't there:</b>0<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)  and
   * AI_MATKEY_TEXTURE_MAPPING(type,N) == UV<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_UVWSRC = "$tex.uvwsrc";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_TEXOP
   * Parameters: type, N<br>
   * Specifies how the of the <N>th texture of type <type> is combined with
   * the result of all color values from all previous textures combined.
   * <b>Type:</b> int (aiTextureOp)<br>
   * <b>Default value to be assumed if this key isn't there:</b>multiply<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_TEXOP = "$tex.op";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_MAPPING
   * Parameters: type, N<br>
   * Specifies how the of the <N>th texture of type <type>is mapped.
   * <br>
   * <b>Type:</b> int (aiTextureMapping)<br>
   * <b>Default value to be assumed if this key isn't there:</b>UV<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_MAPPING = "$tex.mapping";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_TEXBLEND (
   * Parameters: type, N<br>
   * Specifies the strength of the <N>th texture of type <type>. This is just
   * a multiplier for the texture's color values.
   * <br>
   * <b>Type:</b> float<br>
   * <b>Default value to be assumed if this key isn't there:</b> 1.f<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_TEXBLEND = "$tex.blend";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_MAPPINGMODE_U
   * Parameters: type, N<br>
   * Specifies the texture mapping mode for the <N>th texture of type <type> in
   * the u (x) direction
   * <br>
   * <b>Type:</b> int (aiTextureMapMode)<br>
   * <b>Default value:</b> aiTextureMapMode_Wrap<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_MAPPINGMODE_U = "$tex.mapmodeu";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_MAPPINGMODE_V
   * Parameters: type, N<br>
   * Specifies the texture mapping mode for the <N>th texture of type <type> in
   * the w (z) direction
   * <br>
   * <b>Type:</b> int (aiTextureMapMode)<br>
   * <b>Default value:</b> aiTextureMapMode_Wrap<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_MAPPINGMODE_V = "$tex.mapmodev";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_MAPPINGMODE_W
   * Parameters: type, N<br>
   * Specifies the texture mapping mode for the <N>th texture of type <type> in
   * the w (z) direction
   * <br>
   * <b>Type:</b> int (aiTextureMapMode)<br>
   * <b>Default value:</b> aiTextureMapMode_Wrap<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N)<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_MAPPINGMODE_W = "$tex.mapmodew";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_TEXMAP_AXIS
   * Parameters: type, N<br>
   * Specifies the main mapping axis <N>th texture of type <type>.
   * This applies to non-UV mapped textures. For spherical, cylindrical and
   * planar this is the main axis of the corresponding geometric shape.
   * <br>
   * <b>Type:</b> int (aiAxis)<br>
   * <b>Default value:</b> aiAxis_Z<br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N) and
   * AI_MATKEY_TEXTURE_MAPPING(type,N) != UV<br>
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_TEXMAP_AXIS = "$tex.mapaxis";

   // ---------------------------------------------------------------------------
   /** @def AI_MATKEY_UVTRANSFORM
   * Parameters: type, N<br>
   * Specifies how the UV mapping coordinates for the<N>th texture of type
   * <type> are transformed before they're used for mapping. This is an array
   * of five floats - use the aiUVTransform structure for simplicity.
   * <br>
   * <b>Type:</b> Array of 5 floats<br>
   * <b>Default value:</b> 0.f,0.f,1.f,1.f,0.f <br>
   * <b>Requires:</b> AI_MATKEY_TEXTURE(type,N) and
   * AI_MATKEY_TEXTURE_MAPPING(type,N) == UV<br>
   * <b>Note:</b>Transformed 3D texture coordinates are not supported
   */
   // ---------------------------------------------------------------------------
   char* AI_MATKEY_UVTRANSFORM = "$tex.uvtrafo";

   char* AI_MATKEY_ORENNAYAR_ROUGHNESS   = "$shading.orennayar.roughness";
   char* AI_MATKEY_MINNAERT_DARKNESS     = "$shading.minnaert.darkness";
   char* AI_MATKEY_COOK_TORRANCE_PARAM   = "$shading.cookt.param";

   /** @def AI_MATKEY_GLOBAL_BACKGROUND_IMAGE
   *  Global property defined by some loaders. Contains the path to
   *  the image file to be used as background image.
   */
   char* AI_MATKEY_GLOBAL_BACKGROUND_IMAGE = "$global.bg.image2d";

   // Functions have been moved into assimp.api.
}