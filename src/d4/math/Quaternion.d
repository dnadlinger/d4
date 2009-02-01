module d4.math.Quaternion;

import tango.math.Math : sin, cos;
import d4.math.Vector3;

struct Quaternion {
   static Quaternion opCall( float newW = 1f, float newX = 0f, float newY = 0f, float newZ = 0f ) {
      Quaternion result;
      result.w = newW;
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      return result;
   }
   
   static Quaternion opCall( float scalar, Vector3 vector ) {
      Quaternion result;
      result.w = scalar;
      result.x = vector.x;
      result.y = vector.y;
      result.z = vector.z;
      return result;
   }

   Quaternion opMul( Quaternion rhs ) {
      // TODO: Can we do this? opMul is defined to be commutative?!
      Quaternion result;

      result.w = w * rhs.w - x * rhs.x - y * rhs.y - z * rhs.z;
      result.x = w * rhs.x + rhs.w * x + y * rhs.z - rhs.y * z;
      result.y = w * rhs.y + rhs.w * y + z * rhs.x - rhs.z * x;
      result.z = w * rhs.z + rhs.w * z + x * rhs.y - rhs.x * y;

      return result;
   }

   void opMulAssign( Quaternion rhs ) {
      (*this) = (*this) * rhs;
   }

   void append( Quaternion rhs ) {
      (*this) = rhs * (*this);
   }

   float w;
   float x;
   float y;
   float z;
}