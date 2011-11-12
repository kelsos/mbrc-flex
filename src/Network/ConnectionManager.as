// ActionScript file
package Network {
	import Data.TrackInfo;
	
	import Network.Protocol.AnswerHandler;
	
	import flash.events.*;
	import flash.net.XMLSocket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.xml.XMLNode;
	
	import flashx.textLayout.formats.Float;
	
	import mx.collections.ArrayList;
	
	import spark.components.Image;
	import spark.managers.PersistenceManager;
	
	public class ConnectionManager extends EventDispatcher {
		private var xmlSocket:XMLSocket;
		private var _serverAnswer:String;
		private var answerHandle:AnswerHandler;
		private static var _instance:ConnectionManager;
		private var dataPoller:Timer;
		private var p:PersistenceManager;

		public function ConnectionManager(enforcer:SingletonEnforcer){
			if (enforcer==null)
			{
				throw new Error("No new Instances Of Connection Manager can be created");
			}
			else
			{
			xmlSocket = new XMLSocket();
			_serverAnswer="";
			configureListeners(xmlSocket);
			dataPoller = new Timer(3000,0);
			dataPoller.addEventListener(TimerEvent.TIMER,dataPollerTickHandler);
			dataPoller.start();
			p = new PersistenceManager();
			connect();
			}
		}
		
		protected function dataPollerTickHandler(event:TimerEvent):void
		{
			connect();
			requestPlayState();
			requestSongChangedStatus();
			requestVolume();
			requestMuteState();
			requestShuffleState();
			requestRepeatState();
		}
		
		public static function getInstance():ConnectionManager
		{
			if (_instance==null)
			{
				_instance = new ConnectionManager(new SingletonEnforcer());
			}
			return _instance;
		}

		public function connect():void
		{
			if (!xmlSocket.connected)
				xmlSocket.connect(p.getProperty("serverAddress").toString(),parseInt(p.getProperty("serverPort").toString()));
		}
		private function send(data:Object):void 
		{
			xmlSocket.send(data);
		}
		
		public function disconnect():void 
		{
			xmlSocket.close();
		}
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CLOSE, closeHandler);
			dispatcher.addEventListener(Event.CONNECT, connectHandler);
			dispatcher.addEventListener(DataEvent.DATA, dataHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			/*Protocol handlers-middleware*/ 
			AnswerHandler.getInstance().addEventListener("SendSongData",requestSongDataHandler)
		}
		protected function requestSongDataHandler(event:Event):void
		{
			requestSongData();
			requestSongCover();
		}
		private function closeHandler(event:Event):void 
		{
			trace("closeHandler: " + event);
		}
		private function connectHandler(event:Event):void 
		{
			trace("connectHandler: " + event); 
		}
		private function dataHandler(event:DataEvent):void 
		{
			var xml:XML= new XML(event.data);
			AnswerHandler.getInstance().serverAnswerHandler(xml);
		}
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void 
		{
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		public function requestPlayPause():void
		{
			var playPauseXml:XML=new XML("<playPause/>");
			send(playPauseXml);
			send("\r\n");
		}
		public function requestNextTrack():void
		{
			var nextXml:XML=new XML("<next/>");
			send(nextXml);
			send("\r\n");
		}
		public function requestPreviousTrack():void
		{
			var previousXml:XML=new XML("<previous/>");
			send(previousXml);
			send("\r\n");
		}
		public function requestPlayState():void
		{
			var playStateXml:XML = new XML("<playState/>");
			send(playStateXml);
			send("\r\n");
		}
		public function requestVolume(vol:Number=-1):void
		{
			var volumeXml:XML;
			if ((vol>=0)&&(vol<=10))
			{
			 volumeXml = new XML("<volume>"+vol+"</volume>");
			}
			else
			{
				volumeXml=new XML("<volume/>")	
			}
			send(volumeXml);
			send("\r\n");
		}
		public function requestSongChangedStatus():void
		{
			var songChangedXml:XML=new XML("<songChanged/>");
			send(songChangedXml);
			send("\r\n");
		}
		public function requestSongData():void
		{
			var songInfoXml:XML=new XML("<songInfo/>");
			send(songInfoXml);
			send("\r\n");
		}
		public function requestSongCover():void
		{
			var songCoverXml:XML = new XML("<songCover/>");
			send(songCoverXml);
			send("\r\n");
		}
		public function requestPlaybackTermination():void
		{
			var stopPlaybackXml:XML = new XML("<stopPlayback/>");
			send(stopPlaybackXml);
			send("\r\n");
		}
		public function requestShuffleState(action:String="state"):void
		{
			var shuffleXml:XML = new XML("<shuffle>"+action+"</shuffle>");
			send(shuffleXml);
			send("\r\n");
		}
		public function requestMuteState(action:String="state"):void
		{
			var muteXml:XML = new XML("<mute>"+action+"</mute>");
			send(muteXml);
			send("\r\n");
		}
		public function requestRepeatState(action:String="state"):void
		{
			var repeatXml:XML = new XML("<repeat>"+action+"</repeat>");
			send(repeatXml);
			send("\r\n");
		}
		public function requestPlaylist():void
		{
			var playlistXml:XML = new XML("<playlist/>");
			send(playlistXml);
			send("\r\n");
		}
	}
}
class SingletonEnforcer {}