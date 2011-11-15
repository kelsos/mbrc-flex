package skins.buttonbar.horizonal
{
	import skins.assets.buttonbar.horizonal.LeftDown
	import skins.assets.buttonbar.horizonal.LeftUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class LeftButton extends ButtonSkin
	{
		public function LeftButton()
		{
			super();

			upBorderSkin = skins.assets.buttonbar.horizonal.LeftUp;
			downBorderSkin = skins.assets.buttonbar.horizonal.LeftDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		}
	}
}