package skins.buttonbar.vertical
{
	import skins.assets.buttonbar.vertical.BottomButtonDown;
	import skins.assets.buttonbar.vertical.BottomButtonUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class BottomButton extends ButtonSkin
	{
		public function BottomButton()
		{
			super();
			upBorderSkin = skins.assets.buttonbar.vertical.BottomButtonUp;
			downBorderSkin = skins.assets.buttonbar.vertical.BottomButtonDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
		}
	}
}