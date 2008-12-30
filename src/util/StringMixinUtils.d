module util.StringMixinUtils;

char[] intToString( uint number ) {
   char digits[];
   if ( number > 10 ) {
      digits = intToString( number / 10 );
   }
   
   digits ~= cast( char )( '0' + number % 10 );
   return digits;
}

char[] stringUnroll( char[] front, char[] between, char[] back, uint times ) {
   char[] string;
   
   for ( uint i = 0; i < times; ++i ) {
      char[] index = intToString( i );
      string ~= front ~ index ~ between ~ index ~ back;
   }
   
   return string;
}

char[] stringUnroll( char[] front, char[] between1, char[] between2, char[] back, uint times ) {
   char[] string;
   
   for ( uint i = 0; i < times; ++i ) {
      char[] index = intToString( i );
      string ~= front ~ index ~ between1 ~ index ~ between2 ~ index ~ back;
   }
   
   return string;
}