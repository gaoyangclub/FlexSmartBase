package com.best.web.gyorg.library.manager
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	public class ImageLoader
	{
		private static var urlDic:Dictionary = new Dictionary(true);//key:url,value:loader
		private static var loadDic:Dictionary = new Dictionary(true);//key:loader,value:Vector.<LoadVo>
		private static var eventDic:Dictionary = new Dictionary(true);
		private static var loadDispatcher:EventDispatcher = new EventDispatcher();
		
		public static function loadFile(url:String,loadFunc:Function = null,...args):void{
			if(url == null || url == ''){
				trace("ImageLoader::图片地址有误");
				return;
			}
			initFile(url,loadFunc,args);
		}
		
		public static function loadFileWithEvent(url:String,loadFunc:Function = null,
												 eventType:String = null,...args):void{
			pushEvent(eventType,url);
			initFile(url,loadFunc,args,eventType);
		}
		/**
		 * 注册全部加载完成事件:Event.COMPLETE
		 * @param func
		 */		
		public static function addCompleteEvent(func:Function):void{
			loadDispatcher.addEventListener(Event.COMPLETE,func);
		}
		public static function removeCompleteEvent(func:Function):void{
			loadDispatcher.removeEventListener(Event.COMPLETE,func);
		}
		public static function addEventListener(type:String,handler:Function):void{
			loadDispatcher.addEventListener(type,handler);
		}
		public static function removeEventListener(type:String,handler:Function):void{
			loadDispatcher.removeEventListener(type,handler);
		}
		
		private static function pushEvent(eventType:String,url:String):void{
			if(eventType != null && url != ''){
				var eList:Vector.<String> = eventDic[eventType];
				if(eList == null){
					eList = eventDic[eventType] = new Vector.<String>();
				}
				eList.push(url);
			}
		}
		
		private static function initFile(url:String,loadFunc:Function,args:Array,
										 eventType:String = null):void
		{
			var data:Object = getFile(url);
			if(data != null){
				if(eventType != null){
					setTimeout(loadComplete,50,data,url,loadFunc,args,eventType);
				}else{
					loadComplete(data,url,loadFunc,args,eventType);
				}
			}else{
				checkFile(url,loadFunc,args,eventType);
			}
		}
		
		private static function checkFile(url:String, loadFunc:Function, args:Array,
										  eventType:String = null):void
		{
			//			if(urlDic == null)urlDic = new Dictionary(true);
			//			if(loadDic == null)loadDic = new Dictionary(true);
			var tempUrl:String = url.toLocaleLowerCase();
			if(tempUrl.lastIndexOf('.png') > 0 || tempUrl.lastIndexOf('.jpg') > 0 || 
				tempUrl.lastIndexOf('.gif') > 0){//加载材质数据
				loadImage(url,loadFunc,args,eventType);
			}
//			loadProgress();
		}
		/**
		 * 先检查是否已经开始加载了 如果已经开始加载 就无需再加载 直接传入回调函数即可 等一起加载结束后回调
		 * @param url
		 * @param loadFunc
		 * @param args
		 */		
		private static function loadImage(url:String, loadFunc:Function, args:Array,
										  eventType:String = null):void
		{
			if(urlDic[url] !== undefined){
				loader = urlDic[url];
			}else{
				var lc:LoaderContext = new LoaderContext(true);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onAssetsComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
				//				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onAssetsProgress);
				loader.load(new URLRequest(url),lc);
			}
			pushLoader(loader,url,loadFunc,args,null,eventType);
		}
		
		private static var urlLoaderDic:Dictionary = new Dictionary(true);
		private static function onAssetsComplete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE,onAssetsComplete);
			var loader:Object;
			var asset:Object;
			if(e.target is LoaderInfo){
				loader = (e.target as LoaderInfo).loader;
				asset = (loader as Loader).content;
				(loader as Loader).unloadAndStop();
				dispose(loader,asset);
			}
		}
		
		private static function onError(e:IOErrorEvent):void
		{
			var loader:Object;
			if(e.target is LoaderInfo){
				loader = (e.target as LoaderInfo).loader;
				(loader as Loader).unloadAndStop();
			}else{
				loader = e.target as URLLoader;
			}
			var loadVector:Vector.<LoadVo> = loadDic[loader];
			var url:Object = loadVector[0].url;
//			trace('ImageLoader::加载地址有误:' + url + '\n错误信息:' + e);
			exit(loader);
		}
		/**
		 * 目标地址有误 直接跳出
		 * @param loader
		 */		
		private static function exit(loader:Object):void{
			var loadVector:Vector.<LoadVo> = loadDic[loader];
			var url:Object = loadVector[0].url;
			delete loadDic[loader];
			delete urlDic[url];
			//			delete eventDic[url];
			loader = null;
			loadVector.length = 0;
			loadVector = null;
		}
		
		private static function dispose(loader:Object,asset:Object):void{
			var loadVector:Vector.<LoadVo> = loadDic[loader];
			var url:Object = loadVector[0].url;
			ResourceBox.setResource(url,asset);
			
			delete loadDic[loader];
			delete urlDic[url];
			//			delete eventDic[url];
			loader = null;
			for each (var lvo:LoadVo in loadVector) 
			{
				//				if(asset is Mesh){
				//					//					trace("有模型");
				//					asset = (asset as Mesh).clone();
				//				}
				loadComplete(asset,lvo.url,lvo.loadFunc,lvo.args,lvo.eventType);
			}
			//			if(lvo != null && lvo.eventType != null){
			//				checkEventType(lvo.eventType);
			//			}
			loadVector.length = 0;
			loadVector = null;
		}
		
		private static function checkEventType(eventType:String):void
		{
			if(loadDispatcher.hasEventListener(eventType)){
				var eList:Vector.<String> = eventDic[eventType];
				if(eList != null && eList.length == 0){//说明已经全部加载完毕
					trace("ImageLoader::事件: " + eventType + " 全部加载完毕");
					loadDispatcher.dispatchEvent(new Event(eventType));
				}
			}
		}
		
		/**
		 * @param loader
		 */		
		private static function pushLoader(loader:Object,
										   url:Object,loadFunc:Function, args:Array,byte:ByteArray = null,eventType:String = null):void
		{
			var loadVector:Vector.<LoadVo> = loadDic[loader];
			if(loadVector == null){
				loadVector = loadDic[loader] = new Vector.<LoadVo>();
			}
			loadVector.push(new LoadVo(url,loadFunc,args,byte,eventType));
			urlDic[url] = loader;
		}
		
		private static function loadComplete(data:Object,url:Object,loadFunc:Function, args:Array,
											 eventType:String = null):void
		{
			if(args != null){ //如果传入第三个参数
				args.unshift(data);
				loadFunc.apply(null,args);//如果第三个参数传入 也将自己作为参数传出
			}else{
				loadFunc(data);
			}
			if(eventType != null){
				popEvent(eventType,url as String);
				trace("ImageLoader::事件: " + eventType + " 数据: " + data);
				checkEventType(eventType);
			}
		}
		
		private static function popEvent(eventType:String, url:String):void
		{
			var eList:Vector.<String> = eventDic[eventType];
			if(eList != null){
				var index:int = eList.indexOf(url);
				if(index >= 0){
					eList.splice(index,1);
				}
			}
		}
		
		private static function getFile(url:Object):Object
		{
			if(ResourceBox.cotainKey(url))return ResourceBox.getResource(url);
			return null;
		}
	}
}
import flash.utils.ByteArray;
import flash.utils.Dictionary;

class ResourceBox
{
	/**
	 * 通过Dictionary保存图片序列bitmapData标签为图片url
	 * 主要实现 存最新图片序列 检查已有的图片序列 取目标图片序列
	 */		
	private static var resource:Dictionary = new Dictionary(true);
	
	/**
	 * 存入目标资源
	 * @param url 目标资源地址
	 * @param data 目标资源（图片序列BitmapData 或 影片MovieClip）
	 */		
	public static function setResource(url:Object , data:* ):void{
		resource[url] = data;
	}
	
	/**
	 * 检查目标资源地址对应的目标资源是否已经在素材管理器里面存在
	 * data的值即不是null也不是undefined表示存在才为true
	 * @param url 目标资源地址
	 * @return 是否有
	 */		
	public static function cotainKey(url:Object):Boolean{
		if(resource[url] !== undefined && resource[url] != null){
			return true; //发现该种子对应的数据确实有的
		}
		return false;
	}
	
	/**
	 * 取得目标资源地址对应的目标资源
	 * @param url 目标资源地址
	 * @return 目标资源
	 */		
	public static function getResource(url:Object):*{
		return resource[url];
	}
}
class LoadVo
{
	public function LoadVo(url:Object, loadFunc:Function, args:Array,byte:ByteArray = null,
						   eventType:String = null):void{
		this.url = url;
		this.loadFunc = loadFunc;
		this.args = args;
		this.byte = byte;
		this.eventType = eventType;
	}
	public var url:Object;
	public var loadFunc:Function;
	public var args:Array;
	public var eventType:String;
	public var byte:ByteArray;
}