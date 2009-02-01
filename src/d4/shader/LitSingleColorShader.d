module d4.shader.LitSingleColorShader;

/**
 * See SingleColorShader.
 */
template LitSingleColorShader( float ambientLevel, float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.TexturedNormalVertex;

   const LIGHT_DIRECTION = Vector3( lightDirX, lightDirY, lightDirZ ).normalized();

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      // TODO: Allow also other vertex types with normals.
      TexturedNormalVertex tnv = cast( TexturedNormalVertex ) vertex;
      assert( tnv !is null );

      // Should probably use the inverse transposed matrix instead.
      Vector3 worldNormal = worldNormalMatrix.rotateVector( tnv.normal );

      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );

      // ambientLevel represents the ambient light.
      if ( lightIntensity < ambientLevel ) {
         lightIntensity = ambientLevel;
      }

      position = worldViewProjMatrix * tnv.position;
      variables.brightness = lightIntensity;
   }

   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255 ) * variables.brightness;
   }

   struct VertexVariables {
      float[1] values;
      mixin( floatVariable!( "brightness", 0 ) );
   }
}