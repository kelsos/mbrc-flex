package skins.buttonbar.horizonal
{
	import skins.assets.buttonbar.horizonal.RightDown;
	import skins.assets.buttonbar.horizonal.RightUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class RightButton extends ButtonSkin
	{
		public function RightButton()
		{
			super();
			upBorderSkin = skins.assets.buttonbar.horizonal.RightUp;
			downBorderSkin = skins.assets.buttonbar.horizonal.RightDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
		
		}
	}
}