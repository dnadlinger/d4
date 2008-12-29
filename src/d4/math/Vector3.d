module d4.math.Vector3;

import tango.math.Math : sin, cos, acos, sqrt;

struct Vector3 {
   static Vector3 opCall( float newX = 0.f, float newY = 0.f, float newZ = 0.f ) {
      Vector3 result;
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      return result;
   }

   Vector3 opAdd( Vector3 rhs ) {
      return Vector3(
         x + rhs.x,
         y + rhs.y,
         z + rhs.z
      );
   }
   
   void opAddAssign( Vector3 rhs ) {
      x += rhs.x;
      y += rhs.y;
      z += rhs.z;
   }

   void opSubAssign( Vector3 rhs ) {
      x -= rhs.x;
      y -= rhs.y;
      z -= rhs.z;
   }
   
   Vector3 opSub( Vector3 rhs ) {
      return Vector3(
         x - rhs.x,
         y - rhs.y,
         z - rhs.z
      );
   }

   Vector3 opMul( float factor ) {
      return Vector3(
         x * factor,
         y * factor,
         z * factor
      );
   }

   void opMulAssign( float factor ) {
      x *= factor;
      y *= factor;
      z *= factor;
   }

   float dot( Vector3 rhs ) {
      return x * rhs.x + y * rhs.y + z * rhs.z;
   }

   Vector3 cross( Vector3 rhs ) {
      return Vector3(
         y * rhs.z - rhs.y * z,
         z * rhs.x - rhs.z * x,
         x * rhs.y - rhs.x * y
      );
   }

   float sqrLength() {
      return x * x + y * y + z * z;
   }

   float length() {
      return sqrt( sqrLength() );
   }

   Vector3 normalized() {
      return ( 1 / length() ) * (*this);
   }

   void normalize() {
      (*this) *= 1 / length();
   }

   float angleWith( Vector3 other ) {
      return acos( dot( other ) / sqrt( sqrLength() * other.sqrLength() ) );
   }

   float x;
   float y;
   float z;
}