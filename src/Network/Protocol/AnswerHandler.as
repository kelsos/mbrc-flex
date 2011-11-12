package Network.Protocol
{
	import Data.TrackInfo;
	
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.utils.Base64Decoder;
	
	/*Events dispatched by the answerHandler */
	[Event(name="statusPlaying", type="flash.events.Event")]
	[Event(name="statusPaused", type="flash.events.Event")]
	[Event(name="statusStopped", type="flash.events.Event")]
	[Event(name="volumeChanged", type="flash.events.Event")]
	[Event(name="SendSongData", type="flash.events.Event")]
	[Event(name="newArtistDataAvailable", type="flash.events.Event")]
	[Event(name="albumCoverAvailable", type="flash.events.Event")]
	[Event(name="ShuffleStatusChanged", type="flash.events.Event")]
	[Event(name="playlistDataAvailable", type="flash.events.Event")]
	[Event(name="MuteStatusChanged", type="flash.events.Event")]
	[Event(name="repeatStatusChanged", type="flash.events.Event")]
	
	//dispatchEvent(new Event('socketData'));
	public class AnswerHandler extends EventDispatcher
	{
		public var trackInfo:TrackInfo;
		/*private variables*/
		private var volumeData:Number;
		private var imageDataFlag:Boolean;
		private var imageData:ByteArray;
		private var shuffleStatus:Boolean;
		private var muteStatus:Boolean;
		private var repeatStatus:Boolean;
		private var trackList:ArrayList; 
		private static var _instance:AnswerHandler;
		
		public function AnswerHandler(enforcer:SingletonEnforcer)
		{
			if(enforcer==null)
			{
				throw new Error("No new Instances Of AnswerHandler can be created");
			}
			trackInfo = new TrackInfo();
		}
		public static function getInstance():AnswerHandler
		{
			if (_instance==null)
			{
				_instance = new AnswerHandler(new SingletonEnforcer());
			}
			return _instance;
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
					case "playing":
						dispatchEvent(new Event('statusPlaying'));
						break;	
					case "paused":
						dispatchEvent(new Event('statusPaused'));
						break;
					case "stopped":
						dispatchEvent(new Event('statusStopped'));
						break;
					default:
						break;
				}
			}
			/*Handles the volume related answers. The answers include the current volume.*/
			if(serverAnswer.name()=="volume")
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
			/*Handles the SongInfo*/
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
			if(serverAnswer.name()=="songCover")
			{
				imageData=coverDataHandler(serverAnswer.text().toString());
				dispatchEvent(new Event("albumCoverAvailable"));
			}
			/*Handles the shuffle answer*/
			if(serverAnswer.name()=="shuffle")
			{
				switch(serverAnswer.text().toString()){
					case "True":
						shuffleStatus=true;
						break;
					case "False":
						shuffleStatus=false;
						break;
				}
				dispatchEvent(new Event("ShuffleStatusChanged"));
			}
			/*Handles the mute data change*/
			if(serverAnswer.name()=="mute")
			{
				switch(serverAnswer.text().toString()){
					case "True":
						muteStatus=true;
						break;
					case "False":
						muteStatus=false;
						break;
				}	
				dispatchEvent(new Event("MuteStatusChanged"));
			}
			/*Handles the repeat answer data*/
			if(serverAnswer.name()=="repeat")
			{
				switch(serverAnswer.text().toString()){
					case "All":
						repeatStatus=true;
						break;
					case "None":
						repeatStatus=false;
						break;
				}
				dispatchEvent(new Event("repeatStatusChanged"));
			}
			/*Handles playlist data*/
			if(serverAnswer.name()=="playlist")
			{
				trackList = new ArrayList();
				for each (var xtag:XML in serverAnswer.children())
				{
					trackList.addItem(xtag.text().toString());
				}
				dispatchEvent(new Event("playlistDataAvailable"));
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
			volumeData = parseInt(volume);
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
		private function coverDataHandler(image:String):ByteArray
		{
			var base64Dec:Base64Decoder;
			
			var imageByteArray:ByteArray;
			
			base64Dec = new Base64Decoder();
			base64Dec.decode(image);
			
			return base64Dec.toByteArray();
		}
		public function getCover():ByteArray
		{
			return imageData;
		}
		public function getShuffleStatus():Boolean
		{
			return shuffleStatus;	
		}
		public function getPlaylistData():ArrayList
		{
			return trackList;
		}
		public function getMuteStatus():Boolean
		{
			return muteStatus;
		}
		public function getRepeatStatus():Boolean
		{
			return repeatStatus;
		}
	}
}
class SingletonEnforcer {}