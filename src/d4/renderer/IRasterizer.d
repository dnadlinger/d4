module d4.renderer.IRasterizer;

import d4.math.Matrix4;
import d4.output.Surface;
import d4.renderer.ZBuffer;
import d4.scene.Image;
import d4.scene.Vertex;

/**
 * The backface culling mode.
 */
enum BackfaceCulling {
   NONE, /// Draw everything.
   CULL_CW, /// Discard clockwise-orientated triangles.
   CULL_CCW /// Discard counter-clockwise-orientated triangles.
}

/**
 * The basic interface every rasterizer must implement.
 */
interface IRasterizer {
   /**
    * Renders a set of indexed triangles using the stored transformations.
    *
    * The results are written to the Frame-/Z-Buffer specified by
    * <code>setRenderTarget</code>.
    *
    * Params:
    *     vertices = The vertices to render.
    *     indices = The indices referring to the passed vertex array.
    */
   void renderTriangleList( Vertex[] vertices, uint[] indices );

   /**
    * Sets the render target to use, which is a framebuffer and its z buffer
    * companion.
    *
    * Params:
    *     colorBuffer = The framebuffer to use.
    *     zBuffer = The z buffer to use.
    */
   void setRenderTarget( Surface colorBuffer, ZBuffer zBuffer );

   /**
    * The world matrix to use.
    */
   Matrix4 worldMatrix();
   void worldMatrix( Matrix4 worldMatrix ); /// ditto

   /**
    * The view matrix to use.
    */
   Matrix4 viewMatrix();
   void viewMatrix( Matrix4 viewMatrix ); /// ditto

   /**
    * The projection matrix to use.
    */
   Matrix4 projectionMatrix();
   void projectionMatrix( Matrix4 projectionMatrix ); /// ditto

   /**
    * The backface culling mode to use.
    */
   BackfaceCulling backfaceCulling();
   void backfaceCulling( BackfaceCulling cullingMode ); /// ditto

   /**
    * The textures to use.
    */
   Image[] textures();
   void textures( Image[] textures ); /// ditto
}
