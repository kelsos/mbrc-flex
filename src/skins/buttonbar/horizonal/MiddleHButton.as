package skins.buttonbar.horizonal
{
	import assets.buttonbar.horizonal.MiddleUp;
	import assets.buttonbar.horizonal.MiddleDown;

	import spark.skins.mobile.ButtonSkin;
	
	public class MiddleHButton extends ButtonSkin
	{
		public function MiddleHButton()
		{
			super();
			upBorderSkin = assets.buttonbar.horizonal.MiddleUp;
			downBorderSkin = assets.buttonbar.horizonal.MiddleDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
	}
}