module d4.output.Surface;

import d4.math.Color;

abstract class Surface {
   abstract uint width();
   abstract uint height();

   abstract bool lock();
   abstract void unlock();

   abstract Color pixel( uint x, uint y );
   abstract void setPixel( uint x, uint y, Color color );
   
   abstract void clear( Color clearColor );
}