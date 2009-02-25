module d4.math.Vector2;

/**
 * A two-dimensional vector (e.g. for screen positions or texture coordinates).
 */
struct Vector2 {
   /**
    * Constructs a new vector.
    * 
    * Params:
    *     newX = The x component of the vector. 
    *     newY = The y component of the vector.
    * Returns: The new Vector2.
    */
   static Vector2 opCall( float newX = 0.f, float newY = 0.f ) {
      Vector2 result;
      result.x = newX;
      result.y = newY;
      return result;
   }

   /**
    * Substracts another vector from this vector and returns the difference
    * as a new vector.
    * 
    * Params:
    *     rhs = The right hand side vector.
    * Returns: The result (difference) vector.
    */
   Vector2 opSub( Vector2 rhs ) {
      return Vector2(
         x - rhs.x,
         y - rhs.y
      );
   }

   /**
    * Scales the vector (both components) and returns the result
    * in a new vector.
    * 
    * Params:
    *     factor = The scaling factor. 
    * Returns: The scaled vector.
    */
   Vector2 opMul( float factor ) {
      return Vector2(
         x * factor,
         y * factor
      );
   }

   /**
    * Scales the vector (both components) and saves the result to this object.
    * 
    * Params:
    *     factor = The scaling factor. 
    */
   void opMulAssign( float factor ) {
      x *= factor;
      y *= factor;
   }

   float x; /// The x component of the vector.
   float y; /// The y component of the vector.
}