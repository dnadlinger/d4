module d4.math.Transformations;

import d4.math.Matrix4;
import d4.math.Quaternion;
import d4.math.Vector3;
import d4.math.Vector4;

static Matrix4 scalingMatrix( float factorX = 1.f, float factorY = 1.f, float factorZ = 1.f ) {
   Matrix4 m = Matrix4.identity();

   m.m11 = factorX;
   m.m22 = factorY;
   m.m33 = factorZ;

   return m;
}

static Matrix4 scalingMatrix( Vector3 vector ) {
   return scalingMatrix( vector.x, vector.y, vector.z );
}

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

static Matrix4 translationMatrix( float deltaX = 0.f, float deltaY = 0.f, float deltaZ = 0.f ) {
   Matrix4 m = Matrix4.identity();

   m.m14 = deltaX;
   m.m24 = deltaY;
   m.m34 = deltaZ;

   return m;
}

static Matrix4 translationMatrix( Vector3 vector ) {
   return translationMatrix( vector.x, vector.y, vector.z );
}

static Matrix4 cameraMatrix( Vector3 position, Vector3 direction, Vector3 up ) {
   Vector3 right = direction.cross( up );

   Matrix4 m = Matrix4.identity();

   m.m11 = right.x;
   m.m12 = up.x;
   m.m13 = -direction.x;
   m.m14 = -right.dot( position );

   m.m21 = right.y;
   m.m22 = up.y;
   m.m23 = -direction.y;
   m.m24 = -up.dot( position );

   m.m31 = right.z;
   m.m32 = up.z;
   m.m33 = -direction.z;
   m.m34 = direction.dot( position );

   return m;
}

static Matrix4 lookAtMatrix( Vector3 position, Vector3 target, Vector3 worldUp ) {
   Vector3 direction = target - position;
   direction.normalize();

   Vector3 cameraUp = worldUp - ( direction.dot( worldUp ) * direction );
   
   if ( cameraUp.sqrLength() < 1e-6f ) {
      throw new Exception( "Unsuitable world up vector (looking straight up or down?).");
   }
   
   cameraUp.normalize();

   return cameraMatrix( position, direction, cameraUp );
}

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