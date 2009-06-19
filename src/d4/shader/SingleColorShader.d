/**
 * A shader which simply paints all objects white.
 *
 * Vertex types: any.
 */
module d4.shader.SingleColorShader;

/*
 * A command like this:
 * new SolidGouraudRasterizer!( SingleColorShader, Color() )();
 * will somehow cause dmd to abort with a segfault. Just removed the color
 * parameter for now.
 *
 * The intended declaration was:
 * template SingleColorShader( alias surfaceColor )
 */
template SingleColorShader() {
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      position = worldViewProjMatrix * vertex.position;
   }

   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255 );
   }

   struct VertexVariables {
      float[0] values;
   }
}
