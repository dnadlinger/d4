module d4.scene.ColoredVertex;

import d4.math.Color;
import d4.scene.Vertex;

class ColoredVertex : Vertex {
public:
   Color color() {
      return m_color;
   }
   
   void color( Color color ) {
      m_color = color;
   }
private:
   Color m_color;
}