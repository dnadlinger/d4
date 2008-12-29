module d4.renderer.ZBuffer;

import tango.io.Stdout;

class ZBuffer {
   this( uint width, uint height ) {
      m_width = width;
      m_height = height;
      for ( uint i = 0; i < width * height; ++i ) {
         m_buffer ~= 1f;
      }
   }
   
   bool testAndUpdate( uint x, uint y, float z ) {
      if ( width <= x ) {
         Stdout( "Illegal x coordinate for z buffer access: " )( x ).newline;
         return false;
      }
      if ( height <= y ) {
         Stdout( "Illegal y coordinate for z buffer access: " )( y ).newline;
         return false;
      }
      assert( x < width );
      assert( y < height );
      
      if ( z < m_buffer[ y * width + x ] ) {
         m_buffer[ y * width + x ] = z;
         return true;
      }
      return false;
   }
   
   void clear() {
      m_buffer[] = 1f;
   }

   uint width() {
      return m_width;
   }

   uint height() {
      return m_height;
   }

private:
   uint m_width;
   uint m_height;
   float[] m_buffer;
}