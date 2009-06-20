module assimp.scene;

import assimp.mesh;
import assimp.material;
import assimp.texture;
import assimp.types;

extern ( C ) {
   struct aiLight;
   struct aiCamera;
   struct aiAnimation;

   // ---------------------------------------------------------------------------
   /** A node in the imported hierarchy.
   *
   * Each node has name, a parent node (except for the root node),
   * a transformation relative to its parent and possibly several child nodes.
   * Simple file formats don't support hierarchical structures, for these formats
   * the imported scene does consist of only a single root node with no childs.
   */
   // ---------------------------------------------------------------------------
   struct aiNode {
      /** The name of the node.
       *
       * The name might be empty (length of zero) but all nodes which
       * need to be accessed afterwards by bones or anims are usually named.
       * Multiple nodes may have the same name, but nodes which are accessed
       * by bones (see #aiBone and #aiMesh::mBones) *must* be unique.
       *
       * Cameras and lights are assigned to a specific node name - if there
       * are multiple nodes with this name, they're assigned to each of them.
       *
       * There are no limitations regarding the characters contained in
       * this text. You should be able to handle stuff like whitespace, tabs,
       * linefeeds, quotation marks, ampersands, ... .
       */
      aiString mName;

      /** The transformation relative to the node's parent. */
      aiMatrix4x4 mTransformation;

      /** Parent node. NULL if this node is the root node. */
      aiNode* mParent;

      /** The number of child nodes of this node. */
      uint mNumChildren;

      /** The child nodes of this node. NULL if mNumChildren is 0. */
      aiNode** mChildren;

      /** The number of meshes of this node. */
      uint mNumMeshes;

      /** The meshes of this node. Each entry is an index into the mesh */
      uint* mMeshes;
   }


   // ---------------------------------------------------------------------------
   enum {
      /** @def AI_SCENE_FLAGS_INCOMPLETE
      * Specifies that the scene data structure that was imported is not complete.
      * This flag bypasses some internal validations and allows the import
      * of animation skeletons, material libraries or camera animation paths
      * using Assimp. Most applications won't support such data.
      */
      AI_SCENE_FLAGS_INCOMPLETE = 0x1,

      /** @def AI_SCENE_FLAGS_VALIDATED
      * This flag is set by the validation postprocess-step (aiPostProcess_ValidateDS)
      * if the validation is successful. In a validated scene you can be sure that
      * any cross references in the data structure (e.g. vertex indices) are valid.
      */
      AI_SCENE_FLAGS_VALIDATED = 0x2,

      /** @def AI_SCENE_FLAGS_VALIDATION_WARNING
      * This flag is set by the validation postprocess-step (aiPostProcess_ValidateDS)
      * if the validation is successful but some issues have been found.
      * This can for example mean that a texture that does not exist is referenced
      * by a material or that the bone weights for a vertex don't sum to 1.0 ... .
      * In most cases you should still be able to use the import. This flag could
      * be useful for applications which don't capture Assimp's log output.
      */
      AI_SCENE_FLAGS_VALIDATION_WARNING = 0x4,

      /** @def AI_SCENE_FLAGS_NON_VERBOSE_FORMAT
      * This flag is currently only set by the aiProcess_JoinIdenticalVertices step.
      * It indicates that the vertices of the output meshes aren't in the internal
      * verbose format anymore. In the verbose format all vertices are unique,
      * no vertex is ever referenced by more than one face.
      */
      AI_SCENE_FLAGS_NON_VERBOSE_FORMAT = 0x8,

      /** @def AI_SCENE_FLAGS_TERRAIN
       * Denotes pure height-map terrain data. Pure terrains usually consist of quads,
       * sometimes triangles, in a regular grid. The x,y coordinates of all vertex
       * positions refer to the x,y coordinates on the terrain height map, the z-axis
       * stores the elevation at a specific point.
       *
       * TER (Terragen) and HMP (3D Game Studio) are height map formats.
       * @note Assimp is probably not the best choice for loading *huge* terrains -
       * fully triangulated data takes extremely much free store and should be avoided
       * as long as possible (typically you'll do the triangulation when you actually
       * need to render it).
       */
      AI_SCENE_FLAGS_TERRAIN = 0x10
   }

   // ---------------------------------------------------------------------------
   /** The root structure of the imported data.
   *
   *  Everything that was imported from the given file can be accessed from here.
   *  Objects of this class are generally maintained and owned by Assimp, not
   *  by the caller. You shouldn't want to instance it, nor should you ever try to
   *  delete a given scene on your own.
   */
   // ---------------------------------------------------------------------------
   struct aiScene {
      /** Any combination of the AI_SCENE_FLAGS_XXX flags. By default
      * this value is 0, no flags are set. Most applications will
      * want to reject all scenes with the AI_SCENE_FLAGS_INCOMPLETE
      * bit set.
      */
      uint mFlags;


      /** The root node of the hierarchy.
      *
      * There will always be at least the root node if the import
      * was successful (and no special flags have been set).
      * Presence of further nodes depends on the format and content
      * of the imported file.
      */
      aiNode* mRootNode;



      /** The number of meshes in the scene. */
      uint mNumMeshes;

      /** The array of meshes.
      *
      * Use the indices given in the aiNode structure to access
      * this array. The array is mNumMeshes in size. If the
      * AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
      * be at least ONE material.
      */
      aiMesh** mMeshes;



      /** The number of materials in the scene. */
      uint mNumMaterials;

      /** The array of materials.
      *
      * Use the index given in each aiMesh structure to access this
      * array. The array is mNumMaterials in size. If the
      * AI_SCENE_FLAGS_INCOMPLETE flag is not set there will always
      * be at least ONE material.
      */
      aiMaterial** mMaterials;



      /** The number of animations in the scene. */
      uint mNumAnimations;

      /** The array of animations.
      *
      * All animations imported from the given file are listed here.
      * The array is mNumAnimations in size.
      */
      aiAnimation** mAnimations;



      /** The number of textures embedded into the file */
      uint mNumTextures;

      /** The array of embedded textures.
      *
      * Not many file formats embed their textures into the file.
      * An example is Quake's MDL format (which is also used by
      * some GameStudio versions)
      */
      aiTexture** mTextures;


      /** The number of light sources in the scene.
      *
      * Light sources are fully optional, in most cases this attribute
      * will be 0.
      */
      uint mNumLights;

      /** The array of light sources.
      *
      * All light sources imported from the given file are
      * listed here. The array is mNumLights in size.
      */
      aiLight** mLights;


      /** The number of cameras in the scene.
       *
       * Cameras are fully optional, in most cases this attribute
       * will be 0.
       */
      uint mNumCameras;

      /** The array of cameras.
      *
      * All cameras imported from the given file are listed here.
      * The array is mNumCameras in size. The first camera in the
      * array (if existing) is the default camera view into
      * the scene.
      */
      aiCamera** mCameras;
   }
}
