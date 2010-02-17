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
 * Simple example demonstrating more complex per-pixel lighting by displaying
 * a scene illuminated by two colored point lights moving around.
 *
 * If a model file is passed at the command line, it is loaded. A simple »room«
 * is displayed otherwise.
 */
module SpinningLights;

import d4.app.Application;
import d4.app.FreeCamera;
import d4.app.Key;
import d4.app.Option;
import d4.app.Rendering;
import d4.app.Sdl;
import d4.format.AssimpScene;
import d4.math.AABB;
import d4.math.Color;
import d4.math.Texture;
import d4.math.Transformations;
import d4.math.Vector3;
import d4.renderer.IMaterial;
import d4.renderer.IRasterizer;
import d4.renderer.Renderer;
import d4.renderer.SolidRasterizer;
import d4.scene.CollectPointsVisitor;
import d4.scene.Mesh;
import d4.scene.Node;
import d4.scene.Primitives;
import d4.scene.FixedMaterialRenderVisitor;
import d4.scene.Vertex;
import d4.scene.WireframeMaterial;
import d4.shader.SingleColorShader;
import d4.util.ArrayUtils;
import d4.util.EnumUtils;
import util.EntryPoint;

/**
 * A shader which renders the objects all white illuminated with two colored
 * omni lights (with decay) and ambient light.
 *
 * Instead of (integer) <code>Color</code>s, <code>Vector3</code>s are used
 * internally because it turned out that this is quite a bit faster than
 * working with colors packed into a 32 bit integer and performing clipping for
 * all three channels on every operation.
 *
 * There might be a more elaborate solution, but for now, it works quite well.
 *
 * Vertex type: NormalVertex.
 */
template Shader() {
   import tango.math.Math : sqrt;
   import d4.scene.NormalVertex;

   const AMBIENT_INTENSITY = 0f;
   const DECAY_0 = 0.05f;
   const DECAY_1 = 0.05f;

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      NormalVertex nv = cast( NormalVertex ) vertex;
      assert( nv !is null );

      position = worldViewProjMatrix * nv.position;
      variables.normal = worldNormalMatrix.rotateVector( nv.normal ).normalized();
      variables.localPosition = nv.position;
   }

   Color pixelShader( VertexVariables variables ) {
      Vector3 normal = variables.normal.normalized();

      Vector3 toLight0 = shaderConstants.light0LocalPosition - variables.localPosition;
      float decayFactor0 = 1f / ( 1f + toLight0.sqrLength() * DECAY_0 );
      toLight0.normalize();

      Vector3 toLight1 = shaderConstants.light1LocalPosition - variables.localPosition;
      float decayFactor1 = 1f / ( 1f + toLight1.sqrLength() * DECAY_1 );
      toLight1.normalize();

      Vector3 color = Vector3( 255, 255, 255 ) * AMBIENT_INTENSITY;

      float diffuseFactor0 = toLight0.dot( normal );
      if ( diffuseFactor0 > 0 ) {
         color += shaderConstants.light0Color * diffuseFactor0 * decayFactor0;
      }

      float diffuseFactor1 = toLight1.dot( normal );
      if ( diffuseFactor1 > 0 ) {
         color += shaderConstants.light1Color * diffuseFactor1 * decayFactor1;
      }

      return vector3ToColor!( true )( color );
   }

   struct ShaderConstants {
      Vector3 light0LocalPosition;
      Vector3 light0Color;

      Vector3 light1LocalPosition;
      Vector3 light1Color;
   }

   struct VertexVariables {
      Vector3 normal;
      Vector3 localPosition;
   }
}


/**
 * An IMaterial which uses the above Shader to render the scene with a blue and
 * an orange light spinning around the y-axis.
 */
class Material : IMaterial {
public:
   this() {
      m_light0Position = Vector3( -3f, 2.5f, 3f );
      m_light1Position = Vector3( 4f, 4f, 2f );
   }

   void updatePositions( float deltaTime ) {
      m_light0Position = rotationMatrix( rotationQuaternion(
         -deltaTime/2, Vector3( 0, 1, 0 ) ) ).transformLinear( m_light0Position );
      m_light1Position = rotationMatrix( rotationQuaternion(
         deltaTime, Vector3( 0, 1, 0 ) ) ).transformLinear( m_light1Position );
   }

   IRasterizer createRasterizer() {
      if ( m_rasterizer is null ) {
         m_rasterizer = new Rasterizer();
         m_rasterizer.shaderConstants.light0Color = colorToVector3( Color( 0, 128, 255 ) );
         m_rasterizer.shaderConstants.light1Color = colorToVector3( Color( 255, 128, 0 ) );
      }

      return m_rasterizer;
   }

   void prepareForRendering( Renderer renderer ) {
      m_rasterizer.shaderConstants.light0LocalPosition =
         renderer.worldMatrix.inversed().transformLinear( m_light0Position );
      m_rasterizer.shaderConstants.light1LocalPosition =
         renderer.worldMatrix.inversed().transformLinear( m_light1Position );
   }

private:
   Vector3 m_light0Position;
   Vector3 m_light1Position;

   alias SolidRasterizer!( true, Shader ) Rasterizer;
   Rasterizer m_rasterizer;
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
class SpinningLights : FreeCamera!( Rendering!( Sdl!( Application ) ) ) {
public:
   this( char[][] args ) {
      super( args );
   }

protected:
   override void init() {
      super.init();

      if ( m_rootNode is null ) {
         // Generate 16-by-16 »room« if no scene was loaded.
         m_rootNode = new Node();
         m_rootNode.addMesh(
            makeCube( Vector3( -8, 0, -8 ), Vector3( 8, 8, 8 ), true ) );
      } else if ( m_displayRoom ) {
         // Compute the bounding box of the scene geometry.
         auto collector = new CollectPointsVisitor();
         m_rootNode.accept( collector );

         AABB boundingBox = AABB( collector.result );

         // Enlarge the box to the sides and top, mimicking a room the model is
         // standing in.
         float size = ( boundingBox.max - boundingBox.min ).length;
         boundingBox.enlarge( Vector3( size / 2, size / 3, size / 2 ) );
         boundingBox.min.y += size / 3;

         auto newRoot = new Node();
         newRoot.addMesh( makeCube( boundingBox, true ) );
         newRoot.addChild( m_rootNode );
         m_rootNode = newRoot;
      }

      cameraPosition = Vector3( 0, 3, 5 );
      m_material = new Material();

      m_wireframeMode = WireframeMode.OFF;
      m_wireframeMaterial = new WireframeMaterial();
   }

   override void render( float deltaTime ) {
      super.render( deltaTime );

      m_material.updatePositions( deltaTime );

      renderer().beginScene();

      if ( m_wireframeMode != WireframeMode.ONLY ) {
         m_rootNode.accept(
            new FixedMaterialRenderVisitor( renderer(), m_material ) );
      }

      if ( m_wireframeMode != WireframeMode.OFF ) {
         m_rootNode.accept(
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
         case Key.x:
            m_wireframeMode = step( m_wireframeMode, 1 );
            break;
         default:
            // Do nothing.
            break;
      }
   }

   override void handleSwitchArgument( char[] name ) {
      switch ( name ) {
         case "display-room":
            m_displayRoom = true;
            break;
         default:
            super.handleSwitchArgument( name );
            break;
      }
   }

   override void handleUnnamedArguments( char[][] values ) {
      if ( values.length > 0 ) {
         // Call the superclass function first to get a nice error message for
         // too many arguments (we would probably try to load an invalid scene
         // file then).
         super.handleUnnamedArguments( values[ 0..( $ - 1 ) ] );
         m_rootNode = ( new AssimpScene( values[ $ - 1 ] ) ).rootNode;
      }
   }

   override char[] helpSummary() {
      return "SpinningLights – demonstrating more complex per-pixel lighting.";
   }

   override char[] helpUsage() {
      return "[options] [scene_file]";
   }

   override Option[] helpOptions() {
      return super.helpOptions() ~ [
         new Option( "display-room", "Display a box around the loaded model." )
      ];
   }

private:
   char[] m_sceneFileName;
   bool m_displayRoom;
   Node m_rootNode;
   Material m_material;

   WireframeMode m_wireframeMode;
   IMaterial m_wireframeMaterial;
}

mixin EntryPoint!( SpinningLights );
