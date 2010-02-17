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

module d4.util.EnumUtils;

/**
 * Advances the passed enumeration value by the given number of steps, wrapping
 * around if the limit has been reached.
 *
 * Of course, this requires the enumeration items to be numbered continuously.
 *
 * Params:
 *    value = The start value.
 *    offset = The number of steps to advance the value. Negative values also
 *       work like expected.
 * Returns:
 *    The advanced value.
 */
T step( T )( T value, int offset ) {
   return cast( T )( ( value + offset ) % ( value.max + 1 ) );
}
