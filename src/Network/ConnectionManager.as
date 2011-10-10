// ActionScript file
package Network {
	import Network.Protocol.AnswerHandler;
	
	import flash.events.*;
	import flash.net.Socket;
	
	[Event(name="statusPlaying", type="flash.events.Event")]
	[Event(name="statusPaused", type="flash.events.Event")]
	[Event(name="statusStopped", type="flash.events.Event")]
	[Event(name="volumeChanged", type="flash.events.Event")]
	
	public class ConnectionManager extends EventDispatcher {
		private var socket:Socket;
		private var _serverAnswer:String="";
		private var answerHandle:AnswerHandler;

		public function ConnectionAchieved():Boolean{
			if (socket.connected)
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
			socket = new Socket();
			answerHandle = new AnswerHandler();
			configureListeners(socket);
		}
		public function connect(hostname:String,port:uint):void{
			if (!socket.connected)
				socket.connect(hostname,port);
		}
		public function send(data:String):void {
			socket.writeUTFBytes(data);
		}
		
		public function disconnect():void {
			socket.close();
		}
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CLOSE, closeHandler);
			dispatcher.addEventListener(Event.CONNECT, connectHandler);
			dispatcher.addEventListener(DataEvent.DATA, dataHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			answerHandle.addEventListener("statusPlaying",statusPlayingHandler);
			answerHandle.addEventListener("statusPaused",statusPausedHandler);
			answerHandle.addEventListener("statusStopped",statusStoppedHandler);
			answerHandle.addEventListener("volumeChanged",volumeChangedHandler);
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
		private function onSocketData(event:ProgressEvent):void
		{
			while(socket.bytesAvailable){
				if(_serverAnswer==null){
					_serverAnswer = socket.readUTFBytes(socket.bytesAvailable);
				}else{
				_serverAnswer += socket.readUTFBytes(socket.bytesAvailable);
				}
			}
			answerHandle.serverAnswerHandler(_serverAnswer);
			AnswerClear();
		}
		private function closeHandler(event:Event):void {
			trace("closeHandler: " + event);
		}
		
		private function connectHandler(event:Event):void {
			trace("connectHandler: " + event);
		}
		
		private function dataHandler(event:DataEvent):void {
			trace("dataHandler: " + event);
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
		{send("PLAYPAUSE\r\n");}
		public function requestNextTrack():void
		{send("NEXT\r\n");}
		public function requestPreviousTrack():void
		{send("PREVIOUS\r\n");}
		public function requestPlayState():void
		{send("GETPLAYSTATE\r\n");}
		public function requestVolume():void
		{send("GETVOL\r\n");}
		public function requestVolumeIncrease():void
		{send("INCREASEVOL\r\n");}
		public function requestVolumeDecrease():void
		{send("DECREASEVOL\r\n");}
		public function requestSongChangedStatus():void
		{send("ISSONGCHANGED\r\n");}
		public function requestSongData():void
		{send("SENDSONGDATA\r\n");}
		public function requestSongCover():void
		{send("SENDSONGCOVER\r\n");}
		public function getVolume():int
		{
			return answerHandle.getVolume();
		}
	}
}