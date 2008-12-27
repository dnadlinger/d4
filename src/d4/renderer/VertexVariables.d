module d4.renderer.VertexVariables;

abstract class VertexVariables {
   abstract uint variableCount();
   abstract float getVariable( uint index );
   abstract void setVariables( uint index, float value );
}