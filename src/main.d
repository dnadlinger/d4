module main;

import tango.core.Array;
import tango.math.Math : sin;
import d4.format.AssimpLoader;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector3;
import d4.renderer.Renderer;
import d4.scene.Node;
import d4.scene.Vertex;
import d4.util.Key;
import d4.util.SdlApplication;

class MainApplication : SdlApplication {
public:
   void modelFile( char[] fileName ) {
      m_modelFileName = fileName;
   }
   
   void fakeColors( bool fakeColors ) {
      m_fakeColors = fakeColors;
   }
   
   void smoothNormals( bool smoothNormals ) {
      m_smoothNormals = smoothNormals;
   }

protected:
   override void init() {
      assert( m_modelFileName.length > 0 );

      auto loader = new AssimpLoader( m_modelFileName, m_smoothNormals, m_fakeColors );
      m_rootNode = loader.rootNode;

      m_renderer = new Renderer( screen() );
      m_renderer.backfaceCulling = BackfaceCulling.CULL_CW;
      m_renderer.setProjection( PI / 2, 0.5f, 200f );
      m_cameraPosition = Vector3( 0, 0, -10 );

      m_rotateWorld = false;
      m_animateBackground = false;
      m_backgroundTime = 0;
      updateRainbowBackground( 0 );
   }

   override void render( float deltaTime ) {
      if ( m_animateBackground ) {
         updateRainbowBackground( deltaTime );
      }
      if ( m_rotateWorld ) {
         updateRotatingWorld( deltaTime );
      }

      Vector3 toCenter = Vector3( 0, 0, 0 ) - m_cameraPosition;
      toCenter.normalize();
      Vector3 toRight = Vector3( 0, 1, 0 ).cross( toCenter );
      const movementSpeed = 10;
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
      m_rootNode.render( m_renderer );
      m_renderer.endScene();
   }

   override void shutdown() {
   }

   override void handleKeyUp( Key key ) {
      super.handleKeyUp( key );
      switch ( key ) {
         case Key.x:
            m_renderer.wireframe = !m_renderer.wireframe;
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

   char[] m_modelFileName;
   bool m_smoothNormals;
   bool m_fakeColors;

   Renderer m_renderer;
   Node m_rootNode;

   bool m_rotateWorld;
   bool m_animateBackground;
   float m_backgroundTime;
   
   Vector3 m_cameraPosition;
}

void main( char[][] args ) {
   scope auto app = new MainApplication();
   
   try {
      app.modelFile = args[ 1 ];
   } catch ( Exception e ) {
      throw new Exception( "Please specify a model file at the command line" );
   }
   
   if ( contains( args[ 2..$ ], "smoothNormals" ) ) {
      app.smoothNormals = true;
   }
   
   if ( contains( args[ 2..$ ], "fakeColors" ) ) {
      app.fakeColors = true;
   }
   
   app.run();
}