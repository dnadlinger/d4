module d4.math.Vector4;

import tango.io.Stdout;
import d4.math.Vector3;

/**
 * A vector in three-dimensional space with homogeneous coordinates x, y, z, w.
 * It could of course also be interpeted as a "pure" four-dimensional vector.
 */
struct Vector4 {
   /**
    * Constructs a new vector.
    * Params:
    *     newX = The x component of the vector.
    *     newY = The y component of the vector.
    *     newZ = The z component of the vector.
    *     newW = The w component of the vector.
    * Returns: The new vector.
    */
   static Vector4 opCall( float newX = 0.f, float newY = 0.f, float newZ = 0.f, float newW = 1.f ) {
      Vector4 result;
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      result.w = newW;
      return result;
   }

   /**
    * Scales the vector (all four components) and returns the result
    * in a new vector.
    * 
    * Params:
    *     factor = The scaling factor. 
    * Returns: The scaled vector.
    */
   Vector4 opMul( float factor ) {
      return Vector4(
         x * factor,
         y * factor,
         z * factor,
         w * factor
      );
   }

   /**
    * Scales the vector (all four components) and saves the result to this object.
    * Params:
    *     factor = The scaling factor.
    */
   void opMulAssign( float factor ) {
      x *= factor;
      y *= factor;
      z *= factor;
      w *= factor;
   }

   float x; /// The x component of the vector.
   float y; /// The y component of the vector.
   float z; /// The z component of the vector.
   float w; /// The w component of the vector.
}

/**
 * Linearly interpolates between the two given vectors [0..1].
 * 
 * Params:
 *     first = The first vector. 
 *     second = The second vector.
 *     position = The position "index" (from 0 to 1).
 * Returns: The interpolated result vector.
 */
Vector4 lerp( Vector4 first, Vector4 second, float position ) {
   Vector4 result;
   result.x = first.x + ( second.x - first.x ) * position;
   result.y = first.y + ( second.y - first.y ) * position;
   result.z = first.z + ( second.z - first.z ) * position;
   result.w = first.w + ( second.w - first.w ) * position;
   return result;
}