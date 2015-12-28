package com.menu
{
	import com.stack.AlertAdvanceStack;
	import com.stack.AreaChooseBoxStack;
	import com.stack.ArrowGroupStack;
	import com.stack.ChooseInputStack;
	import com.stack.DateChooseBoxStack;
	import com.stack.ImageButtonStack;
	import com.stack.ImageMagnifierBoxStack;
	import com.stack.NumberTagGroupStack;
	import com.stack.PopupButtonAdvanceStack;
	import com.stack.PopupButtonGroupStack;
	import com.stack.PopupDialogWindowStack;
	import com.stack.SingleColorStack;
	import com.stack.TextInputAdvanceStack;
	import com.stack.TitlePartListStack;
	import com.stack.ToolBarListStack;

	/**
	 * 数据源
	 * @author bl04696
	 */	
	public class TreeMenuCenter
	{
		[Bindable]
		public static var treeDp:Array = [
			{name:"button",children:[
				{name:"ImageButton",stack:ImageButtonStack},
				{name:"SingleColorButton",stack:SingleColorStack},
				{name:"PopupButtonGroup",stack:PopupButtonGroupStack},
				{name:"PopupButtonAdvance",stack:PopupButtonAdvanceStack}
			]},
			{name:"text",children:[
				{name:"TextInputAdvance",stack:TextInputAdvanceStack},
				{name:"ChooseInput",stack:ChooseInputStack}
			]},
			{name:"date",children:[
				{name:"DateChooseBox",stack:DateChooseBoxStack}
			]},
			{name:"alert",children:[
				{name:"AlertAdvance",stack:AlertAdvanceStack}
			]},
			{name:"choose",children:[
				{name:"AreaChooseBox",stack:AreaChooseBoxStack}
			]},
			{name:"image",children:[
				{name:"ImageMagnifierBox",stack:ImageMagnifierBoxStack}
			]},
			{name:"tag",children:[
				{name:"NumberTagGroup",stack:NumberTagGroupStack}
			]},
			{name:"list",children:[
				{name:"TitlePartList",stack:TitlePartListStack},
				{name:"ToolBarList",stack:ToolBarListStack}
			]},
			{name:"popup",children:[
				{name:"PopupDialogWindow",stack:PopupDialogWindowStack}
			]},
			{name:"arrow",children:[
				{name:"ArrowGroup",stack:ArrowGroupStack}
			]}
		];
		
	}
}