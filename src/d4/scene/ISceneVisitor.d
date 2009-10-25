module d4.scene.ISceneVisitor;

import d4.scene.Mesh;
import d4.scene.Node;

interface ISceneVisitor {
   void visitMesh( Mesh mesh );
   void visitNode( Node node );
}
