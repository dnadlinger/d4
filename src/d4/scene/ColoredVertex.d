module d4.scene.ColoredVertex;

import d4.math.Color;
import d4.math.Vector3;
import d4.scene.Vertex;

class ColoredVertex : Vertex {
public:
   Vector3 normal() {
      return m_normal;
   }
   
   void normal( Vector3 normal ) {
      m_normal = normal;
   }
   
   Color color() {
      return m_color;
   }
   
   void color( Color color ) {
      m_color = color;
   }
private:
   Vector3 m_normal;
   Color m_color;
}