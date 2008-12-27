module d4.renderer.GeometryProcessor;

import d4.math.Matrix4;
import d4.math.Vector4;
import d4.renderer.TransformedTriangle;
import d4.renderer.VertexShader;
import d4.renderer.VertexVariables;
import d4.scene.Vertex;

enum BackfaceCulling {
   NONE,
   CW,
   CCW
}

class GeometryProcessor {
   this() {
      m_worldMatrix = Matrix4.identity;
      m_viewMatrix = Matrix4.identity;
      m_projMatrix = Matrix4.identity;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
      
      m_backfaceCulling = BackfaceCulling.CW;
      
      m_shader = null;
   }
   
   /**
    * Transforms an indexed triangle list into a list of ready-to-render
    * triangles.
    * 
    * The process can be customized using a VertexShader, which is called to
    * transform each vertex.
    * 
    * Params:
    *     vertices = The vertices to transform.
    *     indices = The indices referring to the passed vertex array.
    */
   TransformedTriangle[] transformTriangles( Vertex[] vertices, uint[] indices ) {
      TransformedTriangle[] result;
      
      assert( ( indices.length % 3 == 0 ), "There must be no incomplete triangles." );
      assert( m_shader !is null, "No vertex shader set." );

      // Clipping

      Vector4[] positions;
      VertexVariables[] variables;
      
      foreach ( vertex; vertices ) {
         Vector4 currentPosition;
         VertexVariables currentVariables;
         
         m_shader.process( vertex, currentPosition, currentVariables );
         
         currentPosition.homogenize();
         
         positions ~= currentPosition;
         variables ~= currentVariables;
      }

      // Clipping?

      for ( uint i = 0; i < indices.length; i += 3 ) {
         uint i0 = indices[ i ];
         uint i1 = indices[ i + 1 ];
         uint i2 = indices[ i + 2 ];
         
         Vector4 p0 = positions[ i0 ];
         Vector4 p1 = positions[ i1 ];
         Vector4 p2 = positions[ i2 ];

         // As we already have screen coordinates, looking at the z component
         // of the cross product is enough.
         if ( m_backfaceCulling == BackfaceCulling.CCW ) {
            if ( ( p1.x - p0.x ) * ( p2.y - p0.y ) - ( p1.y - p0.y ) * ( p2.x - p0.x ) > 0 ) {
               continue;
            }
         } else if ( m_backfaceCulling == BackfaceCulling.CW ) {
            if ( ( p0.x - p1.x ) * ( p0.y - p2.y ) - ( p0.y - p1.y ) * ( p0.x - p2.x ) > 0 ) {
               continue;
            }
         }
         
         TransformedTriangle triangle;
         triangle.pos0 = p0;
         triangle.data0 = variables[ i0 ];
         triangle.pos1 = p1;
         triangle.data1 = variables[ i1 ];
         triangle.pos2 = p2;
         triangle.data2 = variables[ i2 ];
         result ~= triangle;
      }
   
      return result;
   }
   
   VertexShader vertexShader() {
      return m_shader;
   }
   
   void vertexShader( VertexShader shader ) {
      m_shader = shader;
      shader.setCombinedTransformation( m_worldViewProjMatrix );
      // TODO: Clear cache if we had one.
   }
   
   Matrix4 worldMatrix() {
      return m_worldMatrix;
   }

   void worldMatrix( Matrix4 worldMatrix ) {
      m_worldMatrix = worldMatrix;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
   }

   Matrix4 viewMatrix() {
      return m_viewMatrix;
   }

   void viewMatrix( Matrix4 viewMatrix ) {
      m_viewMatrix = viewMatrix;
      updateWorldViewMatrix();
      updateWorldViewProjMatrix();
   }
   
   Matrix4 projectionMatrix() {
      return m_projMatrix;
   }

   void projectionMatrix( Matrix4 projectionMatrix ) {
      m_projMatrix = projectionMatrix;
      updateWorldViewProjMatrix();
   }

   BackfaceCulling backfaceCulling() {
      return m_backfaceCulling;
   }
   
   void backfaceCulling( BackfaceCulling cullingMode ) {
      m_backfaceCulling = cullingMode;
   }

private:
   void updateWorldViewMatrix() {
      m_worldViewMatrix = m_viewMatrix * m_worldMatrix;
   }

   void updateWorldViewProjMatrix() {
      m_worldViewProjMatrix = m_projMatrix * m_worldViewMatrix;
      if ( m_shader !is null ) {
         m_shader.setCombinedTransformation( m_worldViewProjMatrix );
      }
   }   
   
   VertexShader m_shader;
   
   Matrix4 m_worldMatrix;
   Matrix4 m_viewMatrix;
   Matrix4 m_projMatrix;
   Matrix4 m_worldViewMatrix;
   Matrix4 m_worldViewProjMatrix;
   
   BackfaceCulling m_backfaceCulling;
}