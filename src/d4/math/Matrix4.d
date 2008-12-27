module d4.math.Matrix4;

import tango.math.Math : sin, cos, tan;
import d4.math.Vector3;
import d4.math.Vector4;

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

   static Matrix4 scaling( float factorX = 1.f, float factorY = 1.f, float factorZ = 1.f ) {
      Matrix4 m = identity();

      m.m11 = factorX;
      m.m22 = factorY;
      m.m33 = factorZ;

      return m;
   }

   static Matrix4 scalingByVector( Vector3 vector ) {
      return scaling( vector.x, vector.y, vector.z );
   }

   static Matrix4 rotationX( float angleRadians ) {
      Matrix4 m = identity();

      float sin = sin( angleRadians );
      float cos = cos( angleRadians );

      m.m22 = cos;
      m.m23 = -sin;

      m.m32 = sin;
      m.m33 = cos;

      return m;
   }

   static Matrix4 rotationY( float angleRadians ) {
      Matrix4 m = identity();

      float sin = sin( angleRadians );
      float cos = cos( angleRadians );

      m.m11 = cos;
      m.m13 = -sin;

      m.m31 = sin;
      m.m33 = cos;

      return m;
   }

   static Matrix4 rotationZ( float angleRadians ) {
      Matrix4 m = identity();

      float sin = sin( angleRadians );
      float cos = cos( angleRadians );

      m.m11 = cos;
      m.m12 = -sin;

      m.m21 = sin;
      m.m22 = cos;

      return m;
   }

   static Matrix4 translation( float deltaX = 0.f, float deltaY = 0.f, float deltaZ = 0.f ) {
      Matrix4 m = identity();

      m.m14 = deltaX;
      m.m24 = deltaY;
      m.m34 = deltaZ;

      return m;
   }

   static Matrix4 translationByVector( Vector3 vector ) {
      return translation( vector.x, vector.y, vector.z );
   }

   static Matrix4 cameraAt( Vector3 position, Vector3 direction, Vector3 up ) {
      Vector3 right = up.cross( direction );

      Matrix4 m = identity();

      m.m11 = right.x;
      m.m12 = up.x;
      m.m13 = direction.x;
      m.m14 = position.x;

      m.m21 = right.y;
      m.m22 = up.y;
      m.m23 = direction.y;
      m.m24 = position.y;

      m.m31 = right.z;
      m.m32 = up.z;
      m.m33 = direction.z;
      m.m34 = position.z;

      return m;
   }

   static Matrix4 lookAt( Vector3 position, Vector3 target, Vector3 worldUp ) {
      Vector3 direction = target - position;
      direction.normalize();

      Vector3 cameraUp = worldUp - ( direction * worldUp.dot( direction ) );
      cameraUp.normalize();

      return cameraAt( position, direction, cameraUp );
   }

  static Matrix4 perspectiveProjection( float fovRadians, float aspectRatio,
      float nearDistance, float farDistance ) {

      if ( farDistance - nearDistance < 0.01 ) {
         throw new Exception( "Could not create perspective projection matrix: " ~
            "Far clipping plane too close to near clipping plane." );
      }

      float p = farDistance / ( farDistance - nearDistance );
      float q = - p * nearDistance;

      float fovScale = 1 / tan( fovRadians * 0.5 );
      if ( fovScale < 0.01 ) {
         throw new Exception( "Could not create perspective projection matrix: " ~
            "Field of view opening angle too big." );
      }

      Matrix4 m = identity();

      m.m11 = fovScale;

      m.m22 = fovScale * aspectRatio;

      m.m33 = p;
      m.m34 = q;

      m.m43 = 1;
      m.m44 = 0;

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
      // Can we do this? opMul is defined to be commutative?!
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