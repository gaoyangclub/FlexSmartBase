package com.best.web.gyorg.library.dialog
{
	import com.best.web.gyorg.library.skin.PopupDialogSkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.Button;
	import mx.controls.LinkButton;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.SandboxMouseEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Panel;
	import spark.events.TitleWindowBoundsEvent;
	
	public class ResizeableWindow extends Panel
	{
		public function ResizeableWindow()
		{
			super();
//			this.title = "你阿妈标题啊啊 啊啊 啊";
		}
		
		protected var maxSizeButton:Button; //最大化按钮
		[Embed("/assets/style/titleWinIcon/WindowMaxButton.png")]private var IconMaxSize:Class;//载入最大化图标
		[Embed("/assets/style/titleWinIcon/Buttonmaximize.png")]private var mouseOnIconMaxSize:Class;//载入最大化图标
		[Embed("/assets/style/titleWinIcon/WindowMaxButton2.png")]private var mouseupIconMaxSize:Class;//载入最大化图标
		protected var minSizeButton:Button; //最小化按钮
		[Embed("/assets/style/titleWinIcon/WindowMinButton.png")]private var IconMinSize:Class;//载入最小化图标
		[Embed("/assets/style/titleWinIcon/Buttonminimize.png")]private var mouseOnIconMinSize:Class;//载入最小化图标
		[Embed("/assets/style/titleWinIcon/WindowMinButton2.png")]private var mouseupIconMinSize:Class;//载入最小化图标
		
		
		[Embed("/assets/style/titleWinIcon/Buttonrestore.png")]private var Iconhuany:Class;//载入还原图标
		[Embed("/assets/style/titleWinIcon/WindowRestoreButton.png")]private var IconhuanyOn:Class;//载入还原图标
		[Embed("/assets/style/titleWinIcon/WindowRestoreButton2.png")]private var IconhuanyDown:Class;//载入还原图标
		
		protected var closeButton:Button;//关闭按钮
		[Embed("/assets/style/titleWinIcon/WindowCloseButton.png")]private var IconClose:Class;//载入最小化图标
		[Embed("/assets/style/titleWinIcon/Buttonclose.png")]private var mouseOnIconClose:Class;//载入最小化图标
		[Embed("/assets/style/titleWinIcon/WindowCloseButton2.png")]private var mouseupIconClose:Class;//载入最小化图标
		
		//调整TitleWindow大小
		private var mouseMargin:Number = 4;//响应范围
		//设置光标的位置值 右上：3  右下：6 左下：11  左上8
		private var theSide:Number = 0;
		private var SIDE_OTHER:Number = 0;
		private var SIDE_TOP:Number = 1;
		private var SIDE_RIGHT:Number = 2;
		private var SIDE_LEFT:Number = 7;
		private var SIDE_BOTTOM:Number = 4;
		private var isReSize:Boolean;//是否允许缩放
		private var theOldPoint:Point;//改变大小前窗口的x，y坐标
		private var _theMinWidth:Number = 30;//窗口最小宽度
		public function get theMinWidth():Number
		{
			return _theMinWidth;
		}
		public function set theMinWidth(value:Number):void
		{
			_theMinWidth = value;
		}
		private var _theMinHeight:Number = 20;//窗口最大高度
		public function get theMinHeight():Number
		{
			return _theMinHeight;
		}
		public function set theMinHeight(value:Number):void
		{
			_theMinHeight = value;
		}

		/** ---------------------------- start:1 控制三个按钮的状态 ----------------  */
		private var _showMin:Boolean = false;//显示最小化
		public function get showMin():Boolean
		{
			return _showMin;
		}
		public function set showMin(value:Boolean):void
		{
			_showMin = value;
			checkButtonGroup();
		}
		private var _showMax:Boolean = false;//显示最大化
		public function get showMax():Boolean
		{
			return _showMax;
		}
		public function set showMax(value:Boolean):void
		{
			_showMax = value;
			checkButtonGroup();
		}
		private var _showClose:Boolean = true;//显示关闭
		public function get showClose():Boolean
		{
			return _showClose;
		}
		public function set showClose(value:Boolean):void
		{
			_showClose = value;
			checkButtonGroup();
		}
		/** ---------------------------- end:1 ----------------  */
		
		private var theOldWidth:Number;//最大最小化时的宽
		private var theOldHeight:Number;//最大最小化时的高
		private var theStatus:int = 0;//窗口状态，0正常 1最大化 2最小化；
		private var titleNormal:String;//正常状态下的标题
		private var titleMin:String;//最小化时的标题
		//当前鼠标光标类
		public var currentType:Class=null;
		//鼠标光标图标
		[Embed("/assets/style/titleWinIcon/resizeCursorH.gif")]
		private var CursorH:Class;
		[Embed("/assets/style/titleWinIcon/resizeCursorTLBR.gif")]
		private var CursorR:Class;
		[Embed("/assets/style/titleWinIcon/resizeCursorTRBL.gif")]
		private var CursorL:Class;
		[Embed("/assets/style/titleWinIcon/resizeCursorV.gif")]
		private var CursorV:Class;
		private var CursorNull:Class=null;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			(this.titleDisplay as DisplayObjectContainer).doubleClickEnabled = true;
			this.titleDisplay.addEventListener(MouseEvent.DOUBLE_CLICK,onMaxSize);
			this.titleDisplay.addEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
			
			//侦听拖拽相关的事件
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			titleNormal = this.title;
			titleMin = this.title.substring(0, 8) + "...";
		}
		
		protected function createButton(parent:Group):void{
			//创建最大化按钮
			this.maxSizeButton = new LinkButton();
			this.maxSizeButton.width = this.maxSizeButton.height = 16;
			//			this.maxSizeButton.y = 6;
			this.maxSizeButton.setStyle("upIcon", IconMaxSize);
			this.maxSizeButton.setStyle("overIcon", mouseOnIconMaxSize);
			this.maxSizeButton.setStyle("downIcon", mouseupIconMaxSize);
			//添加最大化事件
			this.maxSizeButton.addEventListener(MouseEvent.CLICK,onMaxSize);
			
			//创建最小化按钮
			this.minSizeButton = new LinkButton();
			this.minSizeButton.width = this.minSizeButton.height = 16;
			//			this.minSizeButton.y = 6;
			this.minSizeButton.setStyle("upIcon", IconMinSize);
			this.minSizeButton.setStyle("overIcon", mouseOnIconMinSize);
			this.minSizeButton.setStyle("downIcon", mouseupIconMinSize);
			//添加最小化事件
			this.minSizeButton.addEventListener(MouseEvent.CLICK,onMinSize);
			
			//创建关闭按钮
			this.closeButton = new LinkButton();
			this.closeButton.width = this.closeButton.height = 16;
			//			this.closeButton.y = 6;
			this.closeButton.setStyle("upIcon", IconClose);
			this.closeButton.setStyle("overIcon", mouseOnIconClose);
			this.closeButton.setStyle("downIcon", mouseupIconClose);
			//添加关闭事件
			this.closeButton.addEventListener(MouseEvent.CLICK,onClose);
			
			buttonGroup = new HGroup();
			checkButtonGroup();
			buttonGroup.setStyle("right",10);
							//							buttonGroup.y = 6;
			buttonGroup.gap = 0;
			parent.addElement(buttonGroup);
			
//			var titleArea:Group = ((this.titleDisplay as DisplayObject).parent as Group);
//			if(titleArea != null){
//			}
//				titleArea.addElement(buttonGroup);
		}
		
		private function checkButtonGroup():void{
			if(buttonGroup != null){
				buttonGroup.removeChildren();//先全部移除掉
				if(_showMin)buttonGroup.addElement(this.minSizeButton);
				if(_showMax)buttonGroup.addElement(this.maxSizeButton);
				if(_showClose)buttonGroup.addElement(this.closeButton);
			}
		}
		
		protected function onMaxSize(e:MouseEvent):void
		{
			if(theStatus == 0)
			{
				onSaveRestore();
				winMaxSize();
			}
			else if(theStatus == 2){
				winMaxSize();
			}
			else if(theStatus == 1)
			{
				onGetRestore();
			}
		}
		protected function onMinSize(e:MouseEvent):void
		{
			if(theStatus != 2){
				if(theStatus == 0){
					onSaveRestore();
				}
				winMinSize();
			}
			else{
				onGetRestore();
			}
		}
		
		protected function onClose(e:MouseEvent):void{
			PopUpManager.removePopUp(this);
			this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
//		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
//			var theX:int = unscaledWidth - 25.5;
//			var theY:int = 6;
//			closeButton.move(theX,theY);
//			super.updateDisplayList(unscaledWidth,unscaledHeight);
//		}
		
//		override protected function startDragging(event:MouseEvent):void{
//			//设置TitleWindow的拖动的矩形区域
//			var rt:Rectangle = new Rectangle(0, 0, this.parent.width - this.width, this.parent.height - this.height);
//			this.startDrag(false, rt);//设置可以拖动的矩形区域
//			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
//		}
		
		private function stopDragHandler():void{
			this.stopDrag();
		}
		
//		protected function mouseUpEvent(event:MouseEvent):void{
//			this.stopDrag();
//			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
//		}
		
//		override protected function layoutChrome(unscaledWidth:Number,
//												 unscaledHeight:Number):void
//		{
//			super.layoutChrome(unscaledWidth,unscaledHeight);
//			//设置两个新添的按钮的位置
//			this.maxSizeButton.x = this.titleDisplay.width - 43;
//			this.minSizeButton.x = this.titleDisplay.width - 60;
//			//调整状态文本的位置，左移一段位置
//			this.statusTextField.x-=32;
//		}
		
		//调整大小
		private function onMouseUp(event:MouseEvent):void
		{
			if(isReSize)
			{
				FlexGlobals.topLevelApplication.parent.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				FlexGlobals.topLevelApplication.parent.removeEventListener(MouseEvent.MOUSE_MOVE,onResize);
				isReSize = false;
				//				dispatchEvent(new Event(TITLEWINDOW_RESIZE));
			}
			onChangeCursor(CursorNull);
		}
		private function onMouseDown(event:MouseEvent):void
		{
			if(theSide != 0 && theSide != 5)
			{
				isReSize = true;
				FlexGlobals.topLevelApplication.parent.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
				FlexGlobals.topLevelApplication.parent.addEventListener(MouseEvent.MOUSE_MOVE,onResize);
				var point:Point = new Point();
				point = this.localToContent(point);
				theOldPoint = point;
			}
		}
		
		private function onResize(event:MouseEvent):void
		{
			if(isReSize)
			{
				var xPlus:Number = FlexGlobals.topLevelApplication.parent.mouseX - this.x;
				var yPlus:Number = FlexGlobals.topLevelApplication.parent.mouseY - this.y;
				
//				var rt:Rectangle = new Rectangle(0, 0, this.parent.width - this.width, this.parent.height - this.height);
//				if(this.x + xPlus < 0 || this.x + xPlus > rt.width || this.y + yPlus < 0 || this.y + yPlus > rt.height
//				){
//					return;
//				}
//				_theMinWidth = contentGroup.width;
//				_theMinHeight = contentGroup.height;
				
				switch(theSide)
				{
					case SIDE_RIGHT+SIDE_BOTTOM:
						this.width=xPlus>_theMinWidth?xPlus:_theMinWidth;
						this.height=yPlus>_theMinHeight?yPlus:_theMinHeight;
						break;
					case SIDE_LEFT+SIDE_TOP:
						this.width=this.width-xPlus>_theMinWidth?this.width-xPlus:_theMinWidth;
						this.height=this.height-yPlus>_theMinHeight?this.height-yPlus:_theMinHeight;
						this.x = this.width>_theMinWidth?FlexGlobals.topLevelApplication.parent.mouseX:this.x;
						this.y = this.height>_theMinHeight?FlexGlobals.topLevelApplication.parent.mouseY:this.y;
						break;
					case SIDE_LEFT+SIDE_BOTTOM:
						this.width=this.width-xPlus>_theMinWidth?this.width-xPlus:_theMinWidth;
						this.height=yPlus>_theMinHeight?yPlus:_theMinHeight;
						this.x = this.width>_theMinWidth?FlexGlobals.topLevelApplication.parent.mouseX:this.x;
						break;
					case SIDE_RIGHT+SIDE_TOP:
						this.width=xPlus>_theMinWidth?xPlus:_theMinWidth;
						this.height=this.height-yPlus>_theMinHeight?this.height-yPlus:_theMinHeight;
						this.y = this.height>_theMinHeight?FlexGlobals.topLevelApplication.parent.mouseY:this.y;
						break;
					case SIDE_RIGHT:
						this.width = xPlus>_theMinWidth?xPlus:_theMinWidth;
						break;
					case SIDE_LEFT:
						this.width = this.width-xPlus>_theMinWidth?this.width-xPlus:_theMinWidth;
						this.x = this.width>_theMinWidth?FlexGlobals.topLevelApplication.parent.mouseX:this.x;
						break;
					case SIDE_BOTTOM:
						this.height = yPlus>_theMinHeight?yPlus:_theMinHeight;
						break;
					case SIDE_TOP:
						this.height = this.height-yPlus>_theMinHeight?this.height-yPlus:_theMinHeight;
						this.y = this.height>_theMinHeight?FlexGlobals.topLevelApplication.parent.mouseY:this.y;
						break;
				}
			}
			
		}
		private function onMouseOut(event:MouseEvent):void
		{
			if(!isReSize&&this.theStatus==0)
			{
				theSide=0;
				onChangeCursor(CursorNull);
				this.isPopUp=true;
			}
		}
		private function onMouseMove(event:MouseEvent):void
		{
			if(theStatus == 0 && !isReSize)//正常状态下
			{
				var point:Point = new Point();
				point = this.localToGlobal(point);
				var xPosition:Number = FlexGlobals.topLevelApplication.parent.mouseX;
				var yPosition:Number = FlexGlobals.topLevelApplication.parent.mouseY;
				if(xPosition >= (point.x + this.width-mouseMargin) && yPosition >= (point.y + this.height - mouseMargin))
				{//右下
					onChangeCursor(CursorR,-9,-9);
					theSide = SIDE_RIGHT+SIDE_BOTTOM;
					this.isPopUp = false;
				}else if(xPosition <= (point.x + mouseMargin) && yPosition <= (point.y + mouseMargin))
				{//左上
					onChangeCursor(CursorR,-9,-9);
					theSide = SIDE_LEFT+SIDE_TOP;
					this.isPopUp = false;
				}else if(xPosition <= (point.x + mouseMargin) && yPosition >= (point.y + this.height - mouseMargin))
				{//左下
					onChangeCursor(CursorL,-9,-9);
					theSide = SIDE_BOTTOM+SIDE_LEFT;
					this.isPopUp = false;
				}else if(xPosition >= (point.x + this.width - mouseMargin) && yPosition <= (point.y + mouseMargin))
				{//右上
					onChangeCursor(CursorL,-9,-9);
					theSide=SIDE_RIGHT+SIDE_TOP;
					this.isPopUp=false;
				}else if(xPosition>(point.x+this.width-mouseMargin))
				{//右
					onChangeCursor(CursorH,-9,-9);
					theSide=SIDE_RIGHT;
					this.isPopUp=false;
				}else if(xPosition<(point.x+mouseMargin))
				{//左
					onChangeCursor(CursorH,-9,-9);
					theSide=SIDE_LEFT;
					this.isPopUp=false;
				}else if(yPosition<(point.y+mouseMargin))
				{//上
					onChangeCursor(CursorV,-9,-9);
					theSide=SIDE_TOP;
					this.isPopUp=false;
				}
				else if(yPosition>(point.y+this.height-mouseMargin))
				{//下
					onChangeCursor(CursorV,-9,-9);
					theSide = SIDE_BOTTOM;
					this.isPopUp=false;
				}
				else
				{
					onChangeCursor(CursorNull);
					if(!isReSize&&theStatus==0)
					{
						theSide=0;
						this.isPopUp=true;
					}
				}
				event.updateAfterEvent();
			}
		}
		
		private function onChangeCursor(type:Class,xOffset:Number=0,yOffset:Number=0):void
		{
			if(currentType != type)
			{
				currentType = type;
				CursorManager.removeCursor(CursorManager.currentCursorID);
				if(type != null)
				{
					CursorManager.setCursor(type,2,xOffset,yOffset);
				}
			}
		}
		private function onSaveRestore():void
		{
			var point:Point=new Point();
			theOldPoint=this.localToGlobal(point);
			theOldWidth=this.width;
			theOldHeight=this.height;
		}
		private function onGetRestore():void
		{
			this.x=theOldPoint.x;
			this.y=theOldPoint.y
			this.width=theOldWidth;
			this.height=theOldHeight;			
			this.theStatus = 0;
			setWinIcon(theStatus);
			this.title = titleNormal;
		}
		
		private function winMaxSize():void{
			//设置为最大化状态
			this.x=0;
			this.y=0;
			this.height = this.parent.height;
			this.width = this.parent.width;
			this.theStatus = 1;
			setWinIcon(theStatus);
			this.title = titleNormal;
		}
		
		private function winMinSize():void{
			this.width = 200;
			this.height = 31;
			this.x  = 0;
			this.y = this.parent.height - 30;	
			this.theStatus = 2;
			setWinIcon(theStatus);
			this.title = titleMin;
		}
		
		private function setWinIcon(status:int):void{
			switch(status){
				case 0:
					this.minSizeButton.setStyle("upIcon", IconMinSize);
					this.minSizeButton.setStyle("overIcon", mouseOnIconMinSize);
					this.minSizeButton.setStyle("downIcon", mouseupIconMinSize);
					
					this.maxSizeButton.setStyle("upIcon", IconMaxSize);
					this.maxSizeButton.setStyle("overIcon", mouseOnIconMaxSize);
					this.maxSizeButton.setStyle("downIcon", mouseupIconMaxSize);
					break;
				case 1:
					this.maxSizeButton.setStyle("upIcon", Iconhuany);
					this.maxSizeButton.setStyle("overIcon", IconhuanyOn);
					this.maxSizeButton.setStyle("downIcon", IconhuanyDown);
					
					this.minSizeButton.setStyle("upIcon", IconMinSize);
					this.minSizeButton.setStyle("overIcon", mouseOnIconMinSize);
					this.minSizeButton.setStyle("downIcon", mouseupIconMinSize);
					break;
				case 2:
					this.minSizeButton.setStyle("upIcon", Iconhuany);
					this.minSizeButton.setStyle("overIcon", IconhuanyOn);
					this.minSizeButton.setStyle("downIcon", IconhuanyDown);
					
					this.maxSizeButton.setStyle("upIcon", IconMaxSize);
					this.maxSizeButton.setStyle("overIcon", mouseOnIconMaxSize);
					this.maxSizeButton.setStyle("downIcon", mouseupIconMaxSize);
					break;
			}
			
		}
		
		/**
		 *  The area where the user must click and drag to move the window.
		 *  By default, the move area is the title bar of the TitleWindow container.
		 *
		 *  <p>To drag the TitleWindow container, click and hold the mouse pointer in 
		 *  the title bar area of the window, then move the mouse. 
		 *  Create a custom skin class to change the move area.</p>
		 */
//		[SkinPart(required="false")]
//		public var moveArea:InteractiveObject;
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			addButtonGroup(partName, instance);
//			if(partName == "controlBarGroup"){
//				
//			}
			/*else if (instance == closeButton)
			{
				closeButton.focusEnabled = false;
				closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);   
			}*/
		}
		
		protected function addButtonGroup(partName:String, instance:Object):void
		{
			if (partName == "titleDisplay")
			{
				var titleArea:Group = (instance as DisplayObject).parent as Group;
				if(titleArea != null){
					createButton(titleArea);
//					buttonGroup.verticalAlign = "middle";
					buttonGroup.y = 7;//height = (instance as DisplayObject).height;
				}
			}
		}
		/**
		 *  @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if (partName == "titleDisplay")
				instance.removeEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
//			else if (instance == closeButton)
//				closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
		}
//		private var addedHandlers:Boolean = false;
		private var active:Boolean = false;
		/**
		 *  @private
		 *  Horizontal location where the user pressed the mouse button
		 *  on the moveArea to start dragging, relative to the original
		 *  horizontal location of the TitleWindow.
		 */
		private var offsetX:Number;
		/**
		 *  @private
		 *  Vertical location where the user pressed the mouse button
		 *  on the moveArea to start dragging, relative to the original
		 *  vertical location of the TitleWindow.
		 */
		private var offsetY:Number;
		/**
		 *  @private
		 *  The starting bounds of the TitleWindow before a user
		 *  moves or resizes it.
		 */
		private var startBounds:Rectangle;		

		protected var buttonGroup:HGroup;
		/**
		 *  @private
		 *  Called when the user starts dragging a TitleWindow.
		 *  It begins a move on the TitleWindow if it was popped
		 *  up either by PopUpManager or PopUpAnchor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function moveArea_mouseDownHandler(event:MouseEvent):void
		{
			// Only allow dragging of pop-upped windows
			if (enabled && isPopUp)
			{
				startDragHandler();
//				this.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
				var sbRoot:DisplayObject = systemManager.getSandboxRoot();
				sbRoot.addEventListener(
					MouseEvent.MOUSE_UP, moveArea_mouseUpHandler, true);
				sbRoot.addEventListener(
					SandboxMouseEvent.MOUSE_UP_SOMEWHERE, moveArea_mouseUpHandler);
				return;
				// Calculate the mouse's offset in the window
				// TODO (klin): Investigate globalToLocal method
//				offsetX = event.stageX - x;
//				offsetY = event.stageY - y;
//				
//				var sbRoot:DisplayObject = systemManager.getSandboxRoot();
//				
//				sbRoot.addEventListener(
//					MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler, true);
//				sbRoot.addEventListener(
//					MouseEvent.MOUSE_UP, moveArea_mouseUpHandler, true);
//				sbRoot.addEventListener(
//					SandboxMouseEvent.MOUSE_UP_SOMEWHERE, moveArea_mouseUpHandler)
//				
//				// add the mouse shield so we can drag over untrusted applications.
//				systemManager.deployMouseShields(true);
			}
		}
		
		private function startDragHandler():void{
			var rt:Rectangle = new Rectangle(0, 0, this.parent.width - this.width, this.parent.height - this.height);
			this.startDrag(false, rt);//设置可以拖动的矩形区域
		}
		/**
		 *  @private
		 *  Called when the user drags a TitleWindow.
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function moveArea_mouseMoveHandler(event:MouseEvent):void
		{
			// Check to see if this is the first mouseMove
			if (!startBounds)
			{
				// First dispatch a cancellable "windowMoveStart" event
				startBounds = new Rectangle(x, y, width, height);
				var startEvent:TitleWindowBoundsEvent =
					new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVE_START,
						false, true, startBounds, null);
				dispatchEvent(startEvent);
				
				if (startEvent.isDefaultPrevented())
				{
					// Clean up code if entire move is canceled.
					var sbRoot:DisplayObject = systemManager.getSandboxRoot();
					
					sbRoot.removeEventListener(
						MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler, true);
					sbRoot.removeEventListener(
						MouseEvent.MOUSE_UP, moveArea_mouseUpHandler, true);
					sbRoot.removeEventListener(
						SandboxMouseEvent.MOUSE_UP_SOMEWHERE, moveArea_mouseUpHandler);
					
					systemManager.deployMouseShields(false);
					
					offsetX = NaN;
					offsetY = NaN;
					startBounds = null;
					return;
				}
			}
			
			// Dispatch cancelable "windowMoving" event with before and after bounds.
			var beforeBounds:Rectangle = new Rectangle(x, y, width, height);
			var afterBounds:Rectangle = 
				new Rectangle(Math.round(event.stageX - offsetX),
					Math.round(event.stageY - offsetY),
					width, height);
			
			var e1:TitleWindowBoundsEvent =
				new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVING,
					false, true, beforeBounds, afterBounds);
			dispatchEvent(e1);
			
			// Move only if not canceled.
			if (!(e1.isDefaultPrevented()))
				move(afterBounds.x, afterBounds.y);
			
			event.updateAfterEvent();
		}
		
		/**
		 *  @private
		 *  Called when the user releases the TitleWindow.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function moveArea_mouseUpHandler(event:Event):void
		{
			var sbRoot:DisplayObject = systemManager.getSandboxRoot();
			
			sbRoot.removeEventListener(
				MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler, true);
			sbRoot.removeEventListener(
				MouseEvent.MOUSE_UP, moveArea_mouseUpHandler, true);
			sbRoot.removeEventListener(
				SandboxMouseEvent.MOUSE_UP_SOMEWHERE, moveArea_mouseUpHandler);
			
			systemManager.deployMouseShields(false);
			
			stopDragHandler();//停止拖动
			
			// Check to see that a move actually occurred and that the
			// user did not just click on the moveArea
			if (startBounds)
			{
				// Dispatch "windowMoveEnd" event with the starting bounds and current bounds.
				var endEvent:TitleWindowBoundsEvent =
					new TitleWindowBoundsEvent(TitleWindowBoundsEvent.WINDOW_MOVE_END,
						false, false, startBounds,
						new Rectangle(x, y, width, height));
				dispatchEvent(endEvent);
				startBounds = null;
			}
			
			offsetX = NaN;
			offsetY = NaN;
		}
		
		
	}
}