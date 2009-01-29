module d4.scene.MaterialManager;

import tango.util.container.HashMap;
import d4.renderer.IRasterizer;
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
   
   void forceWireframe( bool forceWireframe ) {
      m_forceWireframe = forceWireframe;
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
      
      if ( !m_forceWireframe ) {
         rasterizer = material.createRasterizer();
      } else {
         bool oldWireframe = material.wireframe;
         material.wireframe = true;
         rasterizer = material.createRasterizer();
         material.wireframe = oldWireframe;
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
}