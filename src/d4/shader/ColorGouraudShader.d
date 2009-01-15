module d4.shader.ColorGouraudShader;

template ColorGouraudShader( float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.ColoredNormalVertex;
   
   const LIGHT_DIRECTION = Vector3( lightDirX, lightDirY, lightDirZ ).normalized();
   
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredNormalVertex cnv = cast( ColoredNormalVertex ) vertex;
      assert( cnv !is null );
      
      Vector3 worldNormal = m_worldNormalMatrix.rotateVector( cnv.normal );
      
      // Light comes from top-left.
      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );
      
      // 0.1 represents the ambient light.
      if ( lightIntensity < 0.1 ) {
         lightIntensity = 0.1;
      }
      position = m_worldViewProjMatrix * cnv.position;
      variables.color = cnv.color * lightIntensity;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return variables.color;
   }
   
   struct VertexVariables {
      float[3] values;
      mixin( colorNoAlphaVariable!( "color", 0 ) );
   }
}