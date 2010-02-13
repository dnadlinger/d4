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
import d4.app.Application;
import d4.app.FreeCamera;
import d4.app.Key;
import d4.app.Option;
import d4.app.Rendering;
import d4.app.Sdl;
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
import d4.scene.WireframeMaterial;
import d4.shader.LitSingleColorShader;
import d4.shader.SingleColorShader;
import d4.util.EnumUtils;
import util.EntryPoint;

/**
 * The available shading modes.
 */
enum ShadingMode {
   FLAT, /// Use a default flat material for all meshes.
   GOURAUD, /// Use a default gouraud-shading material for all meshes.
   MATERIAL /// Use the materials stored in the meshes to be rendered.
}

/**
 * The available wireframe drawing modes.
 */
enum WireframeMode {
   OFF, /// Use the normal solid materials.
   ONLY, /// Only render the wireframes.
   OVERLAY /// Render the wireframes above the solid image.
}

/**
 * The main application class.
 *
 * Manages the scene, reacts to user input, etc.
 */
class Viewer : FreeCamera!( Rendering!( Sdl!( Application ) ) ) {
public:
   this( char[][] args ) {
      super( args );
   }
protected:
   override void init() {
      super.init();

      if ( m_sceneFileName is null ) {
         throw new Exception(
            "Please specify a model file to load at the command line." );
      }

      m_rasterizerFactory = new GenericBasicRasterizerFactory();

      Stdout.newline;
      m_scene = new AssimpScene( m_sceneFileName, m_rasterizerFactory,
         m_generateSmoothNormals, m_fakeColors );

      m_rotateWorld = false;
      m_animateBackground = false;
      m_backgroundTime = 0;
      renderer().clearColor = Color( 0, 0, 0 );

      // Use the mesh materials by default.
      m_shadingMode = ShadingMode.MATERIAL;
      m_wireframeMode = WireframeMode.OFF;

      m_wireframeMaterial = new WireframeMaterial();

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

      renderer().beginScene();

      if ( m_wireframeMode != WireframeMode.ONLY ) {
         ISceneVisitor renderVisitor;
         switch ( m_shadingMode ) {
            case ShadingMode.FLAT:
               renderVisitor = new FixedMaterialRenderVisitor(
                  renderer(), m_flatMaterial );
               break;
            case ShadingMode.GOURAUD:
               renderVisitor = new FixedMaterialRenderVisitor(
                  renderer(), m_gouraudMaterial );
               break;
            case ShadingMode.MATERIAL:
               renderVisitor = new RenderVisitor( renderer() );
               break;
            default:
               throw new Exception( "Invalid shading mode!" );
         }
         m_scene.rootNode.accept( renderVisitor );
      }

      if ( m_wireframeMode != WireframeMode.OFF ) {
         m_scene.rootNode.accept(
            new FixedMaterialRenderVisitor( renderer(), m_wireframeMaterial ) );
      }

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
            m_shadingMode = step( m_shadingMode, 1 );
            break;
         case Key.x:
            m_wireframeMode = step( m_wireframeMode, 1 );
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
      if ( values.length > 0 ) {
         m_sceneFileName = values[ $ - 1 ];
         super.handleUnnamedArguments( values[ 0..( $ - 1 ) ] );
      } else {
         super.handleUnnamedArguments( values );
      }
   }

   override char[] helpSummary() {
      return "Viewer – a simple model viewer.";
   }

   override char[] helpUsage() {
      return "[options] scene_file";
   }

   override Option[] helpOptions() {
      return super.helpOptions() ~ [
         new Option( "smooth-normals", "Smooth the normals generated for models without normals." ),
         new Option( "fake-colors", "Color each model vertex in a random color." )
      ];
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
   WireframeMode m_wireframeMode;

   IBasicRasterizerFactory m_rasterizerFactory;
   IMaterial m_wireframeMaterial;
   BasicMaterial m_flatMaterial;
   BasicMaterial m_gouraudMaterial;

   bool m_rotateWorld;
   bool m_animateBackground;
   float m_backgroundTime;
}

mixin EntryPoint!( Viewer );
