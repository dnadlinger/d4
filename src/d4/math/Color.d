module d4.math.Color;

struct Color {
   union {
      // The reverse order of the ARGB values is due to the little endian-nature.
      struct {
         ubyte b = 0;
         ubyte g = 0;
         ubyte r = 0;
         ubyte a = 255;
      }
      
      uint value;
   }
   
   static Color opCall( ubyte r, ubyte g, ubyte b, ubyte a = 255 ) {
      Color color;
      color.r = r;
      color.g = g;
      color.b = b;
      color.a = a;
      return color;
   }
   
   static const uint RED_MASK = 255 << 16;
   static const uint GREEN_MASK = 255 << 8;
   static const uint BLUE_MASK = 255;
   static const uint ALPHA_MASK = 255 << 24;
}