module d4.math.Plane;

import d4.math.Vector4;

/**
 * A plane in three-dimensional space.
 */
struct Plane {
   /**
    * Constructs a new plane from the plane equation coefficients.
    * (ax + by + cz + d = 0)
    *
    * Returns: The new plane instance.
    */
   static Plane opCall( float a, float b, float c, float d ) {
      Plane plane;
      plane.a = a;
      plane.b = b;
      plane.c = c;
      plane.d = d;
      return plane;
   }

   /**
    * Classifies a position vector.
    *
    * If the plane's normal is normalized, the absolute value of the result is
    * the distance to the plane.
    *
    * Params:
    *     position = The vector to classify.
    * Returns:
    *    0 if on the plane, >0 if in front of the plane, <0 if behind the plane.
    */
   float classifyHomogenous( Vector4 position ) {
      return a * position.x + b * position.y + c * position.z + d * position.w;
   }

   float a; /// The a coefficient of the plane equation.
   float b; /// The b coefficient of the plane equation.
   float c; /// The c coefficient of the plane equation.
   float d; /// The d coefficient of the plane equation.
}
