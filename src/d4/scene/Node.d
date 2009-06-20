module d4.scene.Node;

import tango.io.Stdout;
import d4.math.Matrix4;
import d4.renderer.Renderer;
import d4.scene.MaterialManager;
import d4.scene.Mesh;

/**
 * A node in the tree-like scenegraph.
 *
 * It can contain any number of child nodes and meshes and stores a local
 * transformation matrix.
 */
class Node {
public:
   /**
    * Constructs an empty node with no children and no local transformations.
    */
   this() {
      m_localMatrix = Matrix4.identity;
      m_worldMatrix = Matrix4.identity;
      m_worldMatrixValid = false;
   }

   /**
    * Adds a child node to the tree. If the node already has another parent
    * node, it is removed from the tree first.
    *
    * Params:
    *     childNode = The child node to add.
    */
   void addChild( Node childNode ) {
      if ( childNode.parent !is null ) {
         childNode.parent.removeChild( childNode );
      }

      m_children ~= childNode;
      childNode.parent = this;
   }

   /**
    * Removes a child node from the tree. This works only with direct children,
    * not with child nodes which are attached somewhere deep down the hierachy.
    *
    * Params:
    *     childNode = The child node to remove from the tree.
    */
   void removeChild( Node childNode ) {
      foreach ( i, currentNode; m_children ) {
         if ( currentNode == childNode ) {
            // Since the order is not important, simply replace the node at the
            // current index with the last one and truncate the last element.
            m_children[ i ] = m_children[ $-1 ];
            m_children = m_children[ 0 .. ( $ - 1 ) ];
            childNode.parent = null;
            return;
         }
      }
      throw new Exception( "Could not remove child: Node not found in child list." );
   }

   /**
    * Adds a child mesh to the node.
    *
    * Params:
    *     mesh = The mesh to add.
    */
   void addMesh( Mesh mesh ) {
      m_meshes ~= mesh;
   }

   /**
    * Renders the local meshes and all child nodes using the specified renderer.
    *
    * Params:
    *     renderer = The renderer to use.
    *     manager = The material manager to use for rendering.
    */
   void render( Renderer renderer, MaterialManager manager ) {
      renderer.worldMatrix = worldMatrix();
      foreach ( mesh; m_meshes ) {
         mesh.render( renderer, manager );
      }

      // Render all child nodes. This enables us to render the whole scene by
      // just calling #render() on the root node.
      foreach ( node; m_children ) {
         node.render( renderer, manager );
      }
   }

   /**
    * The local transformation matrix.
    */
   Matrix4 transformation() {
      return m_localMatrix;
   }

   /// ditto
   void transformation( Matrix4 localMatrix ) {
      m_localMatrix = localMatrix;
      invalidateWorldMatrix();
   }

protected:
   Node parent() {
      return m_parent;
   }

   void parent( Node parentNode ) {
      m_parent = parentNode;
      invalidateWorldMatrix();
   }

   Matrix4 worldMatrix() {
      // If our cached world matrix is invalid, we have to update it.
      if ( !m_worldMatrixValid ) {
         if ( m_parent !is null ) {
            // Apply the local matrix first, then the parent's matrix.
            m_worldMatrix = m_parent.worldMatrix * m_localMatrix;
         } else {
            m_worldMatrix = m_localMatrix;
         }
         m_worldMatrixValid = true;
      }

      return m_worldMatrix;
   }

   void invalidateWorldMatrix() {
      m_worldMatrixValid = false;
      foreach ( node; m_children ) {
         node.invalidateWorldMatrix();
      }
   }

private:
   Node m_parent;
   Node[] m_children;

   Mesh[] m_meshes;
   Matrix4 m_localMatrix;
   Matrix4 m_worldMatrix;
   bool m_worldMatrixValid;
}
