module d4.output.Surface;

import d4.math.Color;

abstract class Surface {
public:
   abstract uint width();
   abstract uint height();

   abstract void lock();
   abstract void unlock();

   abstract Color* pixels();

   abstract Color pixel( uint x, uint y );
   abstract void setPixel( uint x, uint y, Color color );
   abstract void clear( Color clearColor );
}