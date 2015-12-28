package com.best.web.gyorg.library.util.toast
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	

	public class ToastManager
	{
		public function ToastManager()
		{
		}
		
		private static var _mtoast:Toast;
		
		
		private static var t:Timer;
		t=new Timer(3000);
		t.addEventListener(TimerEvent.TIMER,onTimer);
		
		private static function onTimer(e:TimerEvent):void{
			_mtoast.currentState="hide";
		}
		
		public static function toastClickHandler(e:MouseEvent):void{
			var mtoast:Object=e.currentTarget;
			mtoast.currentState="hide";
		}
		
		
		public static function toast(text:String,delay:int=3000):void{
			if(_mtoast==null){
				_mtoast=new Toast;
				_mtoast.addEventListener(MouseEvent.CLICK,ToastManager.toastClickHandler);
				PopUpManager.addPopUp(_mtoast,FlexGlobals.topLevelApplication as DisplayObject);
			}
			doToast(text,t,delay,_mtoast);
		}
		
		public static function doToast(text:String,timer:Timer,delay:int,toast:Toast):void{

			
			toast.txt=text;
			
			PopUpManager.centerPopUp(toast);
			PopUpManager.bringToFront(toast);
			toast.currentState="show";
			if(timer.running){
				timer.stop();
			}else{
				
			}
			
			timer.delay=delay;
			timer.repeatCount=1;
			timer.start();
		}
	}
}