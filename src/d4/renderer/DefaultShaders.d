module d4.renderer.DefaultShaders;

import d4.scene.Vertex;
import d4.math.Color;
import d4.math.Vector4;
import d4.renderer.PixelShader;
import d4.renderer.VertexVariables;
import d4.renderer.VertexShader;


class DefaultVertexShader : VertexShader {
   this() {
      m_nullVariables = new DefaultVertexVariables();
   }
   
   void process( in Vertex vertex, out Vector4 position, out VertexVariables data ) {
      position = m_combinedTransformation * vertex.position;
      data = m_nullVariables;
   }
   
private:
   DefaultVertexVariables m_nullVariables;
}

class DefaultPixelShader : PixelShader {
   Color process( VertexVariables data ) {
      return Color( 255, 255, 255, 255 );
   }
}

class DefaultVertexVariables : VertexVariables {
   uint variableCount() {
      return 0;
   }
   
   float getVariable( uint index ) {
      assert( false, "Asked for non-existing vertex variable." );
      return 0.f;
   }
   
   void setVariables( uint index, float value ) {
      assert( false, "Tried to set non-existing vertex variable." );
   }
}