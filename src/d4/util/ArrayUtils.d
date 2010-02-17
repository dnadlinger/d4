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

module d4.util.ArrayUtils;

/**
 * Applies an operation to each array element, returning the result in a new
 * array of the same size.
 *
 * Params:
 *    source = The source array.
 *    func = The transformation function.
 * Returns:
 *    An array containing the results of the transformation function for each
 *    element.
 */
U[] map( T, U )( T[] source, U delegate( T ) func ) {
    U[] result;
    result.length = source.length;
    foreach( index, element; source ) {
        result[ index ] = func( element );
    }
    return result;
}

/**
 * Flattens a two-dimensional array into one dimension.
 *
 * Params:
 *    source = The source array.
 * Returns: The flattened array.
 */
T[] flatten( T )( T[][] source ) {
   T[] result;
   foreach ( element; source ) {
      result ~= element;
   }
   return result;
}

/**
 * Adds a fixed value to each array element.
 *
 * Params:
 *    source = The source array.
 *    summand = The summand to add to each element of the source array.
 * Returns: A new array containing the resulting values.
 */
T[] add( T, U )( T[] source, U summand ) {
   return source.map( ( T t ){ return t + summand; } );
}
