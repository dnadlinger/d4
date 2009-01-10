module d4.scene.Mesh;

import d4.renderer.Renderer;
import d4.scene.Material;
import d4.scene.MaterialManager;
import d4.scene.Vertex;

class Mesh {
public:
   void render( Renderer renderer, MaterialManager manager ) {
      manager.activateMaterial( material );
      renderer.renderTriangleList( vertices, indices );
   }

   Vertex[] vertices;
   uint[] indices;
   Material material;
}