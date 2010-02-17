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

module d4.renderer.WireframeRasterizer;

import tango.math.Math : abs, rndint, min;
import d4.math.Color;
import d4.math.Vector4;
import d4.renderer.RasterizerBase;

/**
 * A simple wireframe rasterizer which connects the vertices with
 * Bresenham-generated lines.
 *
 * This rasterizer does not use or respect the z buffer!
 */
final class WireframeRasterizer( alias Shader, ShaderParams... ) :
   RasterizerBase!( false, Shader, ShaderParams ) {
protected:
   void drawTriangle( Vector4 pos0, VertexVariables vars0, Vector4 pos1,
      VertexVariables vars1, Vector4 pos2, VertexVariables vars2 ) {
      // Use either one to get the color, the variables are not interpolated anyway.
      Color color = pixelShader( vars0 );
      drawLine( pos0, pos1, color );
      drawLine( pos1, pos2, color );
      drawLine( pos2, pos0, color );
   }

private:
   /**
    * Helper function to draw a line on the screen using the
    * Bresenham line algorithm.
    */
   void drawLine( Vector4 startPos, Vector4 endPos, Color color ) {
      // »Hack« to display the line even if it lies exactly on the right or
      // bottom viewport border (looks nicer when demonstrating clipping).
      int lastX = m_colorBuffer.width - 1;
      int lastY = m_colorBuffer.height - 1;

      int startX = min( rndint( startPos.x ), lastX );
      int startY = min( rndint( startPos.y ), lastY );

      int endX = min( rndint( endPos.x ), lastX );
      int endY = min( rndint( endPos.y ), lastY );

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
            m_colorBuffer.setPixel( x, y, color );
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
            m_colorBuffer.setPixel( x, y, color );
            error += errorPerPixel;

            if ( error > 0 ) {
               x += xStep;
               error += errorResetStep;
            }

            y += yStep;
         }
      }
   }
}
