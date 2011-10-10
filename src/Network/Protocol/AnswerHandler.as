package Network.Protocol
{
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	/*Events dispatched by the answerHandler */
	[Event(name="statusPlaying", type="flash.events.Event")]
	[Event(name="statusPaused", type="flash.events.Event")]
	[Event(name="statusStopped", type="flash.events.Event")]
	[Event(name="volumeChanged", type="flash.events.Event")]
	//dispatchEvent(new Event('socketData'));
	public class AnswerHandler extends EventDispatcher
	{
		private var volumeData:int;
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
			var getSongData:RegExp = /400.NOW.PLAYING(.*)/gsm;
			var getImageData:RegExp = /410.IMAGE.COVER\n(.*)\n411.IMAGE.COVER.ENDr\n/gm;
			var i:int;
			for (i=0; i<AnswerArray.length-1; i++)
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
						//socketMan.send("SENDSONGDATA\r\n");
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
				if(!getImageData.test(AnswerArray[i])){
					//connectionLogWindow.text+=serverAnswer;
				}
			}
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

			//var i:int = 0;
			//artistName.text = songArray[++i];
			//artistTitle.text = songArray[++i];
			//artistAlbum.text = songArray[++i];
			//albumYear.text = songArray[++i];
		}
		private function coverDataHandler(imageData:String):void
		{
			var base64Dec:Base64Decoder;

				var imageByteArray:ByteArray;
				
				base64Dec = new Base64Decoder();
				base64Dec.decode(imageData);
				
				imageByteArray = base64Dec.toByteArray();
				//coverImage.source =  imageByteArray;

		}
	}
}