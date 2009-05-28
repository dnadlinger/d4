/**
 * A shader which combines a diffuse texture and gouraud lightnig (via the
 * vertex normal vectors) to determine the pixel colors.
 * 
 * Vertex type: TexturedNormalVertex.
 */
module d4.shader.LitTextureShader;

template LitTextureShader( float ambientLevel, float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.TexturedNormalVertex;

   const LIGHT_DIRECTION = Vector3( lightDirX, lightDirY, lightDirZ ).normalized();

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      TexturedNormalVertex tnv = cast( TexturedNormalVertex ) vertex;
      assert( tnv !is null );

      Vector3 worldNormal = worldNormalMatrix.rotateVector( tnv.normal );

      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );

      // ambientLevel represents the ambient light.
      if ( lightIntensity < ambientLevel ) {
         lightIntensity = ambientLevel;
      }

      position = worldViewProjMatrix * tnv.position;
      variables.texCoords = tnv.texCoords;
      variables.brightness = lightIntensity;
   }

   Color pixelShader( VertexVariables variables ) {
      return readTexture!( true, true )( 0, variables.texCoords ) * variables.brightness;
   }

   struct VertexVariables {
      float[3] values;
      mixin( vector2Variable!( "texCoords", 0 ) );
      mixin( floatVariable!( "brightness", 2 ) );
   }
}