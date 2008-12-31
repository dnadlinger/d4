module d4.scene.Material;

import d4.math.Vector3;
import d4.renderer.Renderer;
import d4.renderer.SolidGouraudRasterizer;
import d4.renderer.WireframeRasterizer;
import d4.shader.DefaultShader;
import d4.shader.ColorGouraudShader;
import d4.shader.ColorShader;

class Material {
public:
   this() {
      m_wireframe = false;
      m_useColor = false;
      m_gouraudLighting = false;
   }
   
   void setupRenderer( Renderer renderer ) {
      if ( m_rasterizerId == 0 ) {
         m_rasterizerId = createRasterizer( renderer );
      }
      // FIXME: Bug when used with multiple renderers.
      renderer.useRasterizer( m_rasterizerId );
   }
   
   bool wireframe() {
      return m_wireframe;
   }
   
   void wireframe( bool wireframe ) {
      m_wireframe = wireframe;
      invalidateRasterizer();
   }
   
   bool useColor() {
      return m_wireframe;
   }
   
   void useColor( bool useColor ) {
      m_useColor = useColor;
      invalidateRasterizer();
   }
   
   bool gouraudLighting() {
      return m_gouraudLighting;
   }
   
   void gouraudLighting( bool useGouraudLighting ) {
      m_gouraudLighting = useGouraudLighting;
      invalidateRasterizer();
   }
   
private:
   uint createRasterizer( Renderer renderer ) {
      if ( m_wireframe ) { 
         return renderer.registerRasterizer( new WireframeRasterizer!( DefaultShader )() );
      }
      
      if ( m_useColor ) {
         if ( m_gouraudLighting ) {
            // Simply doing the following does not work:
            // return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, lightDirection )() );
            // 
            // and doing this crashes gdc:
            // auto lightDirection = Vector3( 0, -1, 1 );
            // return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, lightDirection )() );
            return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorGouraudShader, 0, -1, 1 )() );
         } else {
            return renderer.registerRasterizer( new SolidGouraudRasterizer!( ColorShader )() );
         }
      } else {
         if ( m_gouraudLighting ) {
            throw new Exception( "Using gouraud lighting without coloring is currently not supported." );
         } else {
            return renderer.registerRasterizer( new SolidGouraudRasterizer!( DefaultShader )() );
         }
      }
      
   }
   
   void invalidateRasterizer() {
      // TODO: Actually remove the rasterizer from the renderer.
      m_rasterizerId = 0;
   }
   
   uint m_rasterizerId;
   
   bool m_wireframe;
   bool m_useColor;
   bool m_gouraudLighting;
}