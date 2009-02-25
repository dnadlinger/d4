module d4.renderer.SolidGouraudRasterizer;

import tango.math.Math : ceil, rndint;
import d4.math.Color;
import d4.math.Vector4;
import d4.renderer.RasterizerBase;

/**
 * A rasterizer which draws solid triangles using the Scanline algorithm.
 * 
 * The vertex variables are linearly interpolated (perspective-correct
 * Gouraud shading).
 * 
 * Partly inspired by the excellent Muli3D software rasterizer
 * (http://muli3d.sourceforge.net).
 */
final class SolidGouraudRasterizer( alias Shader, ShaderParams... ) : RasterizerBase!( Shader, ShaderParams ) {
protected:
   void drawTriangle( Vector4[ 3 ] positions, VertexVariables[ 3 ] variables ) {
      // All coordinates have to be clipped to screen space.
      debug {
         void sanityCheck( Vector4 pos ) {
            assert( rndint( ceil( pos.x ) ) >= 0, "Triangle coordinates must not be negative." );
            assert( rndint( ceil( pos.y ) ) >= 0, "Triangle coordinates must not be negative." );
            assert( pos.x < m_colorBuffer.width, "Triangle coordinates must not exceed framebuffer size." );
            assert( pos.y < m_colorBuffer.height, "Triangle coordinates must not exceed framebuffer size." );
         }

         sanityCheck( positions[ 0 ] );
         sanityCheck( positions[ 1 ] );
         sanityCheck( positions[ 2 ] );
      }

      // Calculate the triangle »gradients«.
      // The vertex at index 0 is the base vertex for the gradient calculations.
      // In screen space, the y-axis points in the other direction, so we have
      // to negate the y gradients.
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
      
      VertexVariables deltaVars1 = substract( variables[ 1 ], variables[ 0 ] );
      VertexVariables deltaVars2 = substract( variables[ 2 ], variables[ 0 ] );
      VertexVariables dVarsPerDx = scale( substract( scale( deltaVars1, deltaY2 ), scale( deltaVars2, deltaY1 ) ), invDenominator );
      VertexVariables dVarsPerDy = scale( substract( scale( deltaVars1, deltaX2 ), scale( deltaVars2, deltaX1 ) ), -invDenominator );
      
      Color* colorBuffer = m_colorBuffer.pixels;
      float* zBuffer = m_zBuffer.data;
      
      void rasterizeScanline( uint pixelCount, uint startBufferIndex,
         float startZ, float startW, VertexVariables startVariables ) {
         
         Color* currentPixel = colorBuffer + startBufferIndex;
         float* currentDepth = zBuffer + startBufferIndex;
         
         float currentZ = startZ;
         float currentW = startW;
         VertexVariables currentVars = startVariables;
         
         while ( pixelCount-- ) {
            // Perform depth-test.
            if ( currentZ < (*currentDepth) ) {
               (*currentDepth) = currentZ;
               (*currentPixel) = pixelShader( scale( currentVars, ( 1 / currentW ) ) );
            }

            currentZ += dzPerDx;
            currentW += dwPerDx;
            currentVars = add( currentVars, dVarsPerDx );
            ++currentPixel;
            ++currentDepth;
         }
      }
      
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
      
      // Slopes for stepping.
      float xStep0 = ( p1.y - p0.y > 0.f ) ? ( p1.x - p0.x ) / ( p1.y - p0.y ) : 0.f;
      float xStep1 = ( p2.y - p0.y > 0.f ) ? ( p2.x - p0.x ) / ( p2.y - p0.y ) : 0.f;
      float xStep2 = ( p2.y - p1.y > 0.f ) ? ( p2.x - p1.x ) / ( p2.y - p1.y ) : 0.f; 
      
      // Rasterize the triangle.
      // For this, the triangle is divided in the upper and the lower part.
      // First, draw the upper part.
      float x0 = p0.x;
      float x1 = p0.x;
      uint currentY = rndint( ceil( p0.y ) );
      uint bottomY = rndint( ceil( p1.y ) );
      
      float xDelta0;
      float xDelta1;

      if ( xStep0 > xStep1 ) {
         xDelta0 = xStep1;
         xDelta1 = xStep0;
      } else {
         xDelta0 = xStep0;
         xDelta1 = xStep1;
      }

      float yPreStep = cast( float ) currentY - p0.y;
      x0 += xDelta0 * yPreStep;
      x1 += xDelta1 * yPreStep;

      uint bufferLineStride = m_colorBuffer.width;
      uint lineStartBufferIndex =  currentY * bufferLineStride;

      while ( currentY < bottomY ) {
         uint intX0 = rndint( ceil( x0 ) );
         uint intX1 = rndint( ceil( x1 ) );
         
         if ( intX0 < intX1 ) {
            // We used vertex 0 as base for the gradient calculations.
            float relativeX = cast( float ) intX0 - positions[ 0 ].x;
            float relativeY = cast( float ) currentY - positions[ 0 ].y;

            float lineStartZ = positions[ 0 ].z + relativeX * dzPerDx + relativeY * dzPerDy;
            float lineStartW = positions[ 0 ].w + relativeX * dwPerDx + relativeY * dwPerDy;
            VertexVariables lineStartVars = add( variables[ 0 ],
               add( scale( dVarsPerDx, relativeX ), scale( dVarsPerDy, relativeY ) ) );

            rasterizeScanline( ( intX1 - intX0 ), ( lineStartBufferIndex + intX0 ), lineStartZ, lineStartW, lineStartVars );
         }

         ++currentY;
         x0 += xDelta0;
         x1 += xDelta1;
         lineStartBufferIndex += bufferLineStride;
      }
      
      // Now draw the lower part (currentY is now the previous bottomY).
      bottomY = rndint( ceil( p2.y ) );
      
      yPreStep = cast( float ) currentY - p1.y;
      if ( xStep1 > xStep2 ) {
         xDelta0 = xStep1;
         xDelta1 = xStep2;
         x1 = p1.x + xDelta1 * yPreStep;
      } else {
         xDelta0 = xStep2;
         xDelta1 = xStep1;
         x0 = p1.x + xDelta0 * yPreStep;
      }

      while ( currentY < bottomY ) {
         uint intX0 = rndint( ceil( x0 ) );
         uint intX1 = rndint( ceil( x1 ) );
         
         if ( intX0 < intX1 ) {
            float relativeX = cast( float ) intX0 - positions[ 0 ].x;
            float relativeY = cast( float ) currentY - positions[ 0 ].y;

            float lineStartZ = positions[ 0 ].z + relativeX * dzPerDx + relativeY * dzPerDy;
            float lineStartW = positions[ 0 ].w + relativeX * dwPerDx + relativeY * dwPerDy;
            VertexVariables lineStartVars = add( variables[ 0 ],
               add( scale( dVarsPerDx, relativeX ), scale( dVarsPerDy, relativeY ) ) );

            rasterizeScanline( ( intX1 - intX0 ), ( lineStartBufferIndex + intX0 ), lineStartZ, lineStartW, lineStartVars );
         }

         ++currentY;
         x0 += xDelta0;
         x1 += xDelta1;
         lineStartBufferIndex += bufferLineStride;
      }
   }
}