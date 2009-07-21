module d4.math.Vector3;

import tango.math.Math : sin, cos, acos, sqrt;

/**
 * A vector in three-dimensional space.
 */
struct Vector3 {
   /**
    * Constructs a new vector from the given components.
    *
    * Params:
    *     newX = The x coordinate of the new vector.
    *     newY = The y coordinate of the new vector.
    *     newZ = The z coordinate of the new vector.
    * Returns: The new vector.
    */
   static Vector3 opCall( float newX = 0.f, float newY = 0.f, float newZ = 0.f ) {
      Vector3 result;
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      return result;
   }

   /**
    * Negates the vector (negates all compontents).
    *
    * Returns: The negated vector.
    */
   Vector3 opNeg() {
      return Vector3( -x, -y, -z );
   }

   /**
    * Adds another vector to this vector and returns the sum in a new object.
    *
    * Params:
    *     rhs = The right hand side vector.
    * Returns: The vector sum.
    */
   Vector3 opAdd( Vector3 rhs ) {
      return Vector3(
         x + rhs.x,
         y + rhs.y,
         z + rhs.z
      );
   }

   /**
    * Adds another vector to this vector and saves the sum to this object.
    *
    * Params:
    *     rhs = The right hand side vector.
    */
   void opAddAssign( Vector3 rhs ) {
      x += rhs.x;
      y += rhs.y;
      z += rhs.z;
   }

   /**
    * Substracts another vector from this vector and returns the difference
    * in a new object.
    *
    * Params:
    *     rhs = The right hand side vector.
    * Returns: The vector sum.
    */
   Vector3 opSub( Vector3 rhs ) {
      return Vector3(
         x - rhs.x,
         y - rhs.y,
         z - rhs.z
      );
   }

   /**
    * Substracts another vector from this vector and saves the result
    * to this object.
    *
    * Params:
    *     rhs = The right hand side vector.
    */
   void opSubAssign( Vector3 rhs ) {
      x -= rhs.x;
      y -= rhs.y;
      z -= rhs.z;
   }

   /**
    * Scales the vector (all three components) and returns the result as
    * a new vector.
    *
    * Params:
    *     factor = The scaling factor.
    * Returns: The scaled vector.
    */
   Vector3 opMul( float factor ) {
      return Vector3(
         x * factor,
         y * factor,
         z * factor
      );
   }

   /**
    * Scales the vector (all four components) and saves the result to this object.
    *
    * Params:
    *     factor = The scaling factor.
    */
   void opMulAssign( float factor ) {
      x *= factor;
      y *= factor;
      z *= factor;
   }

   /**
    * Computes the dot product of this and another vector.
    *
    * Params:
    *     rhs = The right hand side vector.
    * Returns: The dot product.
    */
   float dot( Vector3 rhs ) {
      return x * rhs.x + y * rhs.y + z * rhs.z;
   }

   /**
    * Computes the cross (or vector) product of this and another vector:
    * Remember: The cross product is not commutative!
    *
    * Params:
    *     rhs = The right hand side vector.
    * Returns: The result vector.
    */
   Vector3 cross( Vector3 rhs ) {
      return Vector3(
         y * rhs.z - rhs.y * z,
         z * rhs.x - rhs.z * x,
         x * rhs.y - rhs.x * y
      );
   }

   /**
    * Returns: The square length of the vector.
    */
   float sqrLength() {
      return x * x + y * y + z * z;
   }

   /**
    * Returns: The length of the vector.
    */
   float length() {
      return sqrt( sqrLength() );
   }

   /**
    * Normalizes the vector (it points in the same direction, but has
    * the length 1) and returns the result as a new vector.
    *
    * Returns: The normalized vector.
    */
   Vector3 normalized() {
      return ( 1 / length() ) * (*this);
   }

   /**
    * Normalizes the vector and saves the result to this object.
    */
   void normalize() {
      (*this) *= 1 / length();
   }

   /**
    * Computes the angle between this and another vector.
    *
    * Params:
    *     other = The other vector.
    * Returns: The angle between the two vectors (in radians).
    */
   float angleWith( Vector3 other ) {
      return acos( dot( other ) / sqrt( sqrLength() * other.sqrLength() ) );
   }

   float x; /// The x component of the vector.
   float y; /// The y component of the vector.
   float z; /// The z component of the vector.
}

Vector3 normalize( Vector3 vector ) {
   return vector.normalized();
}
