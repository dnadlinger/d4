module d4.app.Rendering;

import tango.math.Math : PI;
import d4.app.Key;
import d4.renderer.Renderer;
import d4.util.EnumUtils;

/**
 * Provides a renderer to <code>Application</code>s.
 *
 * The c key toggles the culling mode.
 */
abstract class Rendering( alias Base ) : Base {
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
            renderer().backfaceCulling = step( renderer().backfaceCulling, 1 );
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
