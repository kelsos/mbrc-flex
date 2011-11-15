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
		private var _volumeData:Number;
		private var _imageDataFlag:Boolean;
		private var _imageData:ByteArray;
		private var _shuffleStatus:Boolean;
		private var _muteStatus:Boolean;
		private var _repeatStatus:Boolean;
		private var _trackList:ArrayList; 
		private static var _instance:AnswerHandler;
		
		/**
		 * AnswerHandler's constructor. 
		 * @param enforcer
		 * 
		 */
		public function AnswerHandler(enforcer:SingletonEnforcer)
		{
			if(enforcer==null)
			{
				throw new Error("No new Instances Of AnswerHandler can be created");
			}
			trackInfo = new TrackInfo();
		}
		/**
		 * AnswerHandler's public entry point. Through getInstance you can access the Handler's functions
		 * and properties.
		 * @return 
		 * 
		 */
		public static function getInstance():AnswerHandler
		{
			if (_instance==null)
			{
				_instance = new AnswerHandler(new SingletonEnforcer());
			}
			return _instance;
		}
		/** 
		 * The answerProcessor function gets the server's answer XML and depending on the XML tag's name
		 * it forwards the data to the function responsible. Then it dispatches an event to the listener
		 * to inform for data availability. 
		 * 
		 * @param serverAnswer
		 * 
		 */
		public function answerProcessor(serverAnswer:XML):void{
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
				this.trackInfo.fromXml(serverAnswer);
				dispatchEvent(new Event("newArtistDataAvailable"));
			}
			/*Handles the image data*/
			if(serverAnswer.name()=="songCover")
			{
				_imageData=coverDataHandler(serverAnswer.text().toString());
				dispatchEvent(new Event("albumCoverAvailable"));
			}
			/*Handles the shuffle answer*/
			if(serverAnswer.name()=="shuffle")
			{
				switch(serverAnswer.text().toString()){
					case "True":
						_shuffleStatus=true;
						break;
					case "False":
						_shuffleStatus=false;
						break;
				}
				dispatchEvent(new Event("ShuffleStatusChanged"));
			}
			/*Handles the mute data change*/
			if(serverAnswer.name()=="mute")
			{
				switch(serverAnswer.text().toString()){
					case "True":
						_muteStatus=true;
						break;
					case "False":
						_muteStatus=false;
						break;
				}	
				dispatchEvent(new Event("MuteStatusChanged"));
			}
			/*Handles the repeat answer data*/
			if(serverAnswer.name()=="repeat")
			{
				switch(serverAnswer.text().toString()){
					case "All":
						_repeatStatus=true;
						break;
					case "None":
						_repeatStatus=false;
						break;
				}
				dispatchEvent(new Event("repeatStatusChanged"));
			}
			/*Handles playlist data*/
			if(serverAnswer.name()=="playlist")
			{
				_trackList = new ArrayList();
				for each (var xtag:XML in serverAnswer.children())
				{
					_trackList.addItem(xtag.text().toString());
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
			return _volumeData;
		}
		private function volumeAnswerHandler(volume:String):void{
			_volumeData = parseInt(volume);
			dispatchEvent(new Event("volumeChanged"));
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
			return _imageData;
		}
		public function getShuffleStatus():Boolean
		{
			return _shuffleStatus;	
		}
		public function getPlaylistData():ArrayList
		{
			return _trackList;
		}
		public function getMuteStatus():Boolean
		{
			return _muteStatus;
		}
		public function getRepeatStatus():Boolean
		{
			return _repeatStatus;
		}
	}
}
class SingletonEnforcer {}