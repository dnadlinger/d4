/**
 * A shader which simply uses the vertex colors to determine the pixel colors.
 *
 * Vertex type: ColoredVertex.
 */
module d4.shader.VertexColorShader;

// FIXME: Apparently, each vertex type must be included once in the global
// space for the mixin stuff to work. Import it here.
import d4.scene.ColoredVertex;

template VertexColorShader() {
   import d4.scene.ColoredVertex;

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredVertex cv = cast( ColoredVertex ) vertex;
      assert( cv !is null );

      position = worldViewProjMatrix * cv.position;
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
