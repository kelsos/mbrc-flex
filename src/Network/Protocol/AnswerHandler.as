package Network.Protocol
{
	import Data.TrackInfo;
	
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.utils.Base64Decoder;
	
	/*Events dispatched by the answerHandler */
	[Event(name="statusPlaying", type="flash.events.Event")]
	[Event(name="statusPaused", type="flash.events.Event")]
	[Event(name="statusStopped", type="flash.events.Event")]
	[Event(name="volumeChanged", type="flash.events.Event")]
	[Event(name="SendSongData", type="flash.events.Event")]
	[Event(name="newArtistDataAvailable", type="flash.events.Event")]
	[Event(name="albumCoverAvailable", type="flash.events.Event")]
	
	//dispatchEvent(new Event('socketData'));
	public class AnswerHandler extends EventDispatcher
	{
		private var volumeData:int;
		public var trackInfo:TrackInfo;
		private var imageDataFlag:Boolean;
		private var imageData:String;
		public function AnswerHandler()
		{
			trackInfo = new TrackInfo();
		}
		/** Handles the server answers and takes actions depending on the type of the answer.
		 * It is part of the application protocol. 
		 * 
		 * @param serverAnswer
		 * 
		 */
		public function serverAnswerHandler(serverAnswer:XML):void{
			/*Handles the playstate replated answers */
			if (serverAnswer.name()=="playState")
			{
				switch(serverAnswer.text().toString()){
					case "PLAYING":
						dispatchEvent(new Event('statusPlaying'));
						break;	
					case "PAUSEDD":
						dispatchEvent(new Event('statusPaused'));
						break;
					case "STOPPED":
						dispatchEvent(new Event('statusStopped'));
						break;
					default:
						break;
				}
			}
			/*Handles the volume related answers. The answers include the current volume.*/
			if(serverAnswer.name()=="currentVolume"||serverAnswer.name()=="increasedVolume"||serverAnswer.name()=="decreasedVolume")
				volumeAnswerHandler(serverAnswer.text().toString());
			/*Handles the answer to the song change Command. If the answer is true requests the song data. */
			if(serverAnswer.name()=="songChanged")
			{
				if(serverAnswer.text().toString()=="True")
				{
					var songDataRequestDelay:Timer = new Timer(500,1);
					songDataRequestDelay.addEventListener(TimerEvent.TIMER_COMPLETE,dispatchSendSongData);
					songDataRequestDelay.start();
				}
			}
			if(serverAnswer.name()=="songInfo")
			{
				var count:int=0;
				var tagArray:Array = new Array(4);
				for each (var tag:XML in serverAnswer.children())
				{
					tagArray[count++]=tag.text().toString();
				}
				 artistDataHandler(tagArray);
			}
			/*Handles the image data*/
			if(serverAnswer.name()=="image")
			{
				imageData=serverAnswer.text().toString();
				dispatchEvent(new Event("albumCoverAvailable"));
			}
		}
				
		protected function dispatchSendSongData(event:TimerEvent):void
		{
			dispatchEvent(new Event("SendSongData"));
		}
		public function getVolume():int
		{
			return volumeData;
		}
		private function volumeAnswerHandler(volume:String):void{
			volumeData = (parseInt(volume)*10);
			dispatchEvent(new Event("volumeChanged"));
		}
		private function artistDataHandler(artistData:Array):void{
			
			var i:int = 0;
			trackInfo.artist = artistData[i++];
			trackInfo.title = artistData[i++];
			trackInfo.album = artistData[i++];
			trackInfo.year = artistData[i++];
			dispatchEvent(new Event("newArtistDataAvailable"));
		}
		public function coverDataHandler():ByteArray
		{
			var base64Dec:Base64Decoder;
			
			var imageByteArray:ByteArray;
			
			base64Dec = new Base64Decoder();
			base64Dec.decode(imageData);
			
			return base64Dec.toByteArray();
		}
	}
}