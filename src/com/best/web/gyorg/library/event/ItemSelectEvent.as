package com.best.web.gyorg.library.event
{
	import flash.events.Event;
	
	
	public class ItemSelectEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemClick";
		public static const ITEM_ADD:String = "itemAdd";
		public static const ITEM_DELETE:String = "itemDelete";//选中内部的xx
		public static const ITEM_EDIT:String = "itemEdit";//选中编辑按钮
		public static const ITEM_CHANGE:String = "itemChange";//地址更改后触发
		
		public function ItemSelectEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = true)
		{
			super(type, bubbles, cancelable);
		}
		
		public var oldIndex:int;
		public var newIndex:int;
		
		public var newItem:Object;
		public var oldItem:Object;
		
		public override function clone():Event{
			var ie:ItemSelectEvent = new ItemSelectEvent(type, bubbles, cancelable);
			ie.newItem = newItem;
			ie.oldItem = oldItem;
			ie.oldIndex = oldIndex;
			ie.newIndex = newIndex;
			return ie;
		}
		
		
	}
}