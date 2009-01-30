module d4.shader.ColorGouraudShader;

template ColorGouraudShader( float ambientLevel, float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.ColoredNormalVertex;
   
   const LIGHT_DIRECTION = Vector3( lightDirX, lightDirY, lightDirZ ).normalized();
   
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredNormalVertex cnv = cast( ColoredNormalVertex ) vertex;
      assert( cnv !is null );
      
      Vector3 worldNormal = worldNormalMatrix.rotateVector( cnv.normal );
      
      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );
      
      // ambientLevel represents the ambient light.
      if ( lightIntensity < ambientLevel ) {
         lightIntensity = ambientLevel;
      }
      position = worldViewProjMatrix * cnv.position;
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