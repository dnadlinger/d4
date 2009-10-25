module d4.scene.FixedMaterialRenderVisitor;

import d4.renderer.IMaterial;
import d4.renderer.Renderer;
import d4.scene.ISceneVisitor;
import d4.scene.Mesh;
import d4.scene.Node;

class FixedMaterialRenderVisitor : ISceneVisitor {
public:
   this( Renderer renderer, IMaterial material ) {
      m_renderer = renderer;
      m_material = material;
   }

   void visitNode( Node node ) {
      m_renderer.worldMatrix = node.worldMatrix;
   }

   void visitMesh( Mesh mesh ) {
      m_renderer.activateMaterial( m_material );
      m_renderer.renderTriangleList( mesh.vertices, mesh.indices );
   }

private:
   Renderer m_renderer;
   IMaterial m_material;
}
