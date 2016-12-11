/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings {

import com.pomodairo.data.ConfigProperty;
import com.pomodairo.core.Storage;
import com.pomodairo.settings.providers.LocalDBStorageProvider;
	import com.pomodairo.settings.providers.LocalFSStorageProvider;
	import com.pomodairo.settings.providers.LocalSOStorageProvider;

	import flash.utils.Dictionary;

	public class ConfigManager {

		private static var _instance:ConfigManager;

		public static function get instance():ConfigManager {
			if (_instance == null) {
				_instance = new ConfigManager();
			}
			return _instance;
		}

		private var _providers:Dictionary;
		private var _settings:ConfigCollection;
		private var _fsProvider:LocalFSStorageProvider;
		private var _soProvider:LocalSOStorageProvider;
		private var _dbProvider:Storage;

		public var defaultSettingsFilePath:String;

		public function ConfigManager() {
			_providers = new Dictionary();
			_settings = new ConfigCollection();
			_dbProvider = Storage.instance;
		}

		public function hasConfig(key:String):Boolean {
			var item:ConfigItem = _settings.getItem(key);
			var result:Boolean = (item != null);
			return result;
		}

		public function setConfig(key:String, value:String):void {
			var item:ConfigItem = _settings.getItem(key);
			item.userValue = value;
			if (key == ConfigItemName.DATABASE_LOCATION) {
				_soProvider.setString(key, value);
			} else {
				_dbProvider.setConfigurationValue(key, value);
			}
		}

		public function getConfig(key:String):String {
			var result:String;
			if (key == ConfigItemName.DATABASE_LOCATION) {
				result = _soProvider.getString(key);
			} else {
				var item:ConfigItem = _settings.getItem(key);
				result = item.userValue || item.defaultValue;
			}

			return result;
		}

		public function getBoolean(name:String):Boolean {
			return getConfig(name) == "true";
		}

		public function setBoolean(name:String, value:Boolean):void {
			setConfig(name, value.toString());
		}

		public function getFloat(key:String):Number {
			return parseFloat(getConfig(key));
		}

		public function clearConfig(key:String):void {
			var item:ConfigItem = _settings.getItem(key);
			item.userValue = null;
		}

		public function initialize():void {
			_fsProvider = new LocalFSStorageProvider(defaultSettingsFilePath);
			_fsProvider.load();
			setDefaultValueFrom(_fsProvider.getKeyValuePairs());

			_soProvider = new LocalSOStorageProvider();
			_settings.setString(ConfigItemName.DATABASE_LOCATION, _soProvider.getString(ConfigItemName.DATABASE_LOCATION), true);

			_providers[SettingItemStorage.LOCAL_FS_STORAGE] = _fsProvider;
			_providers[SettingItemStorage.LOCAL_SO_STORAGE] = _soProvider;
		}

		public function setDefaultValueFrom(pairs:Vector.<ConfigProperty>):void {
			for each (var prop:ConfigProperty in pairs) {
				var item:ConfigItem = _settings.getItem(prop.name);
				if (item == null) {
					item = new ConfigItem();
					item.name = prop.name;
					item.defaultValue = prop.value;
					_settings.addItem(item);
				} else {
					item.defaultValue = prop.value;
				}
			}
		}

		public function setUserValueFrom(pairs:Array):void {
			for each (var pair:ConfigProperty in pairs) {
				var item:ConfigItem = _settings.getItem(pair.name);
				if (item == null) {
					item = new ConfigItem();
					item.name = pair.name;
					item.userValue = pair.value;
					_settings.addItem(item);
				} else {
					item.userValue = pair.value;
				}
			}
		}

	}
}
