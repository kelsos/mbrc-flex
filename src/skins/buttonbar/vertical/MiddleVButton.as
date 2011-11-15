package skins.buttonbar.vertical
{
	import skins.assets.buttonbar.vertical.MiddleButtonDown;
	import skins.assets.buttonbar.vertical.MiddleButtonUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class MiddleVButton extends ButtonSkin
	{
		public function MiddleVButton()
		{
			super();
			upBorderSkin = skins.assets.buttonbar.vertical.MiddleButtonUp;
			downBorderSkin = skins.assets.buttonbar.vertical.MiddleButtonDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
	}
}