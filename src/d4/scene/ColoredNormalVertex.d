module d4.scene.ColoredNormalVertex;

import d4.math.Vector3;
import d4.scene.ColoredVertex;

class ColoredNormalVertex : ColoredVertex {
public:
   Vector3 normal() {
      return m_normal;
   }
   
   void normal( Vector3 normal ) {
      m_normal = normal;
   }

private:
   Vector3 m_normal;
}