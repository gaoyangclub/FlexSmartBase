package com.best.web.gyorg.library.util.dashline
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	public class HoriDashLine2 extends UIComponent {
	
		

 
		
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
		super.updateDisplayList(unscaledWidth,unscaledHeight);
		myInit(0xbcbcbc,1,0,0,unscaledWidth,0,1,2,3);
	}
		
//		override protected function initializationComplete():void{
//			super.initializationComplete();
//			var color:uint=getStyle("color");
//			myInit(1,color,1,0,0,unscaledWidth,0,1,1,2);
//		}
		
		/*myInit()函数参数注解：
		* 1、shuliang    虚线的条数
		* 2、lineColor   虚线的颜色
		* 3、lineAlpha   虚线的alpha值
		* 4、fromX       虚线起始点的x轴的值
		* 5、fromY       虚线起始点的y轴的值
		* 6、toX         虚线末点的x轴的值
		* 7、toY         虚线末点的y轴的值
		* 8、pointWidth 单个点的厚度
		* 9、pointLength 单个点的长度
		* 10、twoPointDistance 两个点之间的间隔
		* 
		*/
		private function myInit( lineColor:uint, lineAlpha:Number, fromX:Number, fromY:Number, toX:Number, toY:Number, pointWidth:Number, pointLength:Number, twoPointDistance:Number):void{
			drawDashed(this.graphics, lineColor, lineAlpha, new Point(fromX, fromY), new Point(toX, toY), pointWidth, pointLength, twoPointDistance);
		}
		
		private function drawDashed(graphics:Graphics, lineColor:uint, lineAlpha:Number, p1:Point, p2:Point, pointWidth:Number, pointLength:Number, twoPointDistance:Number):void{
			//graphics.clear();
			
			//graphics.lineStyle(pointWidth, lineColor, lineAlpha,true);
			graphics.beginFill(lineColor,lineAlpha);
			var max:Number = Point.distance(p1, p2);
			var dis:Number = 0;
			var p3:Point;
			while(dis < max){
				p3 = Point.interpolate(p2, p1, dis / max);
				dis += pointLength;
				if(dis > max){
					dis = max;
				}
				
				graphics.drawRect(p3.x,p3.y,pointLength,1);
				
				dis += twoPointDistance;
			}
			graphics.endFill();
		}
		
	}
}