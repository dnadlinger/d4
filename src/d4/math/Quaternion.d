module d4.math.Quaternion;

struct Quaternion {
   static Quaternion opCall( float newW = 0f, float newX = 0f, float newY = 0f, float newZ = 0f ) {
      Quaternion result;
      result.w = newW;      
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      return result;
   }
   
   float w;
   float x;
   float y;
   float z;
}