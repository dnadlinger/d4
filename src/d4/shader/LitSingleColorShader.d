/**
 * A shader which paints all object white, but takes gouraud lighting (via the
 * vertex normal vectors) into account.
 *
 * Vertex type: NormalVertex.
 */
module d4.shader.LitSingleColorShader;

/*
 * See SingleColorShader.
 */
template LitSingleColorShader( float ambientLevel, float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.NormalVertex;

   const LIGHT_DIRECTION = Vector3( lightDirX, lightDirY, lightDirZ ).normalized();

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      NormalVertex nv = cast( NormalVertex ) vertex;
      assert( nv !is null );

      Vector3 worldNormal = worldNormalMatrix.rotateVector( nv.normal );

      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );

      // ambientLevel represents the ambient light.
      if ( lightIntensity < ambientLevel ) {
         lightIntensity = ambientLevel;
      }

      position = worldViewProjMatrix * nv.position;
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
