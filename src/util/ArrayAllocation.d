module util.ArrayAllocation;

import tango.core.Memory;

/**
 * Manually allocates space for the array using malloc.
 * Params:
 *     array = The array to allocate space for.
 *     numItems = The number of elements to allocate space for.
 */
void allocate( Type )( inout Type array, uint numItems ) {
    alias typeof( Type[ 0 ] ) ItemType;
    array = ( cast( ItemType* ) GC.malloc( ItemType.sizeof * numItems ) )[ 0 .. numItems ];
}

/**
 * Reallocates (resizes) a manually allocated array.
 * Params:
 *     array = The array whose space to reallocate.
 *     numItems = The new size of the array.
 */
void reallocate( Type )( inout Type array, uint numItems ) {
    alias typeof( Type[ 0 ] ) ItemType;
    
    uint oldLength = array.length;
    uint numBytes = numItems * ItemType.sizeof;
    array = ( cast( ItemType* ) GC.realloc( array.ptr, numBytes ) )[ 0 .. numItems ];
}

/**
 * Frees the space manually allocated for an array.
 * Params:
 *     array = The array whose space to release.
 */
void free( Type )( inout Type array ) {
   assert( array !is null );
   GC.free( array.ptr );
   array = null;
}

/**
 * Clones the given array (manually malloc'd).
 * Params:
 *     source = The source array.
 * Returns: The cloned array.
 */
Type clone( Type )( Type source ) {
    Type result;
    alloc( result, array.length );
    result[] = source[];
    return result;
}