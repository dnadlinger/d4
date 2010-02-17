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
 * A shader which paints all object white, but takes gouraud lighting (via the
 * vertex normal vectors) into account.
 *
 * Vertex type: NormalVertex.
 */
module d4.shader.LitSingleColorShader;

/*
 * See SingleColorShader.
 */
template LitSingleColorShader( float ambientLevel,
   float lightDirX, float lightDirY, float lightDirZ ) {
   import d4.scene.NormalVertex;

   const LIGHT_DIRECTION =
      CTFE_normalize( Vector3( lightDirX, lightDirY, lightDirZ ) );

   void vertexShader( in Vertex vertex,
      out Vector4 position, out VertexVariables variables ) {

      NormalVertex nv = cast( NormalVertex ) vertex;
      assert( nv !is null );

      Vector3 worldNormal = worldNormalMatrix.rotateVector( nv.normal );

      float lightIntensity = -LIGHT_DIRECTION.dot( worldNormal.normalized() );

      // ambientLevel represents the ambient light.
      if ( lightIntensity < ambientLevel ) {
         lightIntensity = ambientLevel;
      }

      position = worldViewProjMatrix * nv.position;
      variables.brightness = lightIntensity;
   }

   Color pixelShader( VertexVariables variables ) {
      return Color( 255, 255, 255 ) * variables.brightness;
   }

   struct VertexVariables {
      float brightness;
   }
}
