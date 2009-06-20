module d4.scene.Vertex;

import d4.math.Vector3;

/**
 * A basic vertex consisting only of a (three-dimensional) position vector.
 */
class Vertex {
   /**
    * Constructs a new vertex instance.
    *
    * Params:
    *     position = The vertex position.
    */
   this( Vector3 position = Vector3() ) {
      m_position = position;
   }

   /**
    * The vertex position.
    */
   Vector3 position() {
      return m_position;
   }

   /// ditto
   void position( Vector3 position ) {
      m_position = position;
   }

private:
   Vector3 m_position;
}
