package Data
{
	public class TrackInfo
	{
		private var _artist:String;
		private var _title:String;
		private var _album:String;
		private var _year:String;
		public function TrackInfo()
		{
			
		}
		
		public function get artist():String
		{
			return _artist;
		}

		public function set artist(value:String):void
		{
			_artist = value;
		}

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get album():String
		{
			return _album;
		}

		public function set album(value:String):void
		{
			_album = value;
		}

		public function get year():String
		{
			return _year;
		}

		public function set year(value:String):void
		{
			_year = value;
		}


	}
}