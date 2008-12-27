module d4.scene.Mesh;

import d4.renderer.Renderer;
import d4.scene.Material;
import d4.scene.Vertex;

class Mesh {
public:
   void render( Renderer renderer ) {
      material.setupRenderer( renderer );
      renderer.renderTriangleList( vertices, indices );
   }

   Vertex[] vertices;
   uint[] indices;
   Material material;
}