module d4.scene.Mesh;

import d4.renderer.IMaterial;
import d4.scene.ISceneElement;
import d4.scene.ISceneVisitor;
import d4.scene.Vertex;

/**
 * A triangle mesh consisting of an indexed triangle list.
 * All the triangles are rendered with one material.
 */
class Mesh : ISceneElement {
public:
   void accept( ISceneVisitor visitor ) {
      visitor.visitMesh( this );
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
   IMaterial material;
}
