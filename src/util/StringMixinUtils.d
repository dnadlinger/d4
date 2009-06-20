module util.StringMixinUtils;

/**
 * Converts an integer to a string containing all the digits.
 *
 * Params:
 *     number = The number to convert.
 * Returns: The string representation of the number.
 */
char[] intToString( uint number ) {
   char digits[];
   if ( number > 10 ) {
      digits = intToString( number / 10 );
   }

   digits ~= cast( char )( '0' + number % 10 );
   return digits;
}

/**
 * Unrolls a string operation.
 * You probably want to use this to prepare string mixins.
 */
char[] stringUnroll( char[] front, char[] between, char[] back, uint times ) {
   char[] string = "";

   for ( uint i = 0; i < times; ++i ) {
      char[] index = intToString( i );
      string ~= front ~ index ~ between ~ index ~ back;
   }

   return string;
}

/**
 * Unrolls a string operation.
 * You probably want to use this to prepare string mixins.
 */
char[] stringUnroll( char[] front, char[] between1, char[] between2, char[] back, uint times ) {
   char[] string = "";

   for ( uint i = 0; i < times; ++i ) {
      char[] index = intToString( i );
      string ~= front ~ index ~ between1 ~ index ~ between2 ~ index ~ back;
   }

   return string;
}
