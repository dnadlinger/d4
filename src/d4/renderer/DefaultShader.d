module d4.renderer.DefaultShader;

template DefaultShader() {
   import d4.math.Vector3;
   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      ColoredVertex cv = cast( ColoredVertex ) vertex;
      assert( cv !is null );
      
      // Assumes that the world matrix does not scale the normal, otherwise we
      // would have to normalize the vector.
      // Should probably use the inverse transposed matrix instead.
      Vector3 worldNormal = m_worldMatrix.rotateVector( cv.normal );
      float lightIntensity = worldNormal.dot( Vector3( 0, -0.707106781187, 0.707106781187 ) );
      
      // 0.1 represents the ambient light.
      if ( lightIntensity < 0.1 ) {
         lightIntensity = 0.1;
      }
      position = m_worldViewProjMatrix * cv.position;
      variables.color = cv.color * lightIntensity;
   }
   
   Color pixelShader( VertexVariables variables ) {
      return variables.color;
   }
   
   struct VertexVariables {
      float[4] values;
      Color color() {
         Color result;
         result.a = cast( ubyte )( values[ 0 ] * 255 );
         result.r = cast( ubyte )( values[ 1 ] * 255 );
         result.g = cast( ubyte )( values[ 2 ] * 255 );
         result.b = cast( ubyte )( values[ 3 ] * 255 );
         return result;
      }
      
      void color( Color color ) {
         values[ 0 ] = cast( float ) color.a / 255f;
         values[ 1 ] = cast( float ) color.r / 255f;
         values[ 2 ] = cast( float ) color.g / 255f;
         values[ 3 ] = cast( float ) color.b / 255f;
      }
   }
   
   VertexVariables lerp( VertexVariables first, VertexVariables second, float position ) {
      return add( first, scale( substract( second, first ), position ) );
   }
   
   VertexVariables scale( VertexVariables variables, float factor ) {
      VertexVariables result;
      for ( uint i = 0; i < result.values.length; ++i ) {
         result.values[ i ] = variables.values[ i ] * factor;
      }
      return result;
   }
   
   VertexVariables add( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      for ( uint i = 0; i < result.values.length; ++i ) {
         result.values[ i ] = first.values[ i ] + second.values[ i ];
      }
      return result;
   }
   
   VertexVariables substract( VertexVariables first, VertexVariables second ) {
      VertexVariables result;
      for ( uint i = 0; i < result.values.length; ++i ) {
         result.values[ i ] = first.values[ i ] - second.values[ i ];
      }
      return result;
   }
}