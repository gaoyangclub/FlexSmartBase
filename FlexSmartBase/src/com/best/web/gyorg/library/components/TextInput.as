package com.best.web.gyorg.library.components
{
	import flash.events.FocusEvent;
	
	import mx.utils.StringUtil;
	
	import spark.components.TextInput;

	[Style(name="icon", type="Object", inherit="no")]
	public class TextInput extends spark.components.TextInput
	{
		public function TextInput()
		{
			super();
			maxChars=25;
			height=26;
		}
		
		
		override protected function focusInHandler(event:FocusEvent):void{
			super.focusInHandler(event);
			this.selectAll();
		}
		
		override protected function focusOutHandler(event:FocusEvent):void{
			super.focusOutHandler(event);
			if(text&&(StringUtil.isWhitespace(text.charAt(0))||StringUtil.isWhitespace(text.charAt(text.length-1))))
			{
				text=StringUtil.trim(text);
			}
		}
		
//		public override function set text(value:String):void{
//			value = checkTrimValue(value);
//			super.text = value;
//		}
//		
//		private function checkTrimValue(value:String):String{
//			var newValue:String = StringUtil.trim(value);
//			if(newValue == "")//表示全部都是空白字符
//			{
//				return newValue;
//			}
//			return value;
//		}
		
//		override public function get text():String{
//			return StringUtil.trim(super.text);
//		}
	}
}