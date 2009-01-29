module d4.scene.TexturedNormalVertex;

import d4.math.Vector2;
import d4.math.Vector3;
import d4.scene.Vertex;

class TexturedNormalVertex : Vertex {
public:
   Vector3 normal() {
      return m_normal;
   }
   
   void normal( Vector3 normal ) {
      m_normal = normal;
   }
   
   Vector2 texCoords() {
      return m_texCoords;
   }
   
   void texCoords( Vector2 texCoords ) {
      m_texCoords = texCoords;
   }

private:
   Vector3 m_normal;
   Vector2 m_texCoords;
}