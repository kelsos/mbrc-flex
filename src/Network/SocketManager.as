// ActionScript file
package Network {
	import flash.events.*;
	import flash.net.Socket;
	
	[Event(name="socketData", type="flash.events.Event")]
	public class SocketManager extends EventDispatcher {
		private var socket:Socket;
		private var _serverAnswer:String="";
		
		public function ServerAnswer():String{
			return _serverAnswer;
		}
		public function AnswerClear():void{
			_serverAnswer="";
		}
		
		public function SocketManager(){
			socket = new Socket();
			configureListeners(socket);
		}
		public function connect(hostname:String,port:uint):void{
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
			dispatchEvent(new Event('socketData'));
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
	}
}