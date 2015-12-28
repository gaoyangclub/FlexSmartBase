package com.best.web.gyorg.library.util.toast
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;

	public class AlertToastManager
	{
		
		private static var _mtoast:Toast;
		
		private static var t:Timer;
		t=new Timer(5000);
		t.addEventListener(TimerEvent.TIMER,onTimer);
		
		private static function onTimer(e:TimerEvent):void{
			_mtoast.currentState="hide";
		}
		
		public static function toast(text:String,delay:int=5000):void{
			if(_mtoast==null){
				_mtoast=new Toast;
				_mtoast.bgColor=0xff0000;
				_mtoast.setStyle("color",0xffffff);
				_mtoast.addEventListener(MouseEvent.CLICK,ToastManager.toastClickHandler);
				PopUpManager.addPopUp(_mtoast,FlexGlobals.topLevelApplication as DisplayObject);
			}
			ToastManager.doToast(text,t,delay,_mtoast);
		}
		
		
		
	}
}