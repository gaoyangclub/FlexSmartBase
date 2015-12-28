package com.best.web.gyorg.library.components
{
	import com.best.web.gyorg.library.util.toast.AlertToastManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;

	public class RangeNumberInput extends NumberInput
	{
		public function RangeNumberInput()
		{
			super();
			this.fractionalDigits=2;
			this.addEventListener(FlexEvent.ENTER,enterHander);
			this.addEventListener(FlexEvent.VALUE_COMMIT,vcHandler,true);
		}
		
		public var maximum:Number;
		
		public var minimum:Number;
		
		public var showAlert:Boolean;
		
		protected function vcHandler(e:FlexEvent):void{
			var nv:Number=Number(text);
			if(nv>maximum){
				textDisplay.text=maximum+'';
				if(showAlert){
					AlertToastManager.toast("不得大于"+maximum);
				}
				
			}else if(nv<minimum){
				textDisplay.text=minimum+'';
				if(showAlert){
					AlertToastManager.toast("不得小于"+minimum);
				}
				
			}
		}
		
		protected function enterHander(e:Event):void{
			this.textDisplay.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		override protected function focusInHandler(event:FocusEvent):void{
			super.focusInHandler(event);
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN,msdHandler);
		}
		protected function msdHandler(e:Event):void{
			if(!this.owns(e.target as DisplayObject)){
				this.textDisplay.dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				systemManager.removeEventListener(MouseEvent.MOUSE_DOWN,msdHandler);
			}
			
		}
	}
}