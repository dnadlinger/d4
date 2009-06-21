module FreeCameraApplication;

import tango.math.Math : PI;
import d4.math.Matrix4;
import d4.math.Quaternion;
import d4.math.Transformations;
import d4.math.Vector3;
import d4.renderer.Renderer;
import d4.util.Key;
import SdlRendererApplication;

/**
 * An application template for SDL applications using a completely free camera.
 *
 * TODO: Move out of a subclass into a mixin of some sort.
 */
abstract class FreeCameraApplication : SdlRendererApplication {
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

protected:
   final void cameraPosition() {
      return m_cameraPosition;
   }
   final void cameraPosition( Vector3 position ) {
      m_cameraPosition = position;
   }

   final void cameraRotation() {
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
         m_cameraRotation.append( rotationQuaternion( -rotationSpeed * deltaTime, Vector3( 1, 0, 0 ) ) );
      }
      if ( isKeyDown( Key.DOWN ) ) {
         m_cameraRotation.append( rotationQuaternion( rotationSpeed * deltaTime, Vector3( 1, 0, 0 ) ) );
      }
      if ( isKeyDown( Key.LEFT ) ) {
         m_cameraRotation.append( rotationQuaternion( -rotationSpeed * deltaTime, Vector3( 0, 1, 0 ) ) );
      }
      if ( isKeyDown( Key.RIGHT ) ) {
         m_cameraRotation.append( rotationQuaternion( rotationSpeed * deltaTime, Vector3( 0, 1, 0 ) ) );
      }

      Matrix4 invMat = renderer().viewMatrix.inversed();
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
