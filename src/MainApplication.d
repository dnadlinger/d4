module MainApplication;

import tango.math.Math : sin;
import d4.format.AssimpScene;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector3;
import d4.renderer.Renderer;
import d4.scene.MaterialManager;
import d4.scene.Node;
import d4.scene.Vertex;
import d4.util.Key;
import d4.util.SdlApplication;

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

      AssimpScene scene;

      // Try to import the scene using the normals given in the file. If this fails
      // (if there are none), generate them as specified in the params.
      // TODO: Make AssimpScene a loader and handle this in AssimpImporter itself.
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
      m_renderer.setProjection( PI / 4, 1f, 100f );
      m_cameraPosition = Vector3( 0, 0, 10 );

      m_materialManager = new MaterialManager( m_renderer );

      m_rotateWorld = false;
      m_animateBackground = false;
      m_backgroundTime = 0;
      m_renderer.clearColor = Color( 255, 255, 255 );
   }

   override void render( float deltaTime ) {
      if ( m_animateBackground ) {
         updateRainbowBackground( deltaTime );
      }
      if ( m_rotateWorld ) {
         updateRotatingWorld( deltaTime );
      }

      // Compute camera movement from keyboard input.
      Vector3 toCenter = Vector3( 0, 0, 0 ) - m_cameraPosition;
      toCenter.normalize();
      Vector3 toRight = toCenter.cross( Vector3( 0, 1, 0 ) );

      float movementSpeed = 10f;
      if ( isKeyDown( Key.LSHIFT ) ) {
         movementSpeed *= 10;
      }

      if ( isKeyDown( Key.w ) ) {
         m_cameraPosition += toCenter * deltaTime * movementSpeed;
      }
      if ( isKeyDown( Key.s ) ) {
         m_cameraPosition -= toCenter * deltaTime * movementSpeed;
      }
      if ( isKeyDown( Key.a ) ) {
         m_cameraPosition += toRight * deltaTime * movementSpeed;
      }
      if ( isKeyDown( Key.d ) ) {
         m_cameraPosition -= toRight * deltaTime * movementSpeed;
      }
      updateViewMatrix();

      m_renderer.beginScene();
      m_rootNode.render( m_renderer, m_materialManager );
      m_renderer.endScene();
   }

   override void shutdown() {
   }

   override void handleKeyUp( Key key ) {
      super.handleKeyUp( key );
      switch ( key ) {
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
      Matrix4 rotation = Matrix4.rotationZ( deltaTime * 0.3 );
      rotation *= Matrix4.rotationX( deltaTime * 0.7 );
      rotation *= Matrix4.rotationY( deltaTime * 1.2 );

      m_rootNode.transformation = rotation * m_rootNode.transformation;
   }
   
   void updateViewMatrix() {
      m_renderer.viewMatrix = Matrix4.lookAt( m_cameraPosition, Vector3( 0, 0, 0 ), Vector3( 0, 1, 0 ) );
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
}