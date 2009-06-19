/**
 * A shader which applies a single diffuse texture.
 * 
 * Vertex type: TexturedNormalVertex.
 */
module d4.shader.TextureShader;

template TextureShader() {
   import d4.scene.TexturedNormalVertex;

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      // TODO: Allow other vertex types.
      TexturedNormalVertex tnv = cast( TexturedNormalVertex ) vertex;
      assert( tnv !is null );

      position = worldViewProjMatrix * tnv.position;
      variables.texCoords = tnv.texCoords;
   }

   Color pixelShader( VertexVariables variables ) {
      return readTexture!( true, true )( 0, variables.texCoords );
   }

   struct VertexVariables {
      float[2] values;
      mixin( vector2Variable!( "texCoords", 0 ) );
   }
}