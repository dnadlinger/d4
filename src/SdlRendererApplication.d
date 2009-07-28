module SdlRendererApplication;

import tango.math.Math : PI;
import d4.renderer.Renderer;
import d4.util.Key;
import d4.util.SdlApplication;

/**
 * The available shading modes.
 */
enum ShadingMode {
   FLAT,
   GOURAUD,
   GOURAUD_TEXTURED
}

abstract class SdlRendererApplication : SdlApplication {
public:
   this( char[][] args ) {
      super( args );
   }

protected:
   abstract override void init() {
      super.init();

      m_renderer = new Renderer( screen() );
      m_renderer.backfaceCulling = BackfaceCulling.CULL_CW;
      m_renderer.setProjection( PI / 3, 0.5f, 1000f );

      // Enable everything by default.
      m_shadingMode = ShadingMode.GOURAUD_TEXTURED;
      updateShadingMode();
   }

   override void handleKeyUp( Key key ) {
      super.handleKeyUp( key );

      switch ( key ) {
         case Key.y:
         case Key.z:
            m_shadingMode = cast( ShadingMode )( ( m_shadingMode + 1 ) % ( m_shadingMode.max + 1 ) );
            updateShadingMode();
            break;
         case Key.x:
            m_renderer.forceWireframe = !m_renderer.forceWireframe;
            break;
         case Key.c:
            m_renderer.backfaceCulling = cast( BackfaceCulling )
               ( ( m_renderer.backfaceCulling + 1 ) % ( BackfaceCulling.max + 1 ) );
            break;
         default:
            // Do nothing.
            break;
      }
   }

   final Renderer renderer() {
      return m_renderer;
   }

private:
   void updateShadingMode() {
      switch ( m_shadingMode ) {
         case ShadingMode.FLAT:
            m_renderer.forceFlatShading = true;
            m_renderer.skipTextures = true;
            break;
         case ShadingMode.GOURAUD:
            m_renderer.forceFlatShading = false;
            m_renderer.skipTextures = true;
            break;
         case ShadingMode.GOURAUD_TEXTURED:
            m_renderer.forceFlatShading = false;
            m_renderer.skipTextures = false;
            break;
      }
   }

   Renderer m_renderer;
   ShadingMode m_shadingMode;
}
