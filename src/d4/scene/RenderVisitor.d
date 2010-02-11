module d4.scene.RenderVisitor;

import d4.renderer.Renderer;
import d4.scene.ISceneVisitor;
import d4.scene.Mesh;
import d4.scene.Node;

class RenderVisitor : ISceneVisitor {
public:
   this( Renderer renderer ) {
      m_renderer = renderer;
   }

   void visitNode( Node node ) {
      m_renderer.worldMatrix = node.worldMatrix;
   }

   void visitMesh( Mesh mesh ) {
      m_renderer.activateMaterial( mesh.material );
      m_renderer.renderTriangleList( mesh.vertices, mesh.indices );
   }

private:
   Renderer m_renderer;
}
