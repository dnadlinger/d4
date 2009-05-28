module d4.scene.Scene;

import d4.scene.Node;

abstract class Scene {
   /**
    * Returns: The root node of the scene.
    */
   abstract Node rootNode();
}