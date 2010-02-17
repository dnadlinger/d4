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

module d4.format.DevilImporter;

import tango.io.Stdout;
import tango.stdc.stringz : toStringz;
import derelict.devil.il;
import d4.math.Color;
import d4.math.Texture;

/**
 * Importer for loading images via the DevIL image library.
 */
class DevilImporter {
public:
   /**
    * Constructs a new loader instance and initializes the DevIL library
    * if neccessary.
    */
   this() {
      if ( ilInit is null ) {
         // Derelict will unload the library automatically on program termination.
         DerelictIL.load();
         ilInit();

         // Set the origin of the image to the lower left corner because we are
         // using OpenGL-style texture coordinates.
         ilEnable( IL_ORIGIN_SET );
         ilOriginFunc( IL_ORIGIN_LOWER_LEFT );
      }
   }

   /**
    * Loads an image from a file.
    *
    * Params:
    *     fileName = The name of the image file.
    * Returns: The loaded image.
    */
   Texture importFile( char[] fileName ) {
      ILuint imageId = createDevilImage();

      if ( !ilLoadImage( toStringz( fileName ) ) ) {
         throw new Exception( "Couldn't load image file: " ~ fileName );
      }

      return importImage( imageId );
   }

   /**
    * Imports (decodes) an image already stored rawly in memory.
    *
    * Params:
    *     rawData = The raw image data.
    * Returns: The imported image.
    */
   Texture importData( void[] rawData ) {
      ILuint imageId = createDevilImage();

      if ( !ilLoadL( IL_TYPE_UNKNOWN, &rawData[0], rawData.length ) ) {
         throw new Exception( "Couldn't load image from raw data." );
      }

      return importImage( imageId );
   }

private:
   ILuint createDevilImage() {
      ILuint imageId;
      ilGenImages( 1, &imageId );
      ilBindImage( imageId );
      return imageId;
   }

   Texture importImage( ILuint imageId ) {
      uint width = ilGetInteger( IL_IMAGE_WIDTH );
      uint height = ilGetInteger( IL_IMAGE_HEIGHT );

      Color data[] = new Color[ width * height ];

      ilCopyPixels( 0, 0, 0, width, height, 1, IL_BGRA, IL_UNSIGNED_BYTE, &data[ 0 ] );

      Texture resultImage = new Texture( width, height, data );

      ilBindImage( 0 );
      ilDeleteImages( 1, &imageId );

      return resultImage;
   }
}
