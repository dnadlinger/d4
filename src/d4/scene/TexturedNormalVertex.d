module d4.scene.TexturedNormalVertex;

import d4.math.Vector2;
import d4.scene.NormalVertex;

/**
 * A vertex consisting of a position vector, a normal vector, and a pair of
 * texture coordinates.
 *
 * This is the standard for lit, textured models.
 */
class TexturedNormalVertex : NormalVertex {
public:
   /**
    * The vertex texture coordinates.
    */
   Vector2 texCoords() {
      return m_texCoords;
   }

   /// ditto
   void texCoords( Vector2 texCoords ) {
      m_texCoords = texCoords;
   }

private:
   Vector2 m_texCoords;
}
