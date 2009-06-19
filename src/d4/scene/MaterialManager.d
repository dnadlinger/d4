module d4.scene.MaterialManager;

import d4.shader.LitSingleColorShader;
import tango.io.Stdout;
import tango.util.container.HashMap;
import d4.renderer.IRasterizer;
import d4.renderer.SolidFlatRasterizer;
import d4.renderer.SolidGouraudRasterizer;
import d4.renderer.Renderer;
import d4.scene.IMaterial;

/**
 * Caches a rasterizer instance for each material and provides global override
 * functionality to force certain rendering modes.
 */
class MaterialManager {
public:
   /**
    * Creates a IMaterialManager-instance for a specific renderer.
    * 
    * Params:
    *     renderer = The target renderer.
    */
   this( Renderer renderer ) {
      m_materialRasterizers = new RasterizerIdMap();
      m_renderer = renderer;
      m_materialCount = 0;

      m_noTextureFlatRasterizer = new SolidFlatRasterizer!( LitSingleColorShader, 0.1, 1, -1, -1 )();
      m_noTextureGouraudRasterizer = new SolidGouraudRasterizer!( LitSingleColorShader, 0.1, 1, -1, -1 )();
   }

   /**
    * Configures the target renderer to use the specified material.
    * 
    * If the material has not been cached yet, it is added to the cache.
    * 
    * Params:
    *     material = The material to activate.
    */
   void activateMaterial( IMaterial material, bool update = false ) {
      if ( !m_materialRasterizers.containsKey( material ) || update ) {
         addMaterial( material );
      }

      m_renderer.useRasterizer( m_materialRasterizers[ material ] );
      m_renderer.activeTextures = material.textures;
   }

   /**
    * The number of registered materials (to obtain statistics and for debugging). 
    */
   uint materialCount() {
      return m_materialCount;
   }

   /**
    * Causes all materials to be rendered as if their wireframe property was set.
    */
   bool forceWireframe() {
      return m_forceWireframe;
   }

   /// ditto
   void forceWireframe( bool forceWireframe ) {
      m_forceWireframe = forceWireframe;
      clearCache();
   }

   /**
    * Causes all materials to be rendered as if gouraud shading was not enabled
    * for them.
    */
   bool forceFlatShading() {
      return m_forceFlatShading;
   }

   /// ditto
   void forceFlatShading( bool forceFlatShading ) {
      m_forceFlatShading = forceFlatShading;
      clearCache();
   }

   /**
    * Replaces all textured materials with a generic textureless one.
    */
   bool skipTextures() {
      return m_skipTextures;
   }

   /// ditto
   void skipTextures( bool skipTextures ) {
      m_skipTextures = skipTextures;
      clearCache();
   }

private:
   /**
    * Adds a material to the material cache.
    * 
    * This is called by activateMaterial if a material has not been cached yet
    * or has to be updated.
    * 
    * Params:
    *     material = The material to cache.
    */
   void addMaterial( IMaterial material ) {
      // Remove the material if it already has been cached.
      if ( m_materialRasterizers.containsKey( material ) ) {
         m_renderer.unregisterRasterizer( m_materialRasterizers[ material ] );
         m_materialRasterizers.removeKey( material );
      }
      
      IRasterizer rasterizer;
      
      if ( m_forceWireframe ) {
         bool oldWireframe = material.wireframe;
         material.wireframe = true;
         rasterizer = material.createRasterizer();
         material.wireframe = oldWireframe;
      } else if ( m_skipTextures && material.textures.length > 0 ) {
         if ( m_forceFlatShading ) {
            rasterizer = m_noTextureFlatRasterizer;
         } else {
            rasterizer = m_noTextureGouraudRasterizer;
         }
      } else if ( m_forceFlatShading ) {
         bool oldGouraud = material.gouraudShading;
         material.gouraudShading = false;
         rasterizer = material.createRasterizer();
         material.gouraudShading = oldGouraud;
      } else {
         rasterizer = material.createRasterizer();
      }

      m_materialRasterizers.add( material, m_renderer.registerRasterizer( rasterizer ) );
      
      ++m_materialCount;
   }
   
   /**
    * Clears the material rasterizer cache,
    */
   void clearCache() {
      foreach ( rasterizerId; m_materialRasterizers ) {
         m_renderer.unregisterRasterizer( rasterizerId );
      }
      m_materialRasterizers.clear();
      m_materialCount = 0;
   }
   
   Renderer m_renderer;
   
   alias HashMap!( IMaterial, uint ) RasterizerIdMap; 
   RasterizerIdMap m_materialRasterizers;
   
   uint m_materialCount;
   
   bool m_forceWireframe;
   bool m_forceFlatShading;
   bool m_skipTextures;
   IRasterizer m_noTextureFlatRasterizer;
   IRasterizer m_noTextureGouraudRasterizer;
}