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
module d4.renderer.SolidRasterizer;

import tango.math.IEEE : RoundingMode, setIeeeRounding;
import tango.math.Math : rndint;
import d4.math.Color;
import d4.math.Vector4;
import d4.renderer.RasterizerBase;

/**
 * A rasterizer which draws solid triangles using the Scanline algorithm.
 *
 * The first template option controlls whether the vertex variables are
 * linearly interpolated (perspective-correct Gouraud shading) or the
 * triangle is drawn using a single color.
 *
 * As in most renderers, the top-left filling convention is used (see e.g. the
 * Microsoft Direct3D documentation for details).
 *
 * Partly inspired by the excellent Muli3D software rasterizer
 * (http://muli3d.sourceforge.net).
 */
final class SolidRasterizer( bool Gouraud, alias Shader, ShaderParams... ) :
   RasterizerBase!( Gouraud, Shader, ShaderParams ) {
protected:
   void drawTriangle( Vector4 pos0, VertexVariables vars0, Vector4 pos1,
      VertexVariables vars1, Vector4 pos2, VertexVariables vars2 ) {
      // Set rounding mode for rndint to make it behave like ceil().
      auto oldRoundingMode = setIeeeRounding( RoundingMode.ROUNDUP );
      scope ( exit ) setIeeeRounding( oldRoundingMode );

      // ---

      // Calculate the triangle »gradients«.
      // The vertex at index 0 is the base vertex for the gradient
      // calculations. In screen space, the y-axis points in the other
      // direction, so we have to negate the y gradients.
      float deltaX1 = pos1.x - pos0.x;
      float deltaX2 = pos2.x - pos0.x;
      float deltaY1 = pos1.y - pos0.y;
      float deltaY2 = pos2.y - pos0.y;

      float invDenominator = 1.f / ( deltaX1 * deltaY2 - deltaX2 * deltaY1 );

      // The procedure is the same for all values.
      float deltaZ1 = pos1.z - pos0.z;
      float deltaZ2 = pos2.z - pos0.z;
      float dzPerDx =  ( deltaZ1 * deltaY2 - deltaZ2 * deltaY1 ) * invDenominator;
      float dzPerDy = -( deltaZ1 * deltaX2 - deltaZ2 * deltaX1 ) * invDenominator;

      float deltaW1 = pos1.w - pos0.w;
      float deltaW2 = pos2.w - pos0.w;
      float dwPerDx =  ( deltaW1 * deltaY2 - deltaW2 * deltaY1 ) * invDenominator;
      float dwPerDy = -( deltaW1 * deltaX2 - deltaW2 * deltaX1 ) * invDenominator;

      static if ( Gouraud ) {
         // Calculate the gradients for the vertex variable too so we can step
         // them in rasterizeScanline() like the other values when doing
         // Gouraud shading.
         VertexVariables deltaVars1 = substract( vars1, vars0 );
         VertexVariables deltaVars2 = substract( vars2, vars0 );
         VertexVariables dVarsPerDx = scale(
            substract( scale( deltaVars1, deltaY2 ), scale( deltaVars2, deltaY1 ) ),
            invDenominator
         );
         VertexVariables dVarsPerDy = scale(
            substract( scale( deltaVars1, deltaX2 ), scale( deltaVars2, deltaX1 ) ),
            -invDenominator
         );
      } else {
         // Calculate the sum of the three vertex variables and divide it by
         // three to compute the arithmetic mean.
         Color triangleColor = pixelShader( scale(
            add( add( vars0, vars1 ), vars2 ),
            1f/3f
         ) );
      }

      // ---

      Color* colorBuffer = m_colorBuffer.pixels;
      float* zBuffer = m_zBuffer.data;

      // Function to rasterize a single scanline. This accesses, but does not
      // modify colorBuffer, zBuffer and the gradients computed above.
      void rasterizeScanline( uint pixelCount, uint startBufferIndex,
         float startZ, float startW, VertexVariables* startVariables ) {

         Color* currentPixel = colorBuffer + startBufferIndex;
         float* currentDepth = zBuffer + startBufferIndex;

         float currentZ = startZ;
         float currentW = startW;

         static if ( Gouraud ) {
            VertexVariables currentVars = *startVariables;
         }

         while ( pixelCount-- ) {
            // Perform depth-test.
            if ( currentZ < (*currentDepth) ) {
               (*currentDepth) = currentZ;
               static if ( Gouraud ) {
                  (*currentPixel) = pixelShader( scale( currentVars, ( 1f / currentW ) ) );
               } else {
                  (*currentPixel) = triangleColor;
               }
            }

            currentZ += dzPerDx;
            currentW += dwPerDx;
            ++currentPixel;
            ++currentDepth;

            static if ( Gouraud ) {
               currentVars = add( currentVars, dVarsPerDx );
            }
         }
      }

      // ---

      // Sort vertices by y-coordinate.
      if ( pos1.y < pos0.y ) {
         swap( pos0, pos1 );
         swap( vars0, vars1 );
      }
      if ( pos2.y < pos1.y ) {
         swap( pos2, pos1 );
         swap( vars2, vars1 );
      }
      if ( pos1.y < pos0.y ) {
         swap( pos0, pos1 );
         swap( vars0, vars1 );
      }

      assert( pos0.y <= pos1.y, "y-sorting failed (pos1.y < pos0.y)" );
      assert( pos1.y <= pos2.y, "y-sorting failed (pos2.y < pos1.y)" );

      // ---

      // Rasterize the triangle.
      // For this, the triangle is divided in the upper and the lower part.

      // Calculate the slopes (dx/dy) of the triangle edges. They are used to
      // calculate the new x coordinates of the scanline borders when the
      // scanline is advanced.
      float xStep0 = ( pos1.y - pos0.y > 0f ) ? ( pos1.x - pos0.x ) / ( pos1.y - pos0.y ) : 0f;
      float xStep1 = ( pos2.y - pos0.y > 0f ) ? ( pos2.x - pos0.x ) / ( pos2.y - pos0.y ) : 0f;
      float xStep2 = ( pos2.y - pos1.y > 0f ) ? ( pos2.x - pos1.x ) / ( pos2.y - pos1.y ) : 0f;

      float leftX;
      float rightX;
      uint currentY;
      uint bottomY;
      float leftDxPerDy;
      float rightDxPerPy;

      uint lineStartBufferIndex;
      uint bufferLineStride = m_colorBuffer.width;

      // Code to rasterize the current triangle part. This accesses and
      // modifies the variables defined above!
      void rasterizeCurrentPart() {
         while ( currentY < bottomY ) {
            // Left and right edge of the scanline. The pixel on the left edge
            // is drawn, the one on the right is not.
            int intLeftX = rndint( leftX );
            int intRightX = rndint( rightX );

            if ( intLeftX < intRightX ) {
               // We used vertex 0 as base for the gradient calculations.
               float relativeX = cast( float ) intLeftX - pos0.x;
               float relativeY = cast( float ) currentY - pos0.y;

               float lineStartZ = pos0.z + relativeX * dzPerDx + relativeY * dzPerDy;
               float lineStartW = pos0.w + relativeX * dwPerDx + relativeY * dwPerDy;

               static if ( Gouraud ) {
                  VertexVariables lineStartVars = add(
                     vars0,
                     add(
                        scale( dVarsPerDx, relativeX ),
                        scale( dVarsPerDy, relativeY )
                     )
                  );
                  rasterizeScanline(
                     ( intRightX - intLeftX ),
                     ( lineStartBufferIndex + intLeftX ),
                     lineStartZ,
                     lineStartW,
                     &lineStartVars
                  );
               } else {
                  rasterizeScanline(
                     ( intRightX - intLeftX ),
                     ( lineStartBufferIndex + intLeftX ),
                     lineStartZ,
                     lineStartW,
                     null
                  );
               }
            }

            ++currentY;
            leftX += leftDxPerDy;
            rightX += rightDxPerPy;
            lineStartBufferIndex += bufferLineStride;
         }
      }

      // First, draw the upper part.
      leftX = pos0.x;
      rightX = pos0.x;
      currentY = rndint( pos0.y );
      bottomY = rndint( pos1.y );
      if ( xStep0 > xStep1 ) {
         leftDxPerDy = xStep1;
         rightDxPerPy = xStep0;
      } else {
         leftDxPerDy = xStep0;
         rightDxPerPy = xStep1;
      }

      float yPreStep = ( cast( float ) currentY ) - pos0.y;
      leftX += leftDxPerDy * yPreStep;
      rightX += rightDxPerPy * yPreStep;

      lineStartBufferIndex = currentY * bufferLineStride;
      rasterizeCurrentPart();

      // Now draw the lower part (currentY is now the previous bottomY).
      bottomY = rndint( pos2.y );

      yPreStep = ( cast( float ) currentY ) - pos1.y;
      if ( xStep1 > xStep2 ) {
         leftDxPerDy = xStep1;
         rightDxPerPy = xStep2;
         rightX = pos1.x + rightDxPerPy * yPreStep;
      } else {
         leftDxPerDy = xStep2;
         rightDxPerPy = xStep1;
         leftX = pos1.x + leftDxPerDy * yPreStep;
      }

      rasterizeCurrentPart();
   }
}

void swap( T )( inout T first, inout T second ) {
   T temp = first;
   first = second;
   second = temp;
}
