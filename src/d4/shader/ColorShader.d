module d4.shader.ColorShader;

template ColorShader() {
   import d4.scene.ColoredVertex;
   
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredVertex cv = cast( ColoredVertex ) vertex;
      assert( cv !is null );
      
      position = m_worldViewProjMatrix * cv.position;
      variables.color = cv.color;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return variables.color;
   }
   
   struct VertexVariables {
      float[3] values;
      mixin( colorNoAlphaVariable!( "color", 0 ) );
   }
}