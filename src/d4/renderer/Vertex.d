module d4.renderer.Vertex;

import d4.math.Color;
import d4.math.Vector3;

struct Vertex {
   static Vertex opCall( Vector3 position = Vector3() ) {
      Vertex result;
      result.position = position;
      result.color.value = 0xffffffff;
      return result;
   }

   Vector3 position;
   Color color;
}