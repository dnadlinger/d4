module d4.math.Matrix4;

import tango.io.Stdout;
import tango.math.Math : sin, cos, tan;
import d4.math.Vector3;
import d4.math.Vector4;

/**
 * A basic 4x4 matrix (row-major memory layout).
 */
struct Matrix4 {
   static Matrix4 identity() {
      Matrix4 m;

      m.data[] = 0;

      m.m11 = 1;
      m.m22 = 1;
      m.m33 = 1;
      m.m44 = 1;

      return m;
   }

   Matrix4 transposed() {
      Matrix4 m;

      m.m11 = m11;
      m.m12 = m21;
      m.m13 = m31;
      m.m14 = m41;

      m.m21 = m12;
      m.m22 = m22;
      m.m23 = m32;
      m.m24 = m42;

      m.m31 = m13;
      m.m32 = m23;
      m.m33 = m33;
      m.m34 = m43;

      m.m41 = m14;
      m.m42 = m24;
      m.m43 = m34;
      m.m44 = m44;

      return m;
   }

   void transpose() {
      void swap( uint x, uint y ) {
         float temp = m[ x ][ y ];
         m[ x ][ y ] = m[ y ][ x ];
         m[ y ][ x ] = temp;
      }

      swap( 1, 2 );
      swap( 1, 3 );
      swap( 1, 4 );
      swap( 2, 3 );
      swap( 2, 4 );
      swap( 3, 4 );
   }

   Matrix4 opMul( Matrix4 rhs ) {
      // TODO: Can we do this? opMul is defined to be commutative?!
      Matrix4 m;

      m.m11 = m11 * rhs.m11 + m12 * rhs.m21 + m13 * rhs.m31 + m14 * rhs.m41;
      m.m12 = m11 * rhs.m12 + m12 * rhs.m22 + m13 * rhs.m32 + m14 * rhs.m42;
      m.m13 = m11 * rhs.m13 + m12 * rhs.m23 + m13 * rhs.m33 + m14 * rhs.m43;
      m.m14 = m11 * rhs.m14 + m12 * rhs.m24 + m13 * rhs.m34 + m14 * rhs.m44;

      m.m21 = m21 * rhs.m11 + m22 * rhs.m21 + m23 * rhs.m31 + m24 * rhs.m41;
      m.m22 = m21 * rhs.m12 + m22 * rhs.m22 + m23 * rhs.m32 + m24 * rhs.m42;
      m.m23 = m21 * rhs.m13 + m22 * rhs.m23 + m23 * rhs.m33 + m24 * rhs.m43;
      m.m24 = m21 * rhs.m14 + m22 * rhs.m24 + m23 * rhs.m34 + m24 * rhs.m44;

      m.m31 = m31 * rhs.m11 + m32 * rhs.m21 + m33 * rhs.m31 + m34 * rhs.m41;
      m.m32 = m31 * rhs.m12 + m32 * rhs.m22 + m33 * rhs.m32 + m34 * rhs.m42;
      m.m33 = m31 * rhs.m13 + m32 * rhs.m23 + m33 * rhs.m33 + m34 * rhs.m43;
      m.m34 = m31 * rhs.m14 + m32 * rhs.m24 + m33 * rhs.m34 + m34 * rhs.m44;

      m.m41 = m41 * rhs.m11 + m42 * rhs.m21 + m43 * rhs.m31 + m44 * rhs.m41;
      m.m42 = m41 * rhs.m12 + m42 * rhs.m22 + m43 * rhs.m32 + m44 * rhs.m42;
      m.m43 = m41 * rhs.m13 + m42 * rhs.m23 + m43 * rhs.m33 + m44 * rhs.m43;
      m.m44 = m41 * rhs.m14 + m42 * rhs.m24 + m43 * rhs.m34 + m44 * rhs.m44;

      return m;
   }

   void opMulAssign( Matrix4 rhs ) {
      float old1;
      float old2;
      float old3;

      old1 = m11;
      old2 = m12;
      old3 = m13;
      m11 = old1 * rhs.m11 + old2 * rhs.m21 + old3 * rhs.m31 + m14 * rhs.m41;
      m12 = old1 * rhs.m12 + old2 * rhs.m22 + old3 * rhs.m32 + m14 * rhs.m42;
      m13 = old1 * rhs.m13 + old2 * rhs.m23 + old3 * rhs.m33 + m14 * rhs.m43;
      m14 = old1 * rhs.m14 + old2 * rhs.m24 + old3 * rhs.m34 + m14 * rhs.m44;

      old1 = m21;
      old2 = m22;
      old3 = m23;
      m21 = old1 * rhs.m11 + old2 * rhs.m21 + old3 * rhs.m31 + m24 * rhs.m41;
      m22 = old1 * rhs.m12 + old2 * rhs.m22 + old3 * rhs.m32 + m24 * rhs.m42;
      m23 = old1 * rhs.m13 + old2 * rhs.m23 + old3 * rhs.m33 + m24 * rhs.m43;
      m24 = old1 * rhs.m14 + old2 * rhs.m24 + old3 * rhs.m34 + m24 * rhs.m44;

      old1 = m31;
      old2 = m32;
      old3 = m33;
      m31 = old1 * rhs.m11 + old2 * rhs.m21 + old3 * rhs.m31 + m34 * rhs.m41;
      m32 = old1 * rhs.m12 + old2 * rhs.m22 + old3 * rhs.m32 + m34 * rhs.m42;
      m33 = old1 * rhs.m13 + old2 * rhs.m23 + old3 * rhs.m33 + m34 * rhs.m43;
      m34 = old1 * rhs.m14 + old2 * rhs.m24 + old3 * rhs.m34 + m34 * rhs.m44;

      old1 = m41;
      old2 = m42;
      old3 = m43;
      m41 = old1 * rhs.m11 + old2 * rhs.m21 + old3 * rhs.m31 + m44 * rhs.m41;
      m42 = old1 * rhs.m12 + old2 * rhs.m22 + old3 * rhs.m32 + m44 * rhs.m42;
      m43 = old1 * rhs.m13 + old2 * rhs.m23 + old3 * rhs.m33 + m44 * rhs.m43;
      m44 = old1 * rhs.m14 + old2 * rhs.m24 + old3 * rhs.m34 + m44 * rhs.m44;
   }

   Vector4 opMul( Vector4 rhs ) {
      return Vector4(
         m11 * rhs.x + m12 * rhs.y + m13 * rhs.z + m14 * rhs.w,
         m21 * rhs.x + m22 * rhs.y + m23 * rhs.z + m24 * rhs.w,
         m31 * rhs.x + m32 * rhs.y + m33 * rhs.z + m34 * rhs.w,
         m41 * rhs.x + m42 * rhs.y + m43 * rhs.z + m44 * rhs.w
      );
   }

   Vector4 opMul( Vector3 rhs ) {
      // Implicitely setting w = 1 here.
      return Vector4(
         m11 * rhs.x + m12 * rhs.y + m13 * rhs.z + m14,
         m21 * rhs.x + m22 * rhs.y + m23 * rhs.z + m24,
         m31 * rhs.x + m32 * rhs.y + m33 * rhs.z + m34,
         m41 * rhs.x + m42 * rhs.y + m43 * rhs.z + m44
      );
   }
   
   Vector3 rotateVector( Vector3 rhs ) {
      return Vector3(
         m11 * rhs.x + m12 * rhs.y + m13 * rhs.z,
         m21 * rhs.x + m22 * rhs.y + m23 * rhs.z,
         m31 * rhs.x + m32 * rhs.y + m33 * rhs.z
      );
   }
   
   Matrix4 inversed() {
      // FIXME: Probably not correct.
      float determinant =
         ( m11 * m11 - m12 * m21 ) * ( m33 * m44 - m34 * m43 ) -
         ( m11 * m23 - m13 * m21 ) * ( m32 * m44 - m34 * m42 ) +
         ( m11 * m24 - m14 * m21 ) * ( m32 * m43 - m33 * m42 ) +
         ( m12 * m23 - m13 * m22 ) * ( m31 * m44 - m34 * m41 ) -
         ( m12 * m24 - m14 * m22 ) * ( m31 * m43 - m33 * m41 ) +
         ( m13 * m24 - m14 * m23 ) * ( m31 * m42 - m32 * m41 );

      if( determinant == 0 ) {
         throw new Exception( "Could not calcualte inverse matrix because determinant is zero." );
      }
        
      float invDet = 1f / determinant;

      Matrix4 result;
      result.m11 = invDet *
         ( m22 * ( m33 * m44 - m34 * m43 ) +
           m23 * ( m34 * m42 - m32 * m44 ) +
           m24 * ( m32 * m43 - m33 * m42 ) );
      result.m12 = invDet *
         ( m32 * ( m13 * m44 - m14 * m43 ) +
           m33 * ( m14 * m42 - m12 * m44 ) +
           m34 * ( m12 * m43 - m13 * m42 ) );
      result.m13 = invDet *
         ( m42 * ( m13 * m24 - m14 * m23 ) +
           m43 * ( m14 * m22 - m12 * m24 ) +
           m44 * ( m12 * m23 - m13 * m22 ) );
      result.m14 = invDet *
         ( m12 * ( m24 * m33 - m23 * m34 ) +
           m13 * ( m22 * m34 - m24 * m32 ) +
           m14 * ( m23 * m32 - m22 * m33 ) );
      result.m21 = invDet *
         ( m23 * ( m31 * m44 - m34 * m41 ) +
           m24 * ( m33 * m41 - m31 * m43 ) +
           m21 * ( m34 * m43 - m33 * m44 ) );
      result.m22 = invDet *
         ( m33 * ( m11 * m44 - m14 * m41 ) +
           m34 * ( m13 * m41 - m11 * m43 ) +
           m31 * ( m14 * m43 - m13 * m44 ) );
      result.m23 = invDet *
         ( m43 * ( m11 * m24 - m14 * m21 ) +
           m44 * ( m13 * m21 - m11 * m23 ) +
           m41 * ( m14 * m23 - m13 * m24 ) );
      result.m24 = invDet *
         ( m13 * ( m24 * m31 - m21 * m34 ) +
           m14 * ( m21 * m33 - m23 * m31 ) +
           m11 * ( m23 * m34 - m24 * m33 ) );
      result.m31 = invDet *
         ( m24 * ( m31 * m42 - m32 * m41 ) +
           m21 * ( m32 * m44 - m34 * m42 ) +
           m22 * ( m34 * m41 - m31 * m44 ) );
      result.m32 = invDet *
         ( m34 * ( m11 * m42 - m12 * m41 ) +
           m31 * ( m12 * m44 - m14 * m42 ) +
           m32 * ( m14 * m41 - m11 * m44 ) );
      result.m33 = invDet *
         ( m44 * ( m11 * m22 - m12 * m21 ) +
           m41 * ( m12 * m24 - m14 * m22 ) +
           m42 * ( m14 * m21 - m11 * m24 ) );
      result.m34 = invDet *
         ( m14 * ( m22 * m31 - m21 * m32 ) +
           m11 * ( m24 * m32 - m22 * m34 ) +
           m12 * ( m21 * m34 - m24 * m31 ) );
      result.m41 = invDet *
         ( m21 * ( m33 * m42 - m32 * m43 ) +
           m22 * ( m31 * m43 - m33 * m41 ) +
           m23 * ( m32 * m41 - m31 * m42 ) );
      result.m42 = invDet *
         ( m31 * ( m13 * m42 - m12 * m43 ) +
           m32 * ( m11 * m43 - m13 * m41 ) +
           m33 * ( m12 * m41 - m11 * m42 ) );
      result.m43 = invDet *
         ( m41 * ( m13 * m22 - m12 * m23 ) +
           m42 * ( m11 * m23 - m13 * m21 ) +
           m43 * ( m12 * m21 - m11 * m22 ) );
      result.m44 = invDet *
         ( m11 * ( m22 * m33 - m23 * m32 ) +
           m12 * ( m23 * m31 - m21 * m33 ) +
           m13 * ( m21 * m32 - m22 * m31 ) );
        
      return result;
   }

   union {
      struct {
         float m11, m12, m13, m14;
         float m21, m22, m23, m24;
         float m31, m32, m33, m34;
         float m41, m42, m43, m44;
      }
      float[ 4 ][ 4 ] m;
      float[ 16 ] data;
   }
}