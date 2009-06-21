module RoomScene;

import d4.math.Vector3;
import d4.scene.Mesh;
import d4.scene.Node;
import d4.scene.NormalVertex;
import d4.scene.Scene;
import util.ArrayUtils;

class RoomScene : Scene {
   this( float size ) {
      Mesh mesh = new Mesh();

      // Floor.
      const FLOOR_NORMAL = Vector3( 0, 1, 0 );
      mesh.indices ~= [ 0u, 1u, 2u, 2u, 1u, 3u ].add( mesh.vertices.length );
      mesh.vertices ~= [
         new NormalVertex( Vector3( -size, 0, -size ), FLOOR_NORMAL ),
         new NormalVertex( Vector3( -size, 0, size ), FLOOR_NORMAL ),
         new NormalVertex( Vector3( size, 0, -size ), FLOOR_NORMAL ),
         new NormalVertex( Vector3( size, 0, size ), FLOOR_NORMAL )
      ];

      // Ceiling.
      const CEILING_NORMAL = Vector3( 0, -1, 0 );
      mesh.indices ~= [ 0u, 2u, 1u, 1u, 2u, 3u ].add( mesh.vertices.length );
      mesh.vertices ~= [
         new NormalVertex( Vector3( -size, size, -size ), CEILING_NORMAL ),
         new NormalVertex( Vector3( -size, size, size ), CEILING_NORMAL ),
         new NormalVertex( Vector3( size, size, -size ), CEILING_NORMAL ),
         new NormalVertex( Vector3( size, size, size ), CEILING_NORMAL )
      ];

      // Left wall.
      const LEFT_NORMAL = Vector3( 1, 0, 0 );
      mesh.indices ~= [ 0u, 1u, 2u, 2u, 1u, 3u ].add( mesh.vertices.length );
      mesh.vertices ~= [
         new NormalVertex( Vector3( -size, size, size ), LEFT_NORMAL ),
         new NormalVertex( Vector3( -size, 0, size ), LEFT_NORMAL ),
         new NormalVertex( Vector3( -size, size, -size ), LEFT_NORMAL ),
         new NormalVertex( Vector3( -size, 0, -size ), LEFT_NORMAL )
      ];

      // Right wall.
      const RIGHT_NORMAL = Vector3( -1, 0, 0 );
      mesh.indices ~= [ 0u, 2u, 1u, 1u, 2u, 3u ].add( mesh.vertices.length );
      mesh.vertices ~= [
         new NormalVertex( Vector3( size, size, size ), RIGHT_NORMAL ),
         new NormalVertex( Vector3( size, 0, size ), RIGHT_NORMAL ),
         new NormalVertex( Vector3( size, size, -size ), RIGHT_NORMAL ),
         new NormalVertex( Vector3( size, 0, -size ), RIGHT_NORMAL )
      ];

      // Front wall.
      const FRONT_NORMAL = Vector3( 0, 0, -1 );
      mesh.indices ~= [ 0u, 2u, 1u, 1u, 2u, 3u ].add( mesh.vertices.length );
      mesh.vertices ~= [
         new NormalVertex( Vector3( -size, size, size ), FRONT_NORMAL ),
         new NormalVertex( Vector3( -size, 0, size ), FRONT_NORMAL ),
         new NormalVertex( Vector3( size, size, size ), FRONT_NORMAL ),
         new NormalVertex( Vector3( size, 0, size ), FRONT_NORMAL )
      ];

      // Back wall.
      const BACK_NORMAL = Vector3( 0, 0, 1 );
      mesh.indices ~= [ 0u, 1u, 2u, 2u, 1u, 3u ].add( mesh.vertices.length );
      mesh.vertices ~= [
         new NormalVertex( Vector3( -size, size, -size ), BACK_NORMAL ),
         new NormalVertex( Vector3( -size, 0, -size ), BACK_NORMAL ),
         new NormalVertex( Vector3( size, size, -size ), BACK_NORMAL ),
         new NormalVertex( Vector3( size, 0, -size ), BACK_NORMAL )
      ];

      m_rootNode = new Node();
      m_rootNode.addMesh( mesh );
   }

   override Node rootNode() {
      return m_rootNode;
   }

private:
   Node m_rootNode;
}
