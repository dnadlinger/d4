module d4.scene.Vertex;

import d4.math.Vector3;

class Vertex {
   this( Vector3 position = Vector3() ) {
      m_position = position;
   }

   Vector3 position() {
      return m_position;
   }

   void position( Vector3 position ) {
      m_position = position;
   }

private:
   Vector3 m_position;
}