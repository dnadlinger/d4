module d4.format.DevilImporter;

import tango.io.Stdout;
import tango.stdc.stringz : toStringz;
import derelict.devil.il;
import d4.math.Color;
import d4.scene.Image;

class DevilImporter {
public:   
   Image importFile( char[] fileName ) {
      ILuint imageId = createDevilImage();
      
      if ( !ilLoadImage( toStringz( fileName ) ) ) {
         throw new Exception( "Couldn't load image file: " ~ fileName );
      }
      
      return importImage( imageId );
   }
   
   Image importData( void[] rawData ) {
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
   
   Image importImage( ILuint imageId ) {
      uint width = ilGetInteger( IL_IMAGE_WIDTH );
      uint height = ilGetInteger( IL_IMAGE_HEIGHT );
      
      Color data[] = new Color[ width * height ];
      
      ilCopyPixels( 0, 0, 0, width, height, 1, IL_BGRA, IL_UNSIGNED_BYTE, &data[ 0 ] );
      
      Image resultImage = new Image( width, height, data );
      
      ilBindImage( 0 );
      ilDeleteImages( 1, &imageId );
      
      return resultImage;
   }
   
   static this() {
      DerelictIL.load();
      ilInit();
      
      // TODO: OpenGL vs. DirectX?
      ilEnable( IL_ORIGIN_SET );
      ilOriginFunc( IL_ORIGIN_UPPER_LEFT );
   }
   
   static ~this() {
      DerelictIL.unload();
   }   
}
