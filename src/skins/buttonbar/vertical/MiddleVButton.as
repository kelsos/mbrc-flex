package skins.buttonbar.vertical
{
	import assets.buttonbar.vertical.MiddleButtonDown;
	import assets.buttonbar.vertical.MiddleButtonUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class MiddleVButton extends ButtonSkin
	{
		public function MiddleVButton()
		{
			super();
			upBorderSkin = assets.buttonbar.vertical.MiddleButtonUp;
			downBorderSkin = assets.buttonbar.vertical.MiddleButtonDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
	}
}