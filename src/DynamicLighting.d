module DynamicLights;

import d4.format.AssimpScene;
import d4.math.Texture;
import d4.math.Vector3;
import d4.renderer.IMaterial;
import d4.renderer.IRasterizer;
import d4.renderer.Renderer;
import d4.renderer.SolidRasterizer;
import d4.scene.Scene;
import d4.scene.NormalVertex;
import d4.shader.VertexVariableUtils;
import util.EntryPoint;
import FreeCameraApplication;
import RoomScene;

template Shader( bool Specular ) {
   import tango.math.Math : pow;
   import d4.scene.NormalVertex;

   const AMBIENT_INTENSITY = 0.1f;
   const DIFFUSE_INTENSITY = 0.8f;
   const SPECULAR_INTENSITY = 0.2f;
   const SPECULAR_SHARPNESS = 20u;

   void vertexShader( in Vertex vertex, out Vector4 position, out VertexVariables variables ) {
      NormalVertex nv = cast( NormalVertex ) vertex;
      assert( nv !is null );

      position = worldViewProjMatrix * nv.position;
      variables.normal = worldNormalMatrix.rotateVector( nv.normal ).normalized();
      variables.localPosition = nv.position;
   }

   Color pixelShader( VertexVariables variables ) {
      Vector3 normal = variables.normal.normalized();
      Vector3 toLight = shaderConstants.localLightPosition
         - variables.localPosition.normalized();
      static if ( Specular ) {
         Vector3 toCamera = shaderConstants.localCameraPosition
            - variables.localPosition.normalized();
      }

      float brightness = AMBIENT_INTENSITY;

      float diffuseFactor = toLight.dot( normal );
      if ( diffuseFactor > 0 ) {
         brightness += diffuseFactor * DIFFUSE_INTENSITY;

         static if ( Specular ) {
            float reflectanceFactor = toCamera.dot( 2 * diffuseFactor * normal - toLight );
            if ( reflectanceFactor > 0 ) {
               brightness += pow( reflectanceFactor, SPECULAR_SHARPNESS ) * SPECULAR_INTENSITY;
            }
         }
      }

      if ( brightness > 1 ) {
         brightness = 1;
      }
      return Color( 255, 255, 255 ) * brightness;
   }

   struct ShaderConstants {
      Vector3 localLightPosition;
      Vector3 localCameraPosition;
   }

   struct VertexVariables {
      float[6] values;
      mixin( vector3Variable!( "normal", 0 ) );
      mixin( vector3Variable!( "localPosition", 3 ) );
   }
}

class Material : IMaterial {
   IRasterizer getRasterizer() {
      if ( m_rasterizer is null ) {
         m_rasterizer = new Rasterizer();
      }

      return m_rasterizer;
   }

   void prepareForRendering( Renderer renderer ) {
      m_rasterizer.shaderConstants.localLightPosition =
         renderer.worldMatrix.inversed().transformLinear( Vector3( 0, 4, 2 ) );
      m_rasterizer.shaderConstants.localCameraPosition =
         ( renderer.worldMatrix * renderer.viewMatrix ).inversed().
         transformLinear( Vector3( 0, 0, 0 ) );
   }

   bool usesTextures() {
      return false;
   }

private:
   alias SolidRasterizer!( true, Shader, false ) Rasterizer;
   Rasterizer m_rasterizer;
}


class DynamicLighting : FreeCameraApplication {
   this( char[][] args ) {
      super( args );
   }

protected:
   override void init() {
      super.init();

      if ( m_scene is null ) {
         m_scene = new RoomScene( 5 );
      }

      // TODO: Add global material override function to material manager instead?
      auto material = new Material();
      auto allMeshes = m_scene.rootNode.flatten();
      foreach ( mesh; allMeshes ) {
         mesh.material = material;
      }

      cameraPosition = Vector3( 0, 3, 5 );
   }

   override void render( float deltaTime ) {
      super.render( deltaTime );

      renderer().beginScene();
      m_scene.rootNode.render( renderer() );
      renderer().endScene();
   }

   override void shutdown() {
      super.shutdown();
   }

   override void handleUnnamedArguments( char[][] values ) {
      if ( values.length > 0 ) {
         m_scene = new AssimpScene( values[ $ - 1 ] );
         super.handleUnnamedArguments( values[ 0..($-1) ] );
      }
   }

private:
   char[] m_sceneFileName;
   Scene m_scene;
}

mixin EntryPoint!( DynamicLighting );
