module d4.shader.DefaultShader;

template DefaultShader() {
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      position = m_worldViewProjMatrix * vertex.position;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255 );
   }
   
   struct VertexVariables {
      float[0] values;
   }
}