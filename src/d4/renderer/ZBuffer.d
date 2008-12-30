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

   float* data() {
      return cast( float* )m_buffer;
   }

private:
   uint m_width;
   uint m_height;
   float[] m_buffer;
}