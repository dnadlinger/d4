module d4.util.SdlRendererApplication;

import tango.math.Math : PI;
import d4.renderer.Renderer;
import d4.util.Key;
import d4.util.SdlApplication;

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
   }

   override void handleKeyUp( Key key ) {
      super.handleKeyUp( key );

      switch ( key ) {
         case Key.c:
            renderer().backfaceCulling = cast( BackfaceCulling )
               ( ( renderer().backfaceCulling + 1 ) % ( BackfaceCulling.max + 1 ) );
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
   Renderer m_renderer;
}
