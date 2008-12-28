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
   
   VertexVariables lerp( VertexVariables first, VertexVariables second, float position ) {
      return add( first, scale( substract( second, first ), position ) );
   }
   
   VertexVariables scale( VertexVariables variables, float factor ) {
      VertexVariables result;
      return result;
   }
   
   VertexVariables add( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      return result;
   }
   
   VertexVariables substract( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      return result;
   }
}