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
 * Partly inspired by the excellent Muli3D software rasterizer
 * (http://muli3d.sourceforge.net).
 */
final class SolidRasterizer( bool Gouraud, alias Shader, ShaderParams... ) :
   RasterizerBase!( Gouraud, Shader, ShaderParams ) {
protected:
   void drawTriangle( Vector4[ 3 ] positions, VertexVariables[ 3 ] variables ) {
      // Set rounding mode for rndint to make it behave like ceil().
      auto oldRoundingMode = setIeeeRounding( RoundingMode.ROUNDUP );
      scope ( exit ) setIeeeRounding( oldRoundingMode );

      // ---

      // Calculate the triangle »gradients«.
      // The vertex at index 0 is the base vertex for the gradient
      // calculations. In screen space, the y-axis points in the other
      // direction, so we have to negate the y gradients.
      float deltaX1 = positions[ 1 ].x - positions[ 0 ].x;
      float deltaX2 = positions[ 2 ].x - positions[ 0 ].x;
      float deltaY1 = positions[ 1 ].y - positions[ 0 ].y;
      float deltaY2 = positions[ 2 ].y - positions[ 0 ].y;

      float invDenominator = 1.f / ( deltaX1 * deltaY2 - deltaX2 * deltaY1 );

      // The procedure is the same for all values.
      float deltaZ1 = positions[ 1 ].z - positions[ 0 ].z;
      float deltaZ2 = positions[ 2 ].z - positions[ 0 ].z;
      float dzPerDx =  ( deltaZ1 * deltaY2 - deltaZ2 * deltaY1 ) * invDenominator;
      float dzPerDy = -( deltaZ1 * deltaX2 - deltaZ2 * deltaX1 ) * invDenominator;

      float deltaW1 = positions[ 1 ].w - positions[ 0 ].w;
      float deltaW2 = positions[ 2 ].w - positions[ 0 ].w;
      float dwPerDx =  ( deltaW1 * deltaY2 - deltaW2 * deltaY1 ) * invDenominator;
      float dwPerDy = -( deltaW1 * deltaX2 - deltaW2 * deltaX1 ) * invDenominator;

      static if ( Gouraud ) {
         // Calculate the gradients for the vertex variable too so we can step
         // them in rasterizeScanline() like the other values when doing
         // Gouraud shading.
         VertexVariables deltaVars1 = substract( variables[ 1 ], variables[ 0 ] );
         VertexVariables deltaVars2 = substract( variables[ 2 ], variables[ 0 ] );
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
            add( add( variables[ 0 ], variables[ 1 ] ), variables[ 2 ] ),
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

      // Sort vertices by y-coordinate. Instead of moving around the actual data,
      // we just store indices to the positions/variables array.
      uint i0 = 0;
      uint i1 = 1;
      uint i2 = 2;
      void swap( inout uint first, inout uint second ) {
         uint temp = first;
         first = second;
         second = temp;
      }
      if ( positions[ i1 ].y < positions[ i0 ].y ) {
         swap( i0, i1 );
      }
      if ( positions[ i2 ].y < positions[ i1 ].y ) {
         swap( i2, i1 );
      }
      if ( positions[ i1 ].y < positions[ i0 ].y ) {
         swap( i0, i1 );
      }

      Vector4 p0 = positions[ i0 ];
      Vector4 p1 = positions[ i1 ];
      Vector4 p2 = positions[ i2 ];

      assert( p0.y <= p1.y, "y-sorting failed (p1.y < p0.y)" );
      assert( p1.y <= p2.y, "y-sorting failed (p2.y < p1.y)" );

      // ---

      // Rasterize the triangle.
      // For this, the triangle is divided in the upper and the lower part.

      // Calculate the slopes (dx/dy) of the triangle edges. They are used to
      // calculate the new x coordinates of the scanline borders when the
      // scanline is advanced.
      float xStep0 = ( p1.y - p0.y > 0f ) ? ( p1.x - p0.x ) / ( p1.y - p0.y ) : 0f;
      float xStep1 = ( p2.y - p0.y > 0f ) ? ( p2.x - p0.x ) / ( p2.y - p0.y ) : 0f;
      float xStep2 = ( p2.y - p1.y > 0f ) ? ( p2.x - p1.x ) / ( p2.y - p1.y ) : 0f;

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
               float relativeX = cast( float ) intLeftX - positions[ 0 ].x;
               float relativeY = cast( float ) currentY - positions[ 0 ].y;

               float lineStartZ = positions[ 0 ].z + relativeX * dzPerDx + relativeY * dzPerDy;
               float lineStartW = positions[ 0 ].w + relativeX * dwPerDx + relativeY * dwPerDy;

               static if ( Gouraud ) {
                  VertexVariables lineStartVars = add( variables[ 0 ],
                     add( scale( dVarsPerDx, relativeX ), scale( dVarsPerDy, relativeY ) ) );
                  rasterizeScanline( ( intRightX - intLeftX ), ( lineStartBufferIndex + intLeftX ), lineStartZ, lineStartW, &lineStartVars );
               } else {
                  rasterizeScanline( ( intRightX - intLeftX ), ( lineStartBufferIndex + intLeftX ), lineStartZ, lineStartW, null );
               }
            }

            ++currentY;
            leftX += leftDxPerDy;
            rightX += rightDxPerPy;
            lineStartBufferIndex += bufferLineStride;
         }
      }

      // First, draw the upper part.
      leftX = p0.x;
      rightX = p0.x;
      currentY = rndint( p0.y );
      bottomY = rndint( p1.y );
      if ( xStep0 > xStep1 ) {
         leftDxPerDy = xStep1;
         rightDxPerPy = xStep0;
      } else {
         leftDxPerDy = xStep0;
         rightDxPerPy = xStep1;
      }

      float yPreStep = ( cast( float ) currentY ) - p0.y;
      leftX += leftDxPerDy * yPreStep;
      rightX += rightDxPerPy * yPreStep;

      lineStartBufferIndex = currentY * bufferLineStride;
      rasterizeCurrentPart();

      // Now draw the lower part (currentY is now the previous bottomY).
      bottomY = rndint( p2.y );

      yPreStep = ( cast( float ) currentY ) - p1.y;
      if ( xStep1 > xStep2 ) {
         leftDxPerDy = xStep1;
         rightDxPerPy = xStep2;
         rightX = p1.x + rightDxPerPy * yPreStep;
      } else {
         leftDxPerDy = xStep2;
         rightDxPerPy = xStep1;
         leftX = p1.x + leftDxPerDy * yPreStep;
      }

      rasterizeCurrentPart();
   }
}
