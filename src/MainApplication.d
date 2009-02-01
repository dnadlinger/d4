module MainApplication;

import tango.io.Stdout;
import tango.math.Math : sin;
import d4.format.AssimpScene;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Quaternion;
import d4.math.Transformations;
import d4.math.Vector3;
import d4.renderer.Renderer;
import d4.scene.MaterialManager;
import d4.scene.Node;
import d4.scene.Vertex;
import d4.util.Key;
import d4.util.SdlApplication;

enum ShadingMode {
   FLAT,
   GOURAUD,
   GOURAUD_TEXTURED
}

class MainApplication : SdlApplication {
public:
   void sceneFile( char[] fileName ) {
      m_sceneFileName = fileName;
   }
   
   void fakeColors( bool fakeColors ) {
      m_fakeColors = fakeColors;
   }
   
   void generateSmoothNormals( bool smooth ) {
      m_generateSmoothNormals = smooth;
   }

protected:
   override void init() {
      assert( m_sceneFileName.length > 0 );

      // Try to import the scene using the normals given in the file. If this fails
      // (if there are none), generate them as specified in the params.
      // TODO: Make AssimpScene a loader and handle this in AssimpImporter itself.
      AssimpScene scene;
      try {
         scene = new AssimpScene( m_sceneFileName, NormalType.FILE, m_fakeColors );
      } catch {
         NormalType normals;
         if ( m_generateSmoothNormals ) {
            normals = NormalType.GENERATE_SMOOTH;
         } else {
            normals = NormalType.GENERATE;
         }
         scene = new AssimpScene( m_sceneFileName, normals, m_fakeColors );
      }
      m_rootNode = scene.rootNode;

      m_renderer = new Renderer( screen() );
      m_renderer.backfaceCulling = BackfaceCulling.CULL_CW;
      m_renderer.setProjection( PI / 3, 0.5f, 1000f );

      m_cameraPosition = Vector3( 0, 0, 10 );
      m_cameraRotation = Quaternion();

      m_materialManager = new MaterialManager( m_renderer );
      // Enable everything by default.
      m_shadingMode = ShadingMode.GOURAUD_TEXTURED;
      updateShadingMode();

      m_rotateWorld = false;
      m_animateBackground = false;
      m_backgroundTime = 0;
      m_renderer.clearColor = Color( 0, 0, 0 );
   }

   override void render( float deltaTime ) {
      if ( m_animateBackground ) {
         updateRainbowBackground( deltaTime );
      }
      if ( m_rotateWorld ) {
         updateRotatingWorld( deltaTime );
      }

      updateCamera( deltaTime );

      m_renderer.beginScene();
      m_rootNode.render( m_renderer, m_materialManager );
      m_renderer.endScene();
   }

   override void shutdown() {
   }

   override void handleKeyUp( Key key ) {
      super.handleKeyUp( key );
      switch ( key ) {
         case Key.y:
            m_shadingMode = cast( ShadingMode )( ( m_shadingMode + 1 ) % ( m_shadingMode.max + 1 ) );
            updateShadingMode();
            break;
         case Key.x:
            m_materialManager.forceWireframe = !m_materialManager.forceWireframe;
            break;
         case Key.c:
            m_renderer.backfaceCulling = cast( BackfaceCulling )
               ( ( m_renderer.backfaceCulling + 1 ) % ( BackfaceCulling.max + 1 ) );
            break;
         case Key.v:
            m_rotateWorld = !m_rotateWorld;
            break;
         case Key.b:
            m_animateBackground = !m_animateBackground;
            break;
         default:
            // Do nothing.
            break;
      }
   }

private:
   void updateRainbowBackground( float deltaTime ) {
      m_backgroundTime += deltaTime;
      ubyte red = 128 + cast( ubyte )( 128 * sin( m_backgroundTime ) );
      ubyte green = 128 + cast( ubyte )( 128 * sin( m_backgroundTime - 1 ) );
      ubyte blue = 128 + cast( ubyte )( 128 * sin( m_backgroundTime + 1 ) );
      m_renderer.clearColor = Color( red, green, blue );
   }

   void updateRotatingWorld( float deltaTime ) {
      Matrix4 rotation = zRotationMatrix( deltaTime * 0.3 );
      rotation *= yRotationMatrix( deltaTime * 0.7 );
      rotation *= xRotationMatrix( deltaTime * 1.2 );

      m_rootNode.transformation = rotation * m_rootNode.transformation;
   }
   
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

      Matrix4 invMat = m_renderer.viewMatrix.inversed();
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

      m_renderer.viewMatrix = rotationMatrix( m_cameraRotation ) * translationMatrix( -m_cameraPosition );
   }

   void updateShadingMode() {
      switch ( m_shadingMode ) {
         case ShadingMode.FLAT:
            m_materialManager.forceFlatShading = true;
            m_materialManager.skipTextures = true;
            break;
         case ShadingMode.GOURAUD:
            m_materialManager.forceFlatShading = false;
            m_materialManager.skipTextures = true;
            break;
         case ShadingMode.GOURAUD_TEXTURED:
            m_materialManager.forceFlatShading = false;
            m_materialManager.skipTextures = false;
            break;
      }
   }

   char[] m_sceneFileName;
   bool m_generateSmoothNormals;
   bool m_fakeColors;

   Renderer m_renderer;
   MaterialManager m_materialManager;
   Node m_rootNode;

   bool m_rotateWorld;
   bool m_animateBackground;
   float m_backgroundTime;
   
   Vector3 m_cameraPosition;
   Quaternion m_cameraRotation;

   ShadingMode m_shadingMode;
}