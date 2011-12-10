package skins.buttonbar.vertical
{
	import assets.buttonbar.vertical.BottomButtonDown;
	import assets.buttonbar.vertical.BottomButtonUp;
	
	import spark.skins.mobile.ButtonSkin;
	
	public class BottomButton extends ButtonSkin
	{
		public function BottomButton()
		{
			super();
			upBorderSkin = assets.buttonbar.vertical.BottomButtonUp;
			downBorderSkin = assets.buttonbar.vertical.BottomButtonDown;
			measuredDefaultHeight = 128;
			measuredDefaultWidth = 128;
		}
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
		}
	}
}