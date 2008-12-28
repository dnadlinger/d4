module d4.renderer.DefaultShader;

template DefaultShader() {
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      position = m_worldViewProjMatrix * vertex.position;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255, 255 );
   }
   
   struct VertexVariables {
      // No variables needed for this shader.
   }
   
   VertexVariables interpolateLinear( VertexVariables first, VertexVariables second, float position ) {
      VertexVariables result;
      return result;
   }
   
   void scale( VertexVariables target, float factor ) {
      // No variables needed for this shader.
   }
}