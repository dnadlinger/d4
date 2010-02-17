/*
 * Copyright © 2010, klickverbot <klickverbot@gmail.com>.
 *
 * This file is part of d4, which is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * d4 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * d4. If not, see <http://www.gnu.org/licenses/>.
 */

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
