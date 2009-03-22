package com.mccullick.utils 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.errors.IOError;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.Event;

	
	/**
	* SpriteManager
	* @author Philip McCullick
	*/
	public class SpriteManager implements IEventDispatcher
	{
		private var sprites:Array;
		private static var instance:SpriteManager;
		
		private var curLoading:Object;
		private var loadQueue:Array;
		private var loader:Loader;
		
		private var numLoaded:Number;
		private var total:Number;
		
		public static var LOAD_COMPLETE:String = "loadComplete";
		public static var LOAD_PROGRESS:String = "loadProgress";
		/**
		 * Constructor is private since this is a Singleton
		 * @param	key - throws a compile time error if the constructor is called outside this class
		 */
		public function SpriteManager(key:SingletonKey)
		{
			this.loader = new Loader();
			this.loadQueue = new Array();
			this.sprites = new Array();
			this.numLoaded = 0;
			this.total = 0;
			
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);			
			loader.contentLoaderInfo.addEventListener(Event.INIT, init);
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
		public function addSprite(id:String, sprite:Sprite):void
		{
			sprites[id] = sprite;
		}
		
		/**
		 * Adds a class, used for adding assets Embeded in the swf
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
		
		public function loadSpritesFile (filename:String):void
		{
			
			var xmlLoader:URLLoader = new URLLoader();
			var xmlData:XML = new XML();
			 
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {

				xmlData = new XML(e.target.data);
				
				loadSpritesXML(xmlData);				
				
			});
			 
			xmlLoader.load(new URLRequest(filename));
		}
		public function loadSpritesXML(xmlData:XML):void
		{	
			for each  (var  tile:XML  in xmlData.tile)  
			{
				loadSprite(tile.text(), tile.@id);				
			}
		}
		
		
		/**
		 * Loads a sprite from a file
		 * @param	filename
		 * @param	id
		 */
		public function loadSprite(filename:String, id:String=null):void		
		{
			total++;
			if (id == null)
			{
				id = filename;
			}
			
			loadQueue.push( { filename:filename, id:id } );
			
			if (curLoading == null)
			{
				loadNext();
			}
		}
		
		/**
		 * Starts the loading of the next sprite
		 */
		public function loadNext():void		
		{
			if (loadQueue.length > 0)
			{
				curLoading = loadQueue.shift();
				var request:URLRequest = new URLRequest(curLoading.filename);

				try {
					loader.load(request);
				}catch (error:SecurityError) {
					trace(error);
				}
			}else 
			{
				dispatchEvent(new Event(SpriteManager.LOAD_COMPLETE));
			}
			
		}
		
		/**
		 * Handle loader error event
		 * @param	evt
		 */
		private function ioError(evt:IOErrorEvent):void
		{
			trace("error: " + evt);
			numLoaded++;
		}

		private function init(evt:Event):void 
		 {
			var loader:LoaderInfo = (LoaderInfo)(evt.target);          
			sprites[curLoading.id] = loader.content;	
			numLoaded++;
			dispatchEvent(new Event(SpriteManager.LOAD_PROGRESS));		
			loadNext();
        }
		
		public function getNumLoaded():Number
		{
			return numLoaded;
		}
		public function getTotal():Number
		{
			return total;
		}
		
		/*****************************************
		 * 
		 *   EVENT DISPATCHER CODE 
		 * 
		 */
		protected var disp:EventDispatcher;
		public function addEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false, p_priority:int=0, p_useWeakReference:Boolean=false):void {
			if (disp == null) { disp = new EventDispatcher(); }
			disp.addEventListener(p_type, p_listener, p_useCapture, p_priority, p_useWeakReference);
		}
		public function removeEventListener(p_type:String, p_listener:Function, p_useCapture:Boolean=false):void {
			if (disp == null) { return; }
			disp.removeEventListener(p_type, p_listener, p_useCapture);
		}
		public function dispatchEvent(p_event:Event):Boolean {
			if (disp == null) { return false; }
			
			return disp.dispatchEvent(p_event);
		}
		public function hasEventListener(type:String):Boolean{
			return disp.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean {
			return disp.willTrigger(type);
		}
    

		/*
		 * 
		 *  END EVENT DISPATCHER CODE 
		 * 
		 *****************************************/
	}
	
}

class SingletonKey {	public function SingletonKey(){	} }
