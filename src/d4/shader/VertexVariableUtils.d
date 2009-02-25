/**
 * Utility mixins for creating the VertexVariable structs.
 */
module d4.shader.VertexVariableUtils;

import util.StringMixinUtils;

/**
 * Declares a scalar float variable.
 */
template floatVariable( char[] name, uint index ) {
   const char[] floatVariable =
      "float " ~ name ~ "() { "
         "return values[" ~ intToString( index ) ~  "];"
      "}"
      "void " ~ name ~ "( float value ) { "
         "values[" ~ intToString( index ) ~  "] = value;"
      "}";
}

/**
 * Declares a Vector2 variable.
 */
template vector2Variable( char[] name, uint index ) {
   const char[] vector2Variable =
      "Vector2 " ~ name ~ "() { "
         "return Vector2( values[" ~ intToString( index ) ~  "], values[" ~
         intToString( index + 1 ) ~ "] );"
      "}"
      "void " ~ name ~ "( Vector2 vector ) { "
         "values[" ~ intToString( index ) ~  "] = vector.x;"
         "values[" ~ intToString( index + 1 ) ~  "] = vector.y;"
      "}";
}

/**
 * Declares a Vector3 variable.
 */
template vector3Variable( char[] name, uint index ) {
   const char[] vector3Variable =
      "Vector3 " ~ name ~ "() { "
         "return Vector3( values[" ~ intToString( index ) ~  "], values[" ~
         intToString( index + 1 ) ~ "], values[" ~ intToString( index + 2 ) ~ "] );"
      "}"
      "void " ~ name ~ "( Vector3 vector ) { "
         "values[" ~ intToString( index ) ~  "] = vector.x;"
         "values[" ~ intToString( index + 1 ) ~  "] = vector.y;"
         "values[" ~ intToString( index + 2 ) ~  "] = vector.z;"
      "}";
}

/**
 * Declares a Color variable which uses all four components.
 * If the alpha channel is not needed, consider using colorNoAlphaVariable instead.
 */
template colorVariable( char[] name, uint index ) {
   const char[] colorVariable =
      "Color " ~ name ~ "() {"
         "Color result;"
         "result.a = cast( ubyte )( values[" ~ intToString( index ) ~  "] * 255 );"
         "result.r = cast( ubyte )( values[" ~ intToString( index + 1 ) ~  "] * 255 );"
         "result.g = cast( ubyte )( values[" ~ intToString( index + 2 ) ~  "] * 255 );"
         "result.b = cast( ubyte )( values[" ~ intToString( index + 3 ) ~  "] * 255 );"
         "return result;"
      "}"
      "void " ~ name ~ "( Color color ) {"
         "values[" ~ intToString( index ) ~  "] = cast( float ) color.a / 255f;"
         "values[" ~ intToString( index + 1 ) ~  "] = cast( float ) color.r / 255f;"
         "values[" ~ intToString( index + 2 ) ~  "] = cast( float ) color.g / 255f;"
         "values[" ~ intToString( index + 3 ) ~  "] = cast( float ) color.b / 255f;"
      "}";
}

/**
 * Declares a color variable that does not use the alpha channel
 * (it is always set to 255).
 * 
 * Using this over colorVariable when no alpha channel is needed gives a 
 * significant performance boost.
 */
template colorNoAlphaVariable( char[] name, uint index ) {
   const char[] colorNoAlphaVariable =
      "Color " ~ name ~ "() {"
         "Color result;"
         "result.a = 255;"
         "result.r = cast( ubyte )( values[" ~ intToString( index ) ~  "] * 255 );"
         "result.g = cast( ubyte )( values[" ~ intToString( index + 1 ) ~  "] * 255 );"
         "result.b = cast( ubyte )( values[" ~ intToString( index + 2 ) ~  "] * 255 );"
         "return result;"
      "}"
      "void " ~ name ~ "( Color color ) {"
         "values[" ~ intToString( index ) ~  "] = cast( float ) color.r / 255f;"
         "values[" ~ intToString( index + 1 ) ~  "] = cast( float ) color.g / 255f;"
         "values[" ~ intToString( index + 2 ) ~  "] = cast( float ) color.b / 255f;"
      "}";
}