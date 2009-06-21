module util.ArrayUtils;

// Thanks to DanielKeep (freenode#d) for this gem.
U[] map( T, U )( T[] source, U delegate( T ) func ) {
    U[] result;
    result.length = source.length;
    foreach( index, element; source ) {
        result[ index ] = func( element );
    }
    return result;
}

T[] add( T )( T[] source, T summand ) {
   return source.map( ( T t ){ return t + summand; } );
}
