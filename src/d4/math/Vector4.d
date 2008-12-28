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

   float x;
   float y;
   float z;
   float w;
}

Vector4 interpolateLinear( Vector4 first, Vector4 second, float position ) {
   Vector4 result;
   result.x = first.x + ( second.x - first.x ) * position;
   result.y = first.y + ( second.y - first.y ) * position;
   result.z = first.z + ( second.z - first.z ) * position;
   result.w = first.w + ( second.w - first.w ) * position;
   return result;
}