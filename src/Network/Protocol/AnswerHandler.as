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
		public function serverAnswerHandler(serverAnswer:String):void{
			
			var socketAnswerData:String = serverAnswer;
			var AnswerArray:Array = serverAnswer.split("\r\n");
			
			var volUpPattern:RegExp = /260.VOL.UP:([01]?[0-9])/gm;
			var volDownPattern:RegExp =/270.VOL.DOWN:([01]?[0-9])/gm;
			var volGetPattern:RegExp = /250.VOL.CUR:([01]?[0-9])/gm;
			var playStatePattern:RegExp = /230.PLAY.STATE:([A-Z]{7})/gm;
			var removeOK:RegExp = /220.PLAYPAUSE.OK/gm;
			var checkSongChange:RegExp = /300.SONGCHANGE:(.*)/gm;
			var getSongData:RegExp = /400.NOW.PLAYING\n(.*)/gsm;
			
			var imageDataHeader:RegExp = /410.IMAGE.COVER/gm;
			var imageDataFooter:RegExp = /\n411.IMAGE.COVER.END/gm;
			
			var i:int;
			for (i=0; i<AnswerArray.length; i++)
			{
				/*Handles the volume related answers. The answers include the current volume.*/
				if(volUpPattern.test(AnswerArray[i]))
					volumeAnswerHandler(AnswerArray[i].replace(volUpPattern,'$1'));
				if(volDownPattern.test(AnswerArray[i]))
					volumeAnswerHandler(AnswerArray[i].replace(volDownPattern,'$1'));
				if(volGetPattern.test(AnswerArray[i]))
					volumeAnswerHandler(AnswerArray[i].replace(volGetPattern,'$1'));
				/*Handles the Currently playing track information*/
				if(getSongData.test(AnswerArray[i])){
					var SongData:String = AnswerArray[i].replace(getSongData,'$1');
					var songArray:Array = SongData.split('\n');
					artistDataHandler(songArray);
				}
				/*Handles the answer to the song change Command. If the answer is true requests the song data. */
				if (checkSongChange.test(AnswerArray[i])){
					var answer:String = AnswerArray[i].replace(checkSongChange,'$1');
					if (answer=="True")
					{
						/*Due to the way the server answers if the event is dispatched immediately it sends the previous track data.
						For this reason a timer is added to delay the data request.*/
						var songDataRequestDelay:Timer = new Timer(500,1);
						songDataRequestDelay.addEventListener(TimerEvent.TIMER_COMPLETE,dispatchSendSongData);
						songDataRequestDelay.start();		
					}
				}
				/*Handles the playstate replated answers */
				if(playStatePattern.test(AnswerArray[i])){
					var playState:String = AnswerArray[i].replace(playStatePattern,'$1');
					playState=playState.replace(removeOK,"");
					switch(playState){
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
				if(imageDataHeader.test(AnswerArray[i])){
					imageDataFlag=true;
					imageData=null;
				}
				if(imageDataFlag)
				{
					if(imageDataFooter.test(AnswerArray[i]))
					{
						if(imageData==null)
						{
							imageData=AnswerArray[i];
						}else{
							imageData+=AnswerArray[i];
						}
						imageDataFlag=false;
					}
					else
					{
						if(imageData==null)
						{
							imageData=AnswerArray[i];
						}
						else
						{
							imageData+=AnswerArray[i];
						}
						break;
					}

					imageData= imageData.replace(imageDataFooter,"");
					imageData= imageData.replace(imageDataHeader,"");
					dispatchEvent(new Event("albumCoverAvailable"));
				}
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