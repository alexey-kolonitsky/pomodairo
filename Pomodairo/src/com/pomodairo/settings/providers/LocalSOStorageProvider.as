/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings.providers {
	import com.pomodairo.data.ConfigProperty;

	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;

	/**
	 * Local encrypted storage
	 */
	public class LocalSOStorageProvider implements IProvider {

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

		public function load():void {
		}

		public function flush():void {
		}

		public function isReadonly():Boolean {
			return false;
		}

		public function getKeyValuePairs():Vector.<ConfigProperty> {
			return null;
		}
}
}
