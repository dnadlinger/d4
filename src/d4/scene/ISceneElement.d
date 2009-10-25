module d4.scene.ISceneElement;

import d4.scene.ISceneVisitor;

interface ISceneElement {
   void accept( ISceneVisitor visitor );
}