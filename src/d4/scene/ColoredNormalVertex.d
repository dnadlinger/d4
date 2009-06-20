module d4.scene.ColoredNormalVertex;

import d4.math.Color;
import d4.scene.NormalVertex;

/**
 * A vertex consisting of a position vector, a vertex color and a normal vector.
 */
class ColoredNormalVertex : NormalVertex {
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
