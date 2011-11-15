package skins.buttonbar.vertical
{
	import skins.assets.buttonbar.vertical.TopButtonDown;
	import skins.assets.buttonbar.vertical.TopButtonUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class TopButton extends ButtonSkin
	{
		public function TopButton()
		{
			super();
			upBorderSkin = skins.assets.buttonbar.vertical.TopButtonUp;
			downBorderSkin = skins.assets.buttonbar.vertical.TopButtonDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
		
	}
}