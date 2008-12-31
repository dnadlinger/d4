module d4.renderer.DefaultShader;

template DefaultShader() {
   import d4.math.Vector3;
   import d4.scene.ColoredVertex;
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredVertex cv = cast( ColoredVertex ) vertex;
      assert( cv !is null );
      
      // Should probably use the inverse transposed matrix instead.
      Vector3 worldNormal = m_worldMatrix.rotateVector( cv.normal ).normalized();
      
      // Light comes from top-left.
      float lightIntensity = worldNormal.dot( Vector3( 0, 0.707106781187, -0.707106781187 ) );
      
      // 0.1 represents the ambient light.
      if ( lightIntensity < 0.1 ) {
         lightIntensity = 0.1;
      }
      position = m_worldViewProjMatrix * cv.position;
      variables.color = cv.color * lightIntensity;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return variables.color;
   }
   
   struct VertexVariables {
      float[4] values;
      mixin( colorVariable!( "color", 0 ) );
   }
}