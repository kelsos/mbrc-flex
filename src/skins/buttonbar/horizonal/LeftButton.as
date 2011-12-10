package skins.buttonbar.horizonal
{
	import assets.buttonbar.horizonal.LeftDown
	import assets.buttonbar.horizonal.LeftUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class LeftButton extends ButtonSkin
	{
		public function LeftButton()
		{
			super();

			upBorderSkin = assets.buttonbar.horizonal.LeftUp;
			downBorderSkin = assets.buttonbar.horizonal.LeftDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
	}
}