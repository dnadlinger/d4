module d4.scene.NormalVertex;

import d4.math.Vector3;
import d4.scene.Vertex;

class NormalVertex : Vertex {
public:
   /**
    * The vertex normal vector.
    */
   Vector3 normal() {
      return m_normal;
   }

   /// ditto
   void normal( Vector3 normal ) {
      m_normal = normal;
   }

private:
   Vector3 m_normal;
}
