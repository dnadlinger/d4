module d4.renderer.PixelShader;

import d4.renderer.VertexVariables;
import d4.math.Color;

abstract class PixelShader {
   abstract Color process( VertexVariables data );
}