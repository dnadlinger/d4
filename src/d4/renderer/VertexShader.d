module d4.renderer.VertexShader;

import d4.renderer.VertexVariables;
import d4.math.Vector4;
import d4.math.Matrix4;
import d4.scene.Vertex;

/**
 * Transforms a vertex from from world coordinates into clipping coordinates
 * and calculates additional per-vertex data.
 */
class VertexShader {   
   abstract void process( in Vertex vertex, out Vector4 position, out VertexVariables data );
   
   void setCombinedTransformation( Matrix4 transformation ) {
      m_combinedTransformation = transformation;
   }
   
protected:
   Matrix4 m_combinedTransformation;
}