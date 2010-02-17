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

// Thanks to DanielKeep (freenode#d) for this gem.
U[] map( T, U )( T[] source, U delegate( T ) func ) {
    U[] result;
    result.length = source.length;
    foreach( index, element; source ) {
        result[ index ] = func( element );
    }
    return result;
}

T[] flatten( T )( T[][] source ) {
   T[] result;
   foreach ( element; source ) {
      result ~= element;
   }
   return result;
}

T[] add( T )( T[] source, T summand ) {
   return source.map( ( T t ){ return t + summand; } );
}
