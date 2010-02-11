module d4.math.Color;

import d4.math.Vector3;

/**
 * A 32-bit color, stored in memory as ARGB.
 */
struct Color {
   union {
      // The reverse order of the ARGB values is due to the little endian-nature.
      struct {
         ubyte b; /// The blue component.
         ubyte g; /// The green component.
         ubyte r; /// The red component.
         ubyte a; /// The alpha (transparency) component.
      }

      uint value; /// The whole 32 bits of color data.
   }

   /**
    * Constructs a Color instance from the color specified component-wise.
    * Params:
    *     r = The red value.
    *     g = The green value.
    *     b = The blue value.
    *     a = The alpha value.
    * Returns: The new Color instance.
    */
   static Color opCall( ubyte r = 255, ubyte g = 255, ubyte b = 255, ubyte a = 255 ) {
      Color color = void;
      color.r = r;
      color.g = g;
      color.b = b;
      color.a = a;
      return color;
   }

   /**
    * Constructs a Color instance directly from the color value
    * (often referred to as "hex-code").
    *
    * Params:
    *     value = The color value.
    * Returns: The new Color instance.
    */
   static Color opCall( uint value ) {
      Color color = void;
      color.value = value;
      return color;
   }

   /**
    * Adds another Color to this instance.
    * Note: the values are not automatically clamped!
    *
    * Params:
    *     other = The color to add.
    */
   void opAddAssign( Color other ) {
      value += other.value;
   }

   /**
    * Multiplies a color with a scalar.
    * Note: the values are not automatically clamped!
    *
    * Params:
    *     factor = The factor to multiply the color with.
    * Returns: A new Color instance containing the result.
    */
   Color opMul( float factor ) {
      Color color = void;
      // TODO: Optimize cast?
      color.r = cast( ubyte )( r * factor );
      color.g = cast( ubyte )( g * factor );
      color.b = cast( ubyte )( b * factor );
      return color;
   }

   static const uint RED_MASK = 255 << 16; /// Bit mask for the red component.
   static const uint GREEN_MASK = 255 << 8; /// Bit mask for the green component.
   static const uint BLUE_MASK = 255; /// Bit mask for the blue component.
   static const uint ALPHA_MASK = 255 << 24; /// Bit mask for the alpha component.
}

/**
 * Converts a Color to a Vector3 (used to store Color values into
 * VertexVariables in the vertex shader).
 */
final Vector3 colorToVector3( Color color ) {
   Vector3 result = void;
   result.x = cast( float )color.r;
   result.y = cast( float )color.g;
   result.z = cast( float )color.b;
   return result;
}

/**
 * Converts a Vector3 to a Color (used to retrieve Color values from the
 * interpolated VertexVariables in the pixel shader).
 */
final Color vector3ToColor( bool CheckForOverrun = false )( Vector3 vector ) {
   Color result = void;
   result.a = 255;
   static if ( CheckForOverrun ) {
      if ( vector.x > 255 ) {
         result.r = 255;
      } else {
         result.r = cast( ubyte )vector.x;
      }
      if ( vector.y > 255 ) {
         result.g = 255;
      } else {
         result.g = cast( ubyte )vector.y;
      }
      if ( vector.z > 255 ) {
         result.b = 255;
      } else {
         result.b = cast( ubyte )vector.z;
      }
   } else {
      result.r = cast( ubyte )vector.x;
      result.g = cast( ubyte )vector.y;
      result.b = cast( ubyte )vector.z;
   }

   return result;
}
