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

module d4.app.FreeCamera;

import tango.math.Math : PI;
import d4.app.Key;
import d4.math.Matrix4;
import d4.math.Quaternion;
import d4.math.Transformations;
import d4.math.Vector3;
import d4.renderer.Renderer;

/**
 * Provides a basic free camera mode for <code>Rendering!( Application )</code>s.
 *
 * Controls are WSAD for the movement and the cursor keys for the rotation, with
 * SHIFT increasing the speed for both.
 */
abstract class FreeCamera( alias Base ) : Base {
public:
   this( char[][] args ) {
      super( args );
   }

protected:
   abstract override void init() {
      super.init();

      m_cameraPosition = Vector3( 0, 0, 10 );
      m_cameraRotation = Quaternion();
   }

   abstract override void render( float deltaTime ) {
      super.render( deltaTime );
      updateCamera( deltaTime );
   }

   final Vector3 cameraPosition() {
      return m_cameraPosition;
   }
   final void cameraPosition( Vector3 position ) {
      m_cameraPosition = position;
   }

   final Quaternion cameraRotation() {
      return m_cameraRotation;
   }
   final void cameraRotation( Quaternion rotation ) {
      m_cameraRotation = rotation;
   }

private:
   void updateCamera( float deltaTime ) {
      // Compute camera movement from keyboard input.
      float movementSpeed = 6f;
      float rotationSpeed = PI / 8;
      if ( isKeyDown( Key.LSHIFT ) || isKeyDown( Key.RSHIFT ) ) {
         movementSpeed *= 4;
         rotationSpeed *= 3;
      }

      if ( isKeyDown( Key.UP ) ) {
         m_cameraRotation.append(
            rotationQuaternion( -rotationSpeed * deltaTime, Vector3( 1, 0, 0 ) ) );
      }
      if ( isKeyDown( Key.DOWN ) ) {
         m_cameraRotation.append(
            rotationQuaternion( rotationSpeed * deltaTime, Vector3( 1, 0, 0 ) ) );
      }
      if ( isKeyDown( Key.LEFT ) ) {
         m_cameraRotation.append(
            rotationQuaternion( -rotationSpeed * deltaTime, Vector3( 0, 1, 0 ) ) );
      }
      if ( isKeyDown( Key.RIGHT ) ) {
         m_cameraRotation.append(
            rotationQuaternion( rotationSpeed * deltaTime, Vector3( 0, 1, 0 ) ) );
      }

      // TODO: File LDC bug about this.
      Matrix4 invMat = renderer().viewMatrix;
      invMat = invMat.inversed();
      Vector3 forwardDirection = -Vector3( invMat.m13, invMat.m23, invMat.m33 );
      Vector3 leftDirection = -Vector3( invMat.m11, invMat.m21, invMat.m31 );

      if ( isKeyDown( Key.w ) ) {
         m_cameraPosition += forwardDirection * deltaTime * movementSpeed;
      }
      if ( isKeyDown( Key.s ) ) {
         m_cameraPosition -= forwardDirection * deltaTime * movementSpeed;
      }
      if ( isKeyDown( Key.a ) ) {
         m_cameraPosition += leftDirection * deltaTime * movementSpeed;
      }
      if ( isKeyDown( Key.d ) ) {
         m_cameraPosition -= leftDirection * deltaTime * movementSpeed;
      }

      renderer().viewMatrix = rotationMatrix( m_cameraRotation ) * translationMatrix( -m_cameraPosition );
   }

   Vector3 m_cameraPosition;
   Quaternion m_cameraRotation;
}
