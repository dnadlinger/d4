module d4.scene.ColoredVertex;

import d4.math.Color;
import d4.scene.Vertex;

/**
 * A simple vertex with just a position vector and a vertex color.
 */
class ColoredVertex : Vertex {
public:
   /**
    * The vertex color.
    */
   Color color() {
      return m_color;
   }
   
   /// ditto
   void color( Color color ) {
      m_color = color;
   }
private:
   Color m_color;
}