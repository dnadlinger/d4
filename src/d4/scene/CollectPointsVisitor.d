module d4.scene.CollectPointsVisitor;

import d4.math.Vector3;
import d4.math.Matrix4;
import d4.scene.ISceneVisitor;
import d4.scene.Mesh;
import d4.scene.Node;

class CollectPointsVisitor : ISceneVisitor {
public:
   this() {
      m_result = [];
   }

   void visitNode( Node node ) {
      m_currentWorldMatrix = node.worldMatrix();
   }

   void visitMesh( Mesh mesh ) {
      foreach ( vertex; mesh.vertices ) {
         m_result ~= m_currentWorldMatrix.transformLinear( vertex.position );
      }
   }

   Vector3[] result() {
      return m_result;
   }

private:
   Vector3[] m_result;
   Matrix4 m_currentWorldMatrix;
}