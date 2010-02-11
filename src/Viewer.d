/**
 * Simple model viewer.
 *
 * Expects at least one parameter, the model file to display.
 *
 * Additional parameters:
 *   - smooth-normals: If there are no normals present in the model file,
 *     smoothed ones are generated (hard faces otherwise).
 *   - fake-colors: Assings a random color to each vertex.
 */
module Viewer;

import tango.core.Array;
import tango.io.Stdout;
import tango.math.Math : sin, PI;
import d4.format.AssimpScene;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Quaternion;
import d4.math.Transformations;
import d4.renderer.IMaterial;
import d4.renderer.SolidRasterizer;
import d4.scene.BasicMaterial;
import d4.scene.IBasicRasterizerFactory;
import d4.scene.ISceneVisitor;
import d4.scene.Node;
import d4.scene.Scene;
import d4.scene.FixedMaterialRenderVisitor;
import d4.scene.GenericBasicRasterizerFactory;
import d4.scene.RenderVisitor;
import d4.scene.Vertex;
import d4.shader.LitSingleColorShader;
import d4.shader.SingleColorShader;
import d4.util.FreeCameraApplication;
import d4.util.Key;
import util.EntryPoint;

/**
 * The available shading modes.
 */
enum ShadingMode {
   FLAT,
   GOURAUD,
   GOURAUD_TEXTURED
}

/**
 * The main application class.
 * Manages the scene, reacts to user input, etc.
 */
class Viewer : FreeCameraApplication {
public:
   this( char[][] args ) {
      super( args );
   }
protected:
   override void init() {
      super.init();

      m_rasterizerFactory = new GenericBasicRasterizerFactory();

      assert( m_sceneFileName.length > 0 );

      Stdout.newline;
      m_scene = new AssimpScene( m_sceneFileName, m_rasterizerFactory,
         m_generateSmoothNormals, m_fakeColors );

      m_rotateWorld = false;
      m_animateBackground = false;
      m_backgroundTime = 0;
      renderer().clearColor = Color( 0, 0, 0 );

      // Enable everything by default.
      m_shadingMode = ShadingMode.GOURAUD_TEXTURED;
      m_forceWireframe = false;

      m_wireframeMaterial = new BasicMaterial( m_rasterizerFactory );
      m_wireframeMaterial.wireframe = true;

      m_flatMaterial = new BasicMaterial( m_rasterizerFactory );
      m_flatMaterial.gouraudShading = false;
      m_flatMaterial.lighting = true;

      m_gouraudMaterial = new BasicMaterial( m_rasterizerFactory );
      m_gouraudMaterial.vertexColors = false;
      m_gouraudMaterial.lighting = true;
   }

   override void render( float deltaTime ) {
      super.render( deltaTime );

      if ( m_animateBackground ) {
         updateRainbowBackground( deltaTime );
      }
      if ( m_rotateWorld ) {
         updateRotatingWorld( deltaTime );
      }

      ISceneVisitor renderVisitor;

      if ( m_forceWireframe ) {
         renderVisitor = new FixedMaterialRenderVisitor(
            renderer(), m_wireframeMaterial );
      } else {
         switch ( m_shadingMode ) {
            case ShadingMode.FLAT:
               renderVisitor = new FixedMaterialRenderVisitor(
                  renderer(), m_flatMaterial );
               break;
            case ShadingMode.GOURAUD:
               renderVisitor = new FixedMaterialRenderVisitor(
                  renderer(), m_gouraudMaterial );
               break;
            case ShadingMode.GOURAUD_TEXTURED:
               renderVisitor = new RenderVisitor( renderer() );
               break;
         }
      }

      renderer().beginScene();
      m_scene.rootNode.accept( renderVisitor );
      renderer().endScene();
   }

   override void shutdown() {
      super.shutdown();
   }

   override void handleKeyUp( Key key ) {
      super.handleKeyUp( key );

      switch ( key ) {
         case Key.y:
         case Key.z:
            m_shadingMode = cast( ShadingMode )( ( m_shadingMode + 1 ) % ( m_shadingMode.max + 1 ) );
            break;
         case Key.x:
            m_forceWireframe = !m_forceWireframe;
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

   override void handleSwitchArgument( char[] name ) {
      switch ( name ) {
         case "smooth-normals":
            m_generateSmoothNormals = true;
            break;
         case "fake-colors":
            m_fakeColors = true;
            break;
         default:
            super.handleSwitchArgument( name );
            break;
      }
   }

   override void handleUnnamedArguments( char[][] values ) {
      if ( values.length == 0 ) {
         throw new Exception(
            "Please specify a model file to load at the command line." );
      }

      m_sceneFileName = values[ $ - 1 ];

      super.handleUnnamedArguments( values[ 0..($-1) ] );
   }

private:
   void updateRainbowBackground( float deltaTime ) {
      m_backgroundTime += deltaTime;
      ubyte red = 128 + cast( ubyte )( 128 * sin( m_backgroundTime ) );
      ubyte green = 128 + cast( ubyte )( 128 * sin( m_backgroundTime - 1 ) );
      ubyte blue = 128 + cast( ubyte )( 128 * sin( m_backgroundTime + 1 ) );
      renderer().clearColor = Color( red, green, blue );
   }

   void updateRotatingWorld( float deltaTime ) {
      Matrix4 rotation = zRotationMatrix( deltaTime * 0.3 );
      rotation *= yRotationMatrix( deltaTime * 0.7 );
      rotation *= xRotationMatrix( deltaTime * 1.2 );

      m_scene.rootNode.transformation = rotation * m_scene.rootNode.transformation;
   }

   char[] m_sceneFileName;
   bool m_generateSmoothNormals;
   bool m_fakeColors;

   Scene m_scene;

   ShadingMode m_shadingMode;
   bool m_forceWireframe;

   IBasicRasterizerFactory m_rasterizerFactory;
   BasicMaterial m_wireframeMaterial;
   BasicMaterial m_flatMaterial;
   BasicMaterial m_gouraudMaterial;

   bool m_rotateWorld;
   bool m_animateBackground;
   float m_backgroundTime;
}

mixin EntryPoint!( Viewer );
