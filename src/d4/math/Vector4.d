module d4.math.Vector4;

import tango.io.Stdout;
import d4.math.Vector3;

struct Vector4 {
   static Vector4 opCall( float newX = 0.f, float newY = 0.f, float newZ = 0.f, float newW = 1.f ) {
      Vector4 result;
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      result.w = newW;
      return result;
   }

   Vector4 opMul( float factor ) {
      return Vector4(
         x * factor,
         y * factor,
         z * factor,
         w * factor
      );
   }

   void opMulAssign( float factor ) {
      x *= factor;
      y *= factor;
      z *= factor;
      w *= factor;
   }

   void homogenize() {
      float invW = ( w != 0 ) ? ( 1 / w ) : 1;
      x *= invW;
      y *= invW;
      z *= invW;
      w = 1;
   }

   Vector3 homogenized() {
      float invW = ( w != 0 ) ? ( 1 / w ) : 1;
      return Vector3(
         x * invW,
         y * invW,
         z * invW
      );
   }

   float x;
   float y;
   float z;
   float w;
}