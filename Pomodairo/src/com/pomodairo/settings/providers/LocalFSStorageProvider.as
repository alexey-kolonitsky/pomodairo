/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings.providers {
	import com.pomodairo.ConfigProperty;

	import flash.data.EncryptedLocalStore;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	import mx.utils.StringUtil;

	/**
	 * Local file-system storage
	 */
	public class LocalFSStorageProvider extends EventDispatcher implements IProvider {

		[Embed(source="/assets/settings.properties",mimeType="application/octet-stream")]
		private var settingsProperties:Class;

		private var _provider:Vector.<ConfigProperty>;

		public function isReadonly():Boolean {
			return true;
		}


		public function load():void {
			var file:ByteArray = new settingsProperties() as ByteArray;
			parse(file.toString());
		}

		public function flush():void {
		}

		public function getKeyValuePairs():Vector.<ConfigProperty> {
			return _provider;
		}

		// Store database location in local store
		public function setString(key:String, value:String):void {
			try {
				var data:ByteArray = new ByteArray();
				data.writeUTFBytes(value);
				EncryptedLocalStore.setItem(key, data);
			}  catch (e:Error) {
				trace("Failed to store value in the EncryptedLocalStore: "+e);
			}
		}

		// read database location from local store
		public function getString(key:String):String {
			try {
				var bytes:ByteArray = EncryptedLocalStore.getItem(key);
				if (bytes) {
					return bytes.readUTFBytes(bytes.bytesAvailable);
				}
			}  catch (e:Error) {
				trace("Failed to access the EncryptedLocalStore: "+e);
			}
			return null;
		}

		public function getInteger(key:String):int {
			return 0;
		}

		public function setInteger(key:String, value:int):void {
		}

		public function getBoolean(key:String):Boolean {
			return false;
		}

		public function setBoolean(key:String, value:Boolean):void {
		}



		public function LocalFSStorageProvider(path:String) {
			_provider = new Vector.<ConfigProperty>();
		}

		public function getPair(key:String):ConfigProperty {
			if (key == null || key == "") {
				trace("ERROR: getPair Key is null");
				return null;
			}
			for each (var pair:ConfigProperty in _provider) {
				if (pair.name == key) {
					return pair;
				}
			}
			return null;
		}

		public function addPair(key:String, value:Object):void {
			var pair:ConfigProperty = getPair(key);
			if (pair == null) {
				var prop:ConfigProperty = new ConfigProperty();
				prop.name = key;
				prop.value = String(value);
				_provider.push(prop);
			} else {
				trace("ERROR: addPair duplicate key");
			}
		}

		public function parse(source:String):void {
			var lines:Array = source.split("\n");
			for each (var line:String in lines) {
				line = StringUtil.trim(line);
				if (line.match(/^#!.*$/)) { // pattern of comment line in property file
					continue;
				} else if (line.match(/^[a-z.]+\s*=\s*.*$/)) {
					var arr:Array = line.split(/\s*=\s*/);
					addPair(arr[0], arr[1])
				}
			}
		}
	}
}
