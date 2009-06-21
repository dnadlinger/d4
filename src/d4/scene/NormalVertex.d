module d4.scene.NormalVertex;

import d4.math.Vector3;
import d4.scene.Vertex;

class NormalVertex : Vertex {
public:
   this( Vector3 position = Vector3(), Vector3 normal = Vector3() ) {
      super( position );
      m_normal = normal;
   }

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
