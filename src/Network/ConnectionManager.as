// ActionScript file
package Network {
	import Data.TrackInfo;
	
	import Network.Protocol.AnswerHandler;
	
	import flash.events.*;
	import flash.net.XMLSocket;
	import flash.utils.ByteArray;
	import flash.xml.XMLNode;
	
	[Event(name="statusPlaying", type="flash.events.Event")]
	[Event(name="statusPaused", type="flash.events.Event")]
	[Event(name="statusStopped", type="flash.events.Event")]
	[Event(name="volumeChanged", type="flash.events.Event")]
	[Event(name="newArtistDataAvailable", type="flash.events.Event")]
	[Event(name="albumCoverAvailable", type="flash.events.Event")]
	
	public class ConnectionManager extends EventDispatcher {
		private var xmlSocket:XMLSocket;
		private var _serverAnswer:String="";
		private var answerHandle:AnswerHandler;

		public function ConnectionAchieved():Boolean{
			if (xmlSocket.connected)
				return true;
			return false;
		}
		public function ServerAnswer():String{
			return _serverAnswer;
		}
		public function AnswerClear():void{
			_serverAnswer="";
		}
		
		public function ConnectionManager(){
			xmlSocket = new XMLSocket();
			answerHandle = new AnswerHandler();
			configureListeners(xmlSocket);
		}
		public function connect(hostname:String,port:uint):void{
			if (!xmlSocket.connected)
				xmlSocket.connect(hostname,port);
		}
		public function send(data:Object):void {
			xmlSocket.send(data);
		}
		
		public function disconnect():void {
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
			answerHandle.addEventListener("statusPlaying",statusPlayingHandler);
			answerHandle.addEventListener("statusPaused",statusPausedHandler);
			answerHandle.addEventListener("statusStopped",statusStoppedHandler);
			answerHandle.addEventListener("volumeChanged",volumeChangedHandler);
			answerHandle.addEventListener("SendSongData",requestSongDataHandler);
			answerHandle.addEventListener("newArtistDataAvailable",newArtistDataHandler);
			answerHandle.addEventListener("albumCoverAvailable",albumCoverDataHandler);
		}
		
		protected function albumCoverDataHandler(event:Event):void
		{
			dispatchEvent(new Event("albumCoverAvailable"));
			
		}
		
		protected function newArtistDataHandler(event:Event):void
		{
			dispatchEvent(new Event("newArtistDataAvailable"));
		}
		
		protected function requestSongDataHandler(event:Event):void
		{
			requestSongData();	
		}
		
		protected function volumeChangedHandler(event:Event):void
		{
			dispatchEvent(new Event("volumeChanged"));
		}
		
		protected function statusStoppedHandler(event:Event):void
		{
			dispatchEvent(new Event("statusStopped"));
		}
		
		protected function statusPausedHandler(event:Event):void
		{
			dispatchEvent(new Event("statusPaused"));
		}
		private function statusPlayingHandler(event:Event):void
		{
			dispatchEvent(new Event("statusPlaying"));
		}
		private function closeHandler(event:Event):void {
			trace("closeHandler: " + event);
		}
		
		private function connectHandler(event:Event):void {
			trace("connectHandler: " + event); 
		}
		
		private function dataHandler(event:DataEvent):void {
			var xml:XML= new XML(event.data);
			answerHandle.serverAnswerHandler(xml);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
		public function requestPlayPause():void
		{send("PLAYPAUSE\0");
			send("\r\n");}
		public function requestNextTrack():void
		{send("NEXT\0");send("\r\n");}
		public function requestPreviousTrack():void
		{send("PREVIOUS\0");send("\r\n");}
		public function requestPlayState():void
		{send("GETPLAYSTATE\0");send("\r\n");}
		public function requestVolume():void
		{send("GETVOL\0");send("\r\n");}
		public function requestVolumeIncrease():void
		{send("INCREASEVOL\0");send("\r\n");}
		public function requestVolumeDecrease():void
		{send("DECREASEVOL\0");send("\r\n");}
		public function requestSongChangedStatus():void
		{send("ISSONGCHANGED\0");send("\r\n");}
		public function requestSongData():void
		{send("SENDSONGDATA\0");send("\r\n");}
		public function requestSongCover():void
		{send("SENDSONGCOVER\0");send("\r\n");}
		public function getVolume():int
		{
			return answerHandle.getVolume();
		}
		public function getTrackInfo():TrackInfo
		{
			return answerHandle.trackInfo;
		}
		public function getAlbumCover():ByteArray
		{
			return answerHandle.coverDataHandler();
		}
	}
}