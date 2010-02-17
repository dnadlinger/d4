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

module d4.math.AABB;

import Math = tango.math.Math;
import d4.math.Vector3;

/**
 * An axis-aligned bounding box.
 */
struct AABB {
   /**
    * Constructs a bounding box for the given points.
    *
    * Params:
    *    points = At least one point in space the bounding box will contain.
    * Returns:
    *    An axis-aligned bounding box which contains all the given points.
    */
   static AABB opCall( Vector3[] points ) {
      assert( points.length > 0 );

      AABB result;

      result.min = points[ 0 ];
      result.max = points[ 0 ];
      result.contain( points[ 1..$ ] );

      return result;
   }

   /**
    * Enlarges the bounding box so that the given point lies inside of it.
    *
    * Params:
    *    points = The point which shall lie inside the box.
    */
   void contain( Vector3 point ) {
      min.x = Math.min( min.x, point.x );
      min.y = Math.min( min.y, point.y );
      min.z = Math.min( min.z, point.z );

      max.x = Math.max( max.x, point.x );
      max.y = Math.max( max.y, point.y );
      max.z = Math.max( max.z, point.z );
   }

   /**
    * Enlarges the bounding box so that all given points lie inside of it.
    *
    * Params:
    *    points = The points which shall lie inside the box.
    */
   void contain( Vector3[] points ) {
      foreach ( point; points ) {
         contain( point );
      }
   }

   void enlarge( float delta ) {
      enlarge( Vector3( delta, delta, delta ) );
   }

   void enlarge( Vector3 delta ) {
      min -= delta;
      max += delta;
   }


   Vector3 min;
   Vector3 max;
}
