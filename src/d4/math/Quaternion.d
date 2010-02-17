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

module d4.math.Quaternion;

import tango.math.Math : sin, cos;
import d4.math.Vector3;

/**
 * A quaternion in the form q = xi + yj + zk + w.
 */
struct Quaternion {
   /**
    * Constructs a new quaternion from the four components.
    * Params:
    *     newW = The w-component (real).
    *     newX = The x-component (i).
    *     newY = The y-component (j).
    *     newZ = The z-component (k).
    * Returns:
    */
   static Quaternion opCall( float newW = 1f, float newX = 0f, float newY = 0f,
      float newZ = 0f ) {

      Quaternion result;
      result.w = newW;
      result.x = newX;
      result.y = newY;
      result.z = newZ;
      return result;
   }

   /**
    * Constructs a new quaternion from the scalar and the vector part.
    * Params:
    *     scalar = The scalar part of the quaternion (w).
    *     vector = The vector part of the quaternion (x, y, z).
    * Returns: The new quaternion.
    */
   static Quaternion opCall( float scalar, Vector3 vector ) {
      Quaternion result;
      result.w = scalar;
      result.x = vector.x;
      result.y = vector.y;
      result.z = vector.z;
      return result;
   }

   /**
    * Multiplies this quaternion with another quaternion.
    * Note: This operation is not commutative!
    *
    * Params:
    *     rhs = The right hand side quaternion.
    * Returns: A new quaternion containing the product.
    */
   Quaternion opMul( Quaternion rhs ) {
      // TODO: Can we do this? opMul is defined to be commutative?!
      Quaternion result;

      result.w = w * rhs.w - x * rhs.x - y * rhs.y - z * rhs.z;
      result.x = w * rhs.x + rhs.w * x + y * rhs.z - rhs.y * z;
      result.y = w * rhs.y + rhs.w * y + z * rhs.x - rhs.z * x;
      result.z = w * rhs.z + rhs.w * z + x * rhs.y - rhs.x * y;

      return result;
   }

   /**
    * Multiplies this quaternion with another quaternion and saves the result
    * to this object.
    *
    * Params:
    *     rhs = The right hand side quaternion.
    */
   void opMulAssign( Quaternion rhs ) {
      (*this) = (*this) * rhs;
   }

   /**
    * Multiplies this quaternion with another quaternion and saves the result
    * to this object.
    *
    * This is basically the same as the *= operator, but the two quaternions are
    * swapped. This allows for easy and concise concatenation of rotations.
    *
    * Params:
    *     lhs = The left hand side quaternion.
    */
   void append( Quaternion lhs ) {
      (*this) = lhs * (*this);
   }

   float w; /// The w (real) component of the quaternion.
   float x; /// The x (i) component of the quaternion.
   float y; /// The y (j) component of the quaternion.
   float z; /// The z (k) component of the quaternion.
}
