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

module d4.format.AssimpScene;

import tango.io.Path : standardizePath = standard;
import tango.io.FilePath;
import tango.io.Stdout;
import tango.stdc.stringz : fromStringz, toStringz;
import tango.text.convert.Integer;
import tango.util.Convert;
import assimp.assimp;
import d4.format.DevilImporter;
import d4.math.Color;
import d4.math.Matrix4;
import d4.math.Texture;
import d4.math.Vector2;
import d4.math.Vector3;
import d4.scene.BasicMaterial;
import d4.scene.ColoredNormalVertex;
import d4.scene.IBasicRasterizerFactory;
import d4.scene.Mesh;
import d4.scene.Node;
import d4.scene.NullBasicRasterizerFactory;
import d4.scene.TexturedNormalVertex;
import d4.scene.Vertex;

/**
 * Loads a scene from a model file using the Assimp library.
 */
class AssimpScene {
   /**
    * Constructs a new scene object with the contents from a scene file.
    *
    * Params:
    *    fileName = The file to load (see Assimp docs for accepted file
    *       formats).
    *    rasterizerFactory = The rasterizer factory to pass to the
    *       <code>BasicMaterial</code>s created for the scene materials.
    *    normalType = If no normals are found in the model file, Assimp
    *       generates a set of normals. This parameter specifies whether
    *       they will be smoothed.
    *    fakeColors = If fake vertex colors should be generated.
    */
   this( char[] fileName,
      IBasicRasterizerFactory rasterizerFactory = new NullBasicRasterizerFactory(),
      bool smoothNormals = false, bool fakeColors = false ) {

      m_rasterizerFactory = rasterizerFactory;

      // Make sure that the Assimp library is loaded.
      Assimp.load();

      Stdout( "Loading scene file: ")( fileName )( "... " );

      // Use the Assimp library to load the scene file into memory.
      uint importFlags =
         aiProcess.JoinIdenticalVertices
         | aiProcess.Triangulate
         | aiProcess.RemoveRedundantMaterials
         | aiProcess.FindInvalidData
         | aiProcess.ValidateDataStructure
      ;

      if ( smoothNormals ) {
         importFlags |= aiProcess.GenSmoothNormals;
      } else {
         importFlags |= aiProcess.GenNormals;
      }

      auto sceneFile = FilePath( standardizePath( fileName ) );
      aiScene* scene = aiImportFile(
         toStringz( sceneFile.toString() ), importFlags );

      if ( scene is null ) {
         throw new Exception( "Failed to load scene from file: " ~
            fromStringz( aiGetErrorString() ) );
      }

      if ( scene.mRootNode is null ) {
         throw new Exception( "Model file contains no root node." );
      }

      // Import materials into our own data structures.
      char[] scenePath = sceneFile.path();

      for ( uint i = 0; i < scene.mNumMaterials; ++i ) {
         m_materials ~= importMaterial(
            scene.mMaterials[ i ], scene, scenePath );
      }

      // Import meshes into our own data structures.
      for ( uint i = 0; i < scene.mNumMeshes; ++i ) {
         m_meshes ~= importMesh( scene.mMeshes[ i ], fakeColors );
      }

      // Import the scenegraph into our own data structures.
      m_rootNode = importNode( scene.mRootNode );

      // Print some statistics.
      uint triangleCount = 0;
      foreach ( mesh; m_meshes ) {
         triangleCount += mesh.indices.length / 3;
      }

      Stdout( "done." ).newline;
      Stdout.format(
         "Imported {} triangles in {} meshes, with a total of {} materials.",
         triangleCount, m_meshes.length, m_materials.length
      ).newline;
      Stdout.format(
         "{} of the meshes had textures applied, " ~
            "{} of the meshes were imported with the vertex colors, " ~
            "{} with the default colors and {} using fake colors.",
         m_texturedMeshCount,
         m_coloredMeshCount,
         m_defaultColorMeshCount,
         m_fakeColorMeshCount
      ).newline;

      // Everything is parsed into our internal structures, we don't need the
      // Assimp scene object and the functions from the library anymore.
      aiReleaseImport( scene );
      Assimp.unload();
   }

   /**
    * Returns: The root node of the scene.
    */
   Node rootNode() {
      return m_rootNode;
   }

private:
   BasicMaterial importMaterial( aiMaterial* material, aiScene* scene,
      char[] modelPath ) {

      BasicMaterial result = new BasicMaterial( m_rasterizerFactory );

      // Read wireframe mode.
      int useWireframe = 0;
      aiGetMaterialInteger(
         material, AI_MATKEY_ENABLE_WIREFRAME, 0, 0, &useWireframe );
      result.wireframe = ( useWireframe == 1 );

      // Read the first diffuse texture (if any).
      aiString targetString;
      if ( aiGetMaterialTexture( material, aiTextureType.DIFFUSE, 0,
         &targetString ) == aiReturn.SUCCESS ) {

         char[] textureFileName = importString( &targetString );

         DevilImporter imageLoader = new DevilImporter();
         Texture image;

         if ( textureFileName[ 0 ] == '*' ) {
            // The texture is embedded into the file.
            aiTexture* texture =
               scene.mTextures[ toInt( textureFileName[ 1 .. $ ] ) ];

            uint width = texture.mWidth;
            uint height = texture.mHeight;

            if ( height > 0 ) {
               // If it is uncompressed, just copy the data over to a Texture.
               image = new Texture( width, height,
                  ( cast( Color* )texture.pcData )[ 0 .. ( width * height ) ] );
            } else {
               // The image is compressed.
               image = imageLoader.importData(
                  ( cast( void* )texture.pcData )[ 0 .. width ] );
            }
         } else {
            // The texture resides in a seperate file on the hard disk.
            // Try a few different locations to be error-tolerant in the
            // texture path specifications.
            auto textureFilePath = new FilePath( textureFileName );
            try {
               // The texture path is probably stored relative to the model
               // file.
               image = imageLoader.importFile( modelPath ~ textureFileName );
            } catch {
               try {
                  // Maybe the exporter has erroneously stored an absolute
                  // path, try using just the file name.
                  image = imageLoader.importFile( modelPath ~
                     textureFilePath.name ~ textureFilePath.suffix );
               } catch {
                  try {
                     // Maybe the absolute path is correct? This should not
                     // happen though.
                     image = imageLoader.importFile( textureFileName );
                     Stdout( "A texture file was specified with an " ~
                        "absoule path: " )( textureFileName );
                  } catch {
                     throw new Exception(
                        "Couldn't find texture file: " ~ textureFileName );
                  }
               }
            }
         }

         result.diffuseTexture = image;
         result.vertexColors = false;
      } else {
         result.vertexColors = true;
      }

      result.lighting = true;

      return result;
   }

   Mesh importMesh( aiMesh* mesh, bool fakeColors ) {
      Mesh result = new Mesh();

      // If assimp's preprocessing worked correctly, the mesh should not be
      // empty and it should only contain triangles by now.
      assert( mesh.mNumFaces > 0 );
      assert( mesh.mPrimitiveTypes == aiPrimitiveType.TRIANGLE );

      // The vertices have to contain normals.
      assert( mesh.mNormals !is null );

      // The meshes store only incides for the global material buffer.
      assert( m_materials[ mesh.mMaterialIndex ] !is null );
      result.material = m_materials[ mesh.mMaterialIndex ];

      // Guess the right vertex type and import the vertices.
      if ( fakeColors ) {
         ++m_fakeColorMeshCount;
         result.vertices = importFakeColorVertices( mesh );

         // TODO: Check if we could unintentionally overwrite something here.
         m_materials[ mesh.mMaterialIndex ].vertexColors = true;
         m_materials[ mesh.mMaterialIndex ].diffuseTexture = null;
      } else if ( ( mesh.mTextureCoords[ 0 ] !is null ) &&
         ( m_materials[ mesh.mMaterialIndex ].diffuseTexture !is null ) ) {
         // Check if there really is a texture, because some models contain
         // unused texture coordinates.
         ++m_texturedMeshCount;
         result.vertices = importTexturedVertices( mesh );
      } else if ( mesh.mColors[ 0 ] !is null ) {
         ++m_coloredMeshCount;
         result.vertices = importColoredVertices( mesh );
      } else {
         ++m_defaultColorMeshCount;
         // TODO: Use material color.
         result.vertices = importVerticesWithFixedColor(
            mesh, Color( 255, 255, 255 ) );
      }

      // Import all the indices/faces.
      for ( uint i = 0; i < mesh.mNumFaces; ++i ) {
         aiFace face = mesh.mFaces[ i ];

         // Since we are dealing with triangles, every face must have thre
         // vertices.
         assert( face.mNumIndices == 3 );

         result.indices ~= face.mIndices[ 0 ];
         result.indices ~= face.mIndices[ 1 ];
         result.indices ~= face.mIndices[ 2 ];
      }

      return result;
   }

   ColoredNormalVertex[] importFakeColorVertices( aiMesh* mesh ) {
      ColoredNormalVertex[] result;

      // The fake color mechanism assigns a color from the list to each vertex.
      // If two vertices within colorLookbackLimit have the same position,
      // they get the same color.
      Color[] colors = [
         Color( 255, 0, 0 ),
         Color( 0, 255, 0 ),
         Color( 0, 0, 255 ),
         Color( 255, 255, 0 ),
         Color( 255, 0, 255 ),
         Color( 0, 255, 255 ),
         Color( 255, 255, 255 )
      ];
      ColoredNormalVertex[ 6 ] fakeColorBuffer;

      for ( uint i = 0; i < mesh.mNumVertices; ++i ) {
         ColoredNormalVertex vertex = new ColoredNormalVertex();

         vertex.position = importVector3( mesh.mVertices[ i ] );

         // vertex.normal.normalize() does not work because of the indirection
         // via the getter/setter function.
         vertex.normal = importVector3( mesh.mNormals[ i ] ).normalized();

         vertex.color = colors[ i % $ ];
         foreach ( oldVertex; fakeColorBuffer ) {
            if ( oldVertex is null ) {
               break;
            }
            if ( vertex.position == oldVertex.position ) {
               vertex.color = oldVertex.color;
               break;
            }
         }
         fakeColorBuffer[ i % $ ] = vertex;

         result ~= vertex;
      }

      return result;
   }

   ColoredNormalVertex[] importColoredVertices( aiMesh* mesh ) {
      ColoredNormalVertex[] result;

      for ( uint i = 0; i < mesh.mNumVertices; ++i ) {
         ColoredNormalVertex vertex = new ColoredNormalVertex();

         vertex.position = importVector3( mesh.mVertices[ i ] );

         // vertex.normal.normalize() does not work because of the indirection
         // via the getter/setter function.
         vertex.normal = importVector3( mesh.mNormals[ i ] ).normalized();

         vertex.color = importColor( mesh.mColors[ 0 ][ i ] );

         result ~= vertex;
      }

      return result;
   }

   ColoredNormalVertex[] importVerticesWithFixedColor( aiMesh* mesh, Color color ) {
      ColoredNormalVertex[] result;

      for ( uint i = 0; i < mesh.mNumVertices; ++i ) {
         ColoredNormalVertex vertex = new ColoredNormalVertex();

         vertex.position = importVector3( mesh.mVertices[ i ] );

         // vertex.normal.normalize() does not work because of the indirection
         // via the getter/setter function.
         vertex.normal = importVector3( mesh.mNormals[ i ] ).normalized();

         vertex.color = color;

         result ~= vertex;
      }

      return result;
   }

   TexturedNormalVertex[] importTexturedVertices( aiMesh* mesh ) {
      TexturedNormalVertex[] result;

      for ( uint i = 0; i < mesh.mNumVertices; ++i ) {
         TexturedNormalVertex vertex = new TexturedNormalVertex();

         vertex.position = importVector3( mesh.mVertices[ i ] );

         // vertex.normal.normalize() does not work because of the indirection
         // via the getter/setter function.
         vertex.normal = importVector3( mesh.mNormals[ i ] ).normalized();

         vertex.texCoords = importTexCoords( mesh.mTextureCoords[ 0 ][ i ] );

         result ~= vertex;
      }

      return result;
   }

   Node importNode( aiNode* node ) {
      // TODO: Omit empty nodes as described in the assimp docs?
      Node result = new Node();

      result.transformation = importMatrix( node.mTransformation );

      for ( uint i = 0; i < node.mNumMeshes; ++i ) {
         // The nodes store only indices for the global mesh buffer.
         assert( m_meshes[ node.mMeshes[ i ] ] !is null );
         result.addMesh( m_meshes[ node.mMeshes[ i ] ] );
      }

      for ( uint i = 0; i < node.mNumChildren; ++i ) {
         result.addChild( importNode( node.mChildren[ i ] ) );
      }

      return result;
   }

   Matrix4 importMatrix( aiMatrix4x4 m ) {
      Matrix4 r;

      r.m11 = m.a1;
      r.m12 = m.a2;
      r.m13 = m.a3;
      r.m14 = m.a4;

      r.m21 = m.b1;
      r.m22 = m.b2;
      r.m23 = m.b3;
      r.m24 = m.b4;

      r.m31 = m.c1;
      r.m32 = m.c2;
      r.m33 = m.c3;
      r.m34 = m.c4;

      r.m41 = m.d1;
      r.m42 = m.d2;
      r.m43 = m.d3;
      r.m44 = m.d4;

      return r;
   }

   Vector3 importVector3( aiVector3D v ) {
      return Vector3( v.x, v.y, v.z );
   }

   Color importColor( aiColor4D c ) {
      return Color(
         cast( ubyte )( c.r * 255f ),
         cast( ubyte )( c.g * 255f ),
         cast( ubyte )( c.b * 255f ),
         cast( ubyte )( c.a * 255f )
      );
   }

   Vector2 importTexCoords( aiVector3D c ) {
      return Vector2( c.x, c.y );
   }

   char[] importString( aiString* s ) {
      return s.data[ 0 .. s.length ];
   }

   IBasicRasterizerFactory m_rasterizerFactory;

   Mesh[] m_meshes;
   BasicMaterial[] m_materials;
   Node m_rootNode;

   uint m_texturedMeshCount;
   uint m_coloredMeshCount;
   uint m_fakeColorMeshCount;
   uint m_defaultColorMeshCount;
}
