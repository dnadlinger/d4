module d4.scene.Vertex;

import d4.math.Vector3;

struct Vertex {
  static Vertex opCall( Vector3 position = Vector3() ) {
      Vertex result;
      result.position = position;
      return result;
   }

   Vector3 position;
}
