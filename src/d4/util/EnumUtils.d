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
