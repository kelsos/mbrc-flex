package skins.buttonbar.horizonal
{
	import skins.assets.buttonbar.horizonal.MiddleUp;
	import skins.assets.buttonbar.horizonal.MiddleDown;

	import spark.skins.mobile.ButtonSkin;
	
	public class MiddleHButton extends ButtonSkin
	{
		public function MiddleHButton()
		{
			super();
			upBorderSkin = skins.assets.buttonbar.horizonal.MiddleUp;
			downBorderSkin = skins.assets.buttonbar.horizonal.MiddleDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
	}
}