module d4.scene.Image;

import tango.io.Stdout;
import tango.math.Math : rndint;
import d4.math.Color;

/**
 * A 32-bit per pixel bitmap.
 * 
 * The pixel data is stored in Color objects.
 */
class Image {
   /**
    * Constructs a new Image object.
    * 
    * Params:
    *     width = The width of the image. 
    *     height = The height of the image.
    *     colorData = The color data (pixels) of the image.
    */
   this( uint width, uint height, Color[] colorData ) {
      m_width = width;
      m_height = height;
      m_colorData = colorData;
   }
   
   /**
    * The image width (in pixels, obviously).
    */
   uint width() {
      return m_width;
   }
   
   /**
    * The image height (in pixels, obviously).
    */
   uint height() {
      return m_height;
   }
   
   /**
    * Returns a reference to the color data.
    * You probably want to use readColor instead to get additional safety checks.
    */
   Color[] colorData() {
      return m_colorData;
   }
   
   /**
    * Reads a pixel from the image.
    * 
    * Params:
    *     x = The x-coordinate of the pixel to read (zero-based).
    *     y = The y-coordinate of the pixel to read (zero-based).
    * Returns: The pixel color.
    */
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