module d4.math.Vector2;

struct Vector2 {
   static Vector2 opCall( float newX = 0.f, float newY = 0.f ) {
      Vector2 result;
      result.x = newX;
      result.y = newY;
      return result;
   }

   Vector2 opSub( Vector2 rhs ) {
      return Vector2(
         x - rhs.x,
         y - rhs.y
      );
   }

   Vector2 opMul( float factor ) {
      return Vector2(
         x * factor,
         y * factor
      );
   }

   void opMulAssign( float factor ) {
      x *= factor;
      y *= factor;
   }

   float x;
   float y;
}