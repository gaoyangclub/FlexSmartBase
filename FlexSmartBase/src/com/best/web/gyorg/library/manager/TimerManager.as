package com.best.web.gyorg.library.manager
{
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	public class TimerManager
	{
		
		private static var timeOutDic:Dictionary = new Dictionary(true);
		private static var intervalDic:Dictionary = new Dictionary(true);
		
		public static function setIntervalOut(delay:Number,func:Function,...args):void{
			if(intervalDic[func] !== undefined){
				clearIntervalOut(func);//先把之前的清除
			}
			var timeID:int = setInterval(onIntervalOut,delay,func,args);
			intervalDic[func] = timeID;
		}
		
		private static function onIntervalOut(func:Function,args:Array = null):void{
			if(func != null) args != null ? func.apply(null,args) : func();
		}
		
		public static function clearIntervalOut(func:Function):void{
			var timeID:int = intervalDic[func];
			clearInterval(timeID);
		}
		
		//key:func value:timeID
		public static function setTimeOut(delay:Number,func:Function,...args):void{
			if(timeOutDic[func] !== undefined){
				clearTimeOut(func);//先把之前的清除
			}
			var timeID:int = setTimeout(onTimeOut,delay,func,args);
			timeOutDic[func] = timeID;
		}
		
		private static function onTimeOut(func:Function,args:Array = null):void{
			clearTimeOut(func);
			if(func != null) args != null ? func.apply(null,args) : func();
		}
		
		public static function clearTimeOut(func:Function):void{
			var timeID:int = timeOutDic[func];
			clearTimeout(timeID);
		}
		
	}
}