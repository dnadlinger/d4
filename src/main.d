module main;

import tango.math.Math : sin;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Vector3;
import d4.renderer.Renderer;
import d4.renderer.SimpleWireframeRasterizer;
import d4.renderer.Vertex;
import d4.util.SdlApplication;

class MainApplication : SdlApplication {
protected:
   override void init() {
      m_renderer = new Renderer( screen() );
      m_renderer.triangleRasterizer = new SimpleWireframeRasterizer();
      m_renderer.clearColor = Color( 0, 0, 0 );
      m_renderer.viewMatrix = Matrix4.lookAt( Vector3( 0, 0, -5 ), Vector3( 0, 0, 0 ), Vector3( 0, 1, 0 ) );
      m_renderer.backfaceCulling = true;
   }

   override void render( float deltaTime ) {
      updateRainbowBackground();
      updateRotatingWorld();

      m_renderer.beginScene();
      m_renderer.renderTriangleList( cubeVertices, cubeIndices );
      m_renderer.endScene();
   }

   override void shutdown() {
   }

private:
   void updateRainbowBackground() {
      float time = totalTimePassed();
      ubyte red = 128 + cast( ubyte )( 128 * sin( time ) );
      ubyte green = 128 + cast( ubyte )( 128 * sin( time - 1 ) );
      ubyte blue = 128 + cast( ubyte )( 128 * sin( time + 1 ) );
      m_renderer.clearColor = Color( red, green, blue );
   }

   void updateRotatingWorld() {
      float time = totalTimePassed();
      Matrix4 rotation = Matrix4.rotationZ( time * 0.5 );
      rotation *= Matrix4.rotationX( time );
      rotation *= Matrix4.rotationY( time * 2 );
      m_renderer.worldMatrix = rotation;
   }

   Vertex[ 8 ] cubeVertices = [
      Vertex( Vector3( -1, 1, -1 ) ),
      Vertex( Vector3( -1, -1, -1 ) ),
      Vertex( Vector3( 1, 1, -1 ) ),
      Vertex( Vector3( 1, -1, -1 ) ),
      Vertex( Vector3( 1, 1, 1 ) ),
      Vertex( Vector3( 1, -1, 1 ) ),
      Vertex( Vector3( -1, 1, 1 ) ),
      Vertex( Vector3( -1, -1, 1 ) )
   ];

   uint[ 36 ] cubeIndices = [
      0, 1, 2,
      2, 1, 3,

      2, 3, 4,
      4, 3, 5,

      4, 5, 6,
      6, 5, 7,

      6, 7, 0,
      0, 7, 1,

      6, 0, 4,
      4, 0, 2,

      1, 7, 3,
      3, 7, 5
   ];

   Renderer m_renderer;
}

void main() {
   scope auto app = new MainApplication();
   app.run();
}