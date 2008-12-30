module d4.renderer.IRasterizer;

import d4.math.Matrix4;
import d4.output.Surface;
import d4.renderer.ZBuffer;
import d4.scene.Vertex;

enum BackfaceCulling {
   NONE,
   CULL_CW,
   CULL_CCW
}

interface IRasterizer {
   void renderTriangleList( Vertex[] vertices, uint[] indices );
   
   void setRenderTarget( Surface colorBuffer, ZBuffer zBuffer );
   
   Matrix4 worldMatrix();
   void worldMatrix( Matrix4 worldMatrix );

   Matrix4 viewMatrix();
   void viewMatrix( Matrix4 viewMatrix );
   
   Matrix4 projectionMatrix();
   void projectionMatrix( Matrix4 projectionMatrix );

   BackfaceCulling backfaceCulling();
   void backfaceCulling( BackfaceCulling cullingMode );   
}