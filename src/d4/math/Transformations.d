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
 * Functions to construct transformation matrices and quaternions.
 */
module d4.math.Transformations;

import tango.math.Math : sin, cos, tan;
import d4.math.Matrix4;
import d4.math.Quaternion;
import d4.math.Vector3;
import d4.math.Vector4;

/**
 * Constructs a scaling matrix from the three axis scaling factors (100% = 1).
 *
 * Params:
 *     factorX = The scaling factor along the x axis.
 *     factorY = The scaling factor along the y axis.
 *     factorZ = The scaling factor along the z axis.
 * Returns: The scaling matix.
 */
static Matrix4 scalingMatrix( float factorX = 1.f, float factorY = 1.f,
   float factorZ = 1.f ) {

   Matrix4 m = Matrix4.identity();

   m.m11 = factorX;
   m.m22 = factorY;
   m.m33 = factorZ;

   return m;
}

/**
 * Constructs a scaling matrix from the three axis scaling factors stored in
 * a Vector3 (100% = 1).
 *
 * Params:
 *     vector = The scaling factors.
 * Returns: The scaling matrix.
 */
static Matrix4 scalingMatrix( Vector3 vector ) {
   return scalingMatrix( vector.x, vector.y, vector.z );
}

/**
 * Constructs a matrix which represents a rotation aroud the x axis.
 *
 * Params:
 *     angleRadians = The angle to rotate about (in radians).
 * Returns: The rotation matrix.
 */
static Matrix4 xRotationMatrix( float angleRadians ) {
   Matrix4 m = Matrix4.identity();

   float sin = sin( angleRadians );
   float cos = cos( angleRadians );

   m.m22 = cos;
   m.m23 = -sin;

   m.m32 = sin;
   m.m33 = cos;

   return m;
}

/**
 * Constructs a matrix which represents a rotation aroud the y axis.
 *
 * Params:
 *     angleRadians = The angle to rotate about (in radians).
 * Returns: The rotation matrix.
 */
static Matrix4 yRotationMatrix( float angleRadians ) {
   Matrix4 m = Matrix4.identity();

   float sin = sin( angleRadians );
   float cos = cos( angleRadians );

   m.m11 = cos;
   m.m13 = sin;

   m.m31 = -sin;
   m.m33 = cos;

   return m;
}

/**
 * Constructs a matrix which represents a rotation aroud the z axis.
 *
 * Params:
 *     angleRadians = The angle to rotate about (in radians).
 * Returns: The rotation matrix.
 */
static Matrix4 zRotationMatrix( float angleRadians ) {
   Matrix4 m = Matrix4.identity();

   float sin = sin( angleRadians );
   float cos = cos( angleRadians );

   m.m11 = cos;
   m.m12 = -sin;

   m.m21 = sin;
   m.m22 = cos;

   return m;
}

/**
 * Constructs a rotation quaternion from the rotation axis and the rotation
 * angle.
 *
 * Params:
 *     angle = The angle to rotate about (in radians).
 *     axis = The axis to rotate around.
 * Returns: The rotation quaternion.
 */
static Quaternion rotationQuaternion( float angle, Vector3 axis ) {
   Quaternion result;

   Vector3 v = axis.normalized();
   v *= sin( angle );

   result.w = cos( angle );
   result.x = v.x;
   result.y = v.y;
   result.z = v.z;

   return result;
}

/**
 * Constructs a rotation matrix from the given rotation quaternion.
 *
 * Params:
 *     q = The rotation quaternion.
 * Returns: A matrix representing the same rotation as the quaternion.
 */
static Matrix4 rotationMatrix( Quaternion q ) {
   Matrix4 m = Matrix4.identity();

   float _2x = q.x + q.x;
   float _2y = q.y + q.y;
   float _2z = q.z + q.z;

   float _2xx = _2x * q.x;
   float _2xy = _2x * q.y;
   float _2xz = _2x * q.z;
   float _2xw = _2x * q.w;

   float _2yy = _2y * q.y;
   float _2yz = _2y * q.z;
   float _2yw = _2y * q.w;

   float _2zz = _2z * q.z;
   float _2zw = _2z * q.w;

   m.m11 = 1 - _2yy - _2zz;
   m.m12 = _2xy - _2zw;
   m.m13 = _2xz + _2yw;

   m.m21 = _2xy + _2zw;
   m.m22 = 1 - _2xx - _2zz;
   m.m23 = _2yz - _2xw;

   m.m31 = _2xz - _2yw;
   m.m32 = _2yz + _2xw;
   m.m33 = 1 - _2xx - _2yy;

   return m;
}

/**
 * Constructs a translation matrix with the amount given component-wise.
 *
 * Params:
 *     deltaX = The distance to move along the x axis.
 *     deltaY = The distance to move along the y axis.
 *     deltaZ = The distance to move along the z axis.
 * Returns: The translation matrix.
 */
static Matrix4 translationMatrix( float deltaX = 0.f, float deltaY = 0.f,
   float deltaZ = 0.f ) {

   Matrix4 m = Matrix4.identity();

   m.m14 = deltaX;
   m.m24 = deltaY;
   m.m34 = deltaZ;

   return m;
}

/**
 * Constructs a translation matrix with the amount given as a vector.
 *
 * Params:
 *     vector = The distance to move.
 * Returns: The translation matrix.
 */
static Matrix4 translationMatrix( Vector3 vector ) {
   return translationMatrix( vector.x, vector.y, vector.z );
}

/**
 * Constructs a view matrix from the camera position and direction.
 *
 * Params:
 *     position = The position of the camera (usually in world coordinates.
 *     direction = The direction the camera is facing.
 *     up = The camera up vector.
 * Returns: The view matrix.
 */
static Matrix4 cameraMatrix( Vector3 position, Vector3 direction, Vector3 up ) {
   Vector3 right = direction.cross( up );

   Matrix4 m = Matrix4.identity();

   m.m11 = right.x;
   m.m12 = right.y;
   m.m13 = right.z;
   m.m14 = -right.dot( position );

   m.m21 = up.x;
   m.m22 = up.y;
   m.m23 = up.z;
   m.m24 = -up.dot( position );

   m.m31 = -direction.x;
   m.m32 = -direction.y;
   m.m33 = -direction.z;
   m.m34 = direction.dot( position );

   return m;
}

/**
 * Constructs a view matrix from the camera position and a target.
 *
 * The world up vector is used to derive the camera up vector and must not be
 * too close to the direction vector.
 *
 * Params:
 *     position = The camera position.
 *     target = The point the camera is looking at.
 *     worldUp = The world up vector (usually [0,1,0]).
 * Returns: The view matrix.
 */
static Matrix4 lookAtMatrix( Vector3 position, Vector3 target, Vector3 worldUp ) {
   Vector3 direction = target - position;
   direction.normalize();

   Vector3 cameraUp = worldUp - ( direction.dot( worldUp ) * direction );

   if ( cameraUp.sqrLength() < 1e-6f ) {
      throw new Exception(
         "Unsuitable world up vector (looking straight up or down?).");
   }

   cameraUp.normalize();

   return cameraMatrix( position, direction, cameraUp );
}

/**
 * Constructs a perspective projection matrix from the projection parameters.
 *
 * Params:
 *     fovRadians = The vertical view angle.
 *     aspectRatio = The aspect ratio of the viewing window.
 *     nearDistance = The distance of the near clipping plane (>0).
 *     farDistance = The distance of the far clipping plane (>nearDistance).
 * Returns: The projection matrix.
 */
static Matrix4 perspectiveProjectionMatrix( float fovRadians, float aspectRatio,
   float nearDistance, float farDistance ) {

   if ( farDistance - nearDistance < 0.01 ) {
      throw new Exception( "Could not create perspective projection matrix: " ~
         "Far clipping plane too close to near clipping plane." );
   }

   float p = farDistance / ( nearDistance - farDistance );
   float q = p * nearDistance;

   float fovScale = 1 / tan( fovRadians * 0.5 );
   if ( fovScale < 0.01 ) {
      throw new Exception( "Could not create perspective projection matrix: " ~
         "Field of view opening angle too big." );
   }

   Matrix4 m = Matrix4.identity();

   m.m11 = fovScale * ( 1 / aspectRatio );

   m.m22 = fovScale;

   m.m33 = p;
   m.m34 = q;

   m.m43 = -1;
   m.m44 = 0;

   return m;
}
