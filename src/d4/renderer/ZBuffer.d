module d4.renderer.ZBuffer;

class ZBuffer {
   this( uint width, uint height ) {
      m_width = width;
      m_height = height;
   }

   uint width() {
      return m_width;
   }

   uint height() {
      return m_height;
   }

private:
   uint m_width;
   uint m_height;
}