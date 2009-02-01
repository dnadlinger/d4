module d4.scene.Image;

import tango.io.Stdout;
import tango.math.Math : rndint;
import d4.math.Color;

class Image {
   this( uint width, uint height, Color[] colorData ) {
      m_width = width;
      m_height = height;
      m_colorData = colorData;
   }
   
   uint width() {
      return m_width;
   }
   
   uint height() {
      return m_height;
   }
   
   Color[] colorData() {
      return m_colorData;
   }
   
   Color readColor( uint x, uint y ) {
      assert( x >= 0 );
      assert( y >= 0 );
      assert( x < m_width );
      assert( y < m_height );
      
      return m_colorData[ rndint( y ) * m_width + rndint( x ) ];
   }
   
private:
   uint m_width;
   uint m_height;
   Color[] m_colorData;
}