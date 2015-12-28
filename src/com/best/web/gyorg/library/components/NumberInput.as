package com.best.web.gyorg.library.components
{
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import spark.events.TextOperationEvent;
	
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.operations.InsertTextOperation;
	
	[Exclude(name="restrict", kind="property")]
	
	public class NumberInput extends TextInput
	{
		public function NumberInput()
		{
			updateRegex();
		}
		
		
		//regex pattern
		private var regex:RegExp;
		
		
		
		private var _allowNegative:Boolean = false;
		/**
		 * Specifies whether negative numbers are permitted.
		 * Valid values are true or false.
		 *
		 * @default true
		 */
		public function set allowNegative(value:Boolean):void
		{
			_allowNegative = value;
			updateRegex();
		}
		
		private var _fractionalDigits:int = 2;
		/**
		 * The maximum number of digits that can appear after the decimal
		 * separator.
		 *
		 *
		 
		 The default value is 0
		 */
		public function set fractionalDigits(value:int):void
		{
			_fractionalDigits = value;
			updateRegex();
		}
		
		/**
		 *  @private
		 */
		override public function set restrict(value:String):void
		{
			throw(new Error("You are not allowed to change the restrict property of this class.  It is read-only."));
		}
		
		override protected function childrenCreated():void
		{
			super.childrenCreated();
			
			//listen for the text change event
			addEventListener(TextOperationEvent.CHANGING, onTextChange);
		}
		
		public function get value():Number{
			if(!text){
				return NaN;
			}
			return Number(text);
		}
		
		
		
		private static function splice(str:String, start:int, end:int,
									   strToInsert:String):String
		{
			return str.substring(0, start) +
				strToInsert +
				str.substring(end, str.length);
		}
		public function onTextChange(event:TextOperationEvent):void
		{
			if (regex && event.operation is InsertTextOperation)
			{
//				trace("onTextChange in"+text);
				/**
				 * 
				 * 此处拷贝了richeditabletext中的代码来生成texttobe，替换了原本错误的代码！！
				 * 
				 */
				// What will be the text if this input is allowed to happen
				var textToBe:String = text;
				
				
				
				var insertTextOperation:InsertTextOperation =
					InsertTextOperation(event.operation);
				
				var textToInsert:String = insertTextOperation.text;
				
				// Note: Must process restrict first, then maxChars,
				// then displayAsPassword last.
				
				// The text deleted by this operation.  If we're doing our
				// own manipulation of the textFlow or thisis a result of a paste operation
				// we have to take the deleted text into account as well as the inserted text.
				var delSelOp:SelectionState = 
					insertTextOperation.deleteSelectionState;
				
				var delLen:int = (delSelOp == null) ? 0 :
					delSelOp.absoluteEnd - delSelOp.absoluteStart;
				
				
				
					// Remove deleted text.
					if (delLen > 0)
					{
						textToBe = splice(textToBe, delSelOp.absoluteStart, 
							delSelOp.absoluteEnd, "");                                    
					}
					
					// Add in the inserted text.
					if (textToInsert.length > 0)
					{
						textToBe = splice(textToBe, insertTextOperation.absoluteStart,
							insertTextOperation.absoluteStart, textToInsert);
					}
				
				
				var match:Object = regex.exec(textToBe);
				if (!match || match[0] != textToBe)
				{
					// The textToBe didn't match the expression... stop the event
					event.preventDefault();
				}
				//special condition checking to prevent multiple dots
				var firstDotIndex:int = textToBe.indexOf(".");
				if( firstDotIndex != -1)
				{
					var lastDotIndex:int = textToBe.lastIndexOf(".");
					if(lastDotIndex != -1 && lastDotIndex != firstDotIndex)
						event.preventDefault();
				}
				
			}
			
		}
		
		private function updateRegex():void
		{
			var regexString:String = "\\d{0,50}";
			if(_allowNegative)
				regexString = "^\\-?" + regexString;
			else
				regexString = "^" + regexString;
			if(_fractionalDigits > 0 )
				regexString += "\\.?\\d{0," + _fractionalDigits.toString() + "}$";
			else
				regexString += "$";
			regex = new RegExp(regexString);
		}
	}
}