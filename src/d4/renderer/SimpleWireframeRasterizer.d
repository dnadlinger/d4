module d4.renderer.SimpleWireframeRasterizer;

import tango.io.Stdout;
import tango.math.Math : abs;
import d4.math.Color;
import d4.math.Vector3;
import d4.renderer.Rasterizer;
import d4.renderer.Vertex;

class SimpleWireframeRasterizer : Rasterizer {
public:
   void drawTriangle( Vertex v0, Vertex v1, Vertex v2 ) {
      drawLine( v0.position, v1.position, v0.color );
      drawLine( v1.position, v2.position, v1.color );
      drawLine( v2.position, v0.position, v2.color );
   }

private:
   void drawLine( Vector3 startPos, Vector3 endPos, Color color ) {
      int startX = cast( int ) startPos.x;
      int startY = cast( int ) startPos.y;

      int endX = cast( int ) endPos.x;
      int endY = cast( int ) endPos.y;

      int x = startX;
      int y = startY;

      int error;
      int errorPerPixel;
      int errorResetStep;

      int deltaX = abs( endX - startX );
      int deltaY = abs( endY - startY );

      // Check if line is going from the left to the right or the other way round.
      int xStep = ( endX - startX ) > 0 ? 1 : -1;

      // Check if line is going down or up.
      int yStep = ( endY - startY ) > 0 ? 1 : -1;

      // Check if line is going flat (deltaY/deltaX < 1) or steep.
      if ( deltaY < deltaX ) {
         error = -deltaX;
         errorPerPixel = 2 * deltaY;
         errorResetStep = 2 * error;

         while ( x != endX ) {
            m_renderTarget.setPixel( x, y, color );
            error += errorPerPixel;

            if ( error > 0 ) {
               y += yStep;
               error += errorResetStep;
            }

            x += xStep;
         }
      } else {
         error = -deltaY;
         errorPerPixel = 2 * deltaX;
         errorResetStep = 2 * error;

         while ( y != endY ) {
            m_renderTarget.setPixel( x, y, color );
            error += errorPerPixel;

            if ( error > 0 ) {
               x += xStep;
               error += errorResetStep;
            }

            y += yStep;
         }
      }

      m_renderTarget.setPixel( endX, endY, color );
   }
}