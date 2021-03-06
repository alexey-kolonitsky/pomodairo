/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings {

	import com.pomodairo.core.PomodoroEventDispatcher;
	import com.pomodairo.data.ConfigProperty;
	import com.pomodairo.core.Storage;
	import com.pomodairo.events.ConfigurationUpdatedEvent;
	import com.pomodairo.settings.providers.LocalDBStorageProvider;
	import com.pomodairo.settings.providers.LocalFSStorageProvider;
	import com.pomodairo.settings.providers.LocalSOStorageProvider;

	import flash.events.EventDispatcher;

	import flash.utils.Dictionary;

	public class ConfigManager {

		public var eventDispatcher:PomodoroEventDispatcher;

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

		public var dbProvider:Storage;

		public var defaultSettingsFilePath:String;

		public function ConfigManager() {
			trace("[INFO][ConfigManager] constructor");
			eventDispatcher = PomodoroEventDispatcher.instance;
			_providers = new Dictionary();
			_settings = new ConfigCollection();
		}

		public function initialize():void {
			trace("[INFO][ConfigManager] initialize");
			_fsProvider = new LocalFSStorageProvider(defaultSettingsFilePath);
			_fsProvider.load();
			setDefaultValueFrom(_fsProvider.getKeyValuePairs());

			_soProvider = new LocalSOStorageProvider();
			_settings.setString(ConfigItemName.DATABASE_LOCATION, _soProvider.getString(ConfigItemName.DATABASE_LOCATION), true);

			_providers[SettingItemStorage.LOCAL_FS_STORAGE] = _fsProvider;
			_providers[SettingItemStorage.LOCAL_SO_STORAGE] = _soProvider;
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
				dbProvider.updateConfig(key, value);
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

		public function getInt(key:String):int {
			return parseInt(getConfig(key));
		}

		public function clearConfig(key:String):void {
			var item:ConfigItem = _settings.getItem(key);
			item.userValue = null;
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
					_settings.addItem(item);
				}
				if (item.userValue != pair.value){
					item.userValue = pair.value;
					trace("[INFO][ConfigManager] serUserValue " + item.name + "=" + item.userValue);
					eventDispatcher.sendConfigItemUpdateEvent(item);
				}
			}
		}
	}
}
