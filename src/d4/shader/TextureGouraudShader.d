module d4.shader.TextureGouraudShader;

template TextureGouraudShader( float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.TexturedNormalVertex;

   const LIGHT_DIRECTION = Vector3( lightDirX, lightDirY, lightDirZ ).normalized();

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      TexturedNormalVertex tnv = cast( TexturedNormalVertex ) vertex;
      assert( tnv !is null );

      // Should probably use the inverse transposed matrix instead.
      Vector3 worldNormal = worldNormalMatrix.rotateVector( tnv.normal );

      // Light comes from top-left.
      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );

      // 0.1 represents the ambient light.
      if ( lightIntensity < 0.1 ) {
         lightIntensity = 0.1;
      }

      position = worldViewProjMatrix * tnv.position;
      variables.texCoords = tnv.texCoords;
      variables.brightness = lightIntensity;
   }

   Color pixelShader( VertexVariables variables ) {
      return readTextureNearest( 0, variables.texCoords ) * variables.brightness;
   }

   struct VertexVariables {
      float[3] values;
      mixin( vector2Variable!( "texCoords", 0 ) );
      mixin( floatVariable!( "brightness", 2 ) );
   }
}