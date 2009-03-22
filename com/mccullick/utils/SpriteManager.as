package com.mccullick.utils 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;	
	import flash.display.Sprite;

	
	/**
	* SpriteManager holds a list of images that can be easily accessed by identifiers. The SpriteManager is
	* a Singleton so it can be accessed from anywhere. The images can be from BitmapData, Class, or Sprites. 
	* No matter how the original was added the image can be retrieved as a DisplayObject.
	* 
	* @usage	
	* 	//add the class from an embedded movie
	* 	SpriteManager.getInstance().addClass("myImage", MyImage);
	* 
	* 	//get the DisplayObject
	* 	SpriteManager.getSprite("myImage");
	* 
	* @author Philip McCullick
	*/
	public class SpriteManager
	{
		private var sprites:Array;
		private static var instance:SpriteManager;
		
		/**
		 * Constructor is private since this is a Singleton
		 * @param	key - throws a compile time error if the constructor is called outside this class
		 */
		public function SpriteManager(key:SingletonKey)
		{
			this.sprites = new Array();			
		}
		
		/**
		 * Gets an instance of the SpriteManager singleton
		 * @return
		 */
		public static function getInstance():SpriteManager
		{
			if (instance == null) 
			{
				instance = new SpriteManager(new SingletonKey());
			}
			return instance;
		}
		
		/**
		 * Gets a DisplayObject for the given id
		 * @param	id
		 * @return
		 */
		public static function getSprite(id:String):DisplayObject
		{
			if (instance.sprites[id] is Bitmap)
			{
				return new Bitmap(instance.sprites[id].bitmapData);
			}else if (instance.sprites[id] is Sprite)
			{
				return instance.sprites[id];
			}else if (instance.sprites[id] is Class)
			{
				return new instance.sprites[id]();
			}else
			{
				throw Error("SpriteManager.getSprite(" + id + ") could not find sprite");
			}
		}
		
		/**
		 * Add a sprite
		 * @param	id
		 * @param	sprite
		 */
		public function addSprite(id:String, sprite:Sprite):void
		{
			sprites[id] = sprite;
		}
		
		/**
		 * Adds a Class, used for adding assets Embeded in the swf
		 * @param	id
		 * @param	dpClass
		 */
		public function addClass(id:String, dpClass:Class):void
		{
			sprites[id] = dpClass;
		}
		
		/**
		 * Adds a bitmap
		 * @param	id
		 * @param	sprite
		 */
		public function addBitmap(id:String, sprite:Bitmap):void
		{
			sprites[id] = sprite;
		}
	}
}

class SingletonKey {	public function SingletonKey(){	} }
