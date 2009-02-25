module d4.scene.Mesh;

import d4.renderer.Renderer;
import d4.scene.Material;
import d4.scene.MaterialManager;
import d4.scene.Vertex;

/**
 * A triangle mesh consisting of an indexed triangle list.
 * All the triangles are rendered with one material.
 */
class Mesh {
public:
   /**
    * Renders the mesh.
    *  
    * Params:
    *     renderer = The renderer to use. 
    *     manager = The material manager connected with the renderer.
    */
   void render( Renderer renderer, MaterialManager manager ) {
      manager.activateMaterial( material );
      renderer.renderTriangleList( vertices, indices );
   }

   /**
    * The vertex buffer of the mesh.
    */
   Vertex[] vertices;
   
   /**
    * The incides for the vertex buffer.
    * 
    * The size of this must always be dividable by three, because there are
    * only completed trinagles allowed.
    */
   uint[] indices;
   
   /**
    * The material to use for the mesh.
    */
   Material material;
}
