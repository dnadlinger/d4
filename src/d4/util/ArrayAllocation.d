/*
 * Copyright © 2010, klickverbot <klickverbot@gmail.com>.
 *
 * This file is part of d4, which is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * d4 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * d4. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Helper functions for manually allocating and freeing (non-GC'd) space for
 * arrays.
 */
module d4.util.ArrayAllocation;

import tango.core.Memory;

/**
 * Manually allocates space for the array using malloc.
 *
 * Params:
 *     array = The array to allocate space for.
 *     numItems = The number of elements to allocate space for.
 */
void allocate( Type )( inout Type array, uint numItems ) {
   alias typeof( Type[ 0 ] ) ItemType;
   array = ( cast( ItemType* ) GC.malloc( ItemType.sizeof * numItems ) )
      [ 0 .. numItems ];
}

/**
 * Reallocates (resizes) a manually allocated array.
 *
 * Params:
 *     array = The array whose space to reallocate.
 *     numItems = The new size of the array.
 */
void reallocate( Type )( inout Type array, uint numItems ) {
   alias typeof( Type[ 0 ] ) ItemType;

   uint oldLength = array.length;
   uint numBytes = numItems * ItemType.sizeof;
   array = ( cast( ItemType* ) GC.realloc( array.ptr, numBytes ) )
      [ 0 .. numItems ];
}

/**
 * Frees the space manually allocated for an array.
 *
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
 *
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
