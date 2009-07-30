/**
 * A shader which combines the vertex colors with gouraud lightnig (via the
 * vertex normal vectors) to determine the pixel colors.
 *
 * Vertex type: ColoredNormalVertex.
 */
module d4.shader.LitVertexColorShader;

template LitVertexColorShader( float ambientLevel, float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.ColoredNormalVertex;

   const LIGHT_DIRECTION = CTFE_normalize( Vector3( lightDirX, lightDirY, lightDirZ ) );

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
      variables.color = colorToVector3( cnv.color ) * lightIntensity;
   }

   Color pixelShader( VertexVariables variables ) {
      return vector3ToColor( variables.color );
   }

   struct VertexVariables {
      Vector3 color;
   }
}
