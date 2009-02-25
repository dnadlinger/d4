module d4.scene.ColoredNormalVertex;

import d4.math.Vector3;
import d4.scene.ColoredVertex;

/**
 * A vertex consisting of a position vector, a vertex color and a normal vector.
 */
class ColoredNormalVertex : ColoredVertex {
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