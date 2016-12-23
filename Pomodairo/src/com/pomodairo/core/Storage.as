package com.pomodairo.core
{
	import com.pomodairo.data.ConfigProperty;
	import com.pomodairo.data.Pomodoro;
	import com.pomodairo.core.PomodoroEventDispatcher;
	import com.pomodairo.RegexUtils;
import com.pomodairo.components.PomodoroEditor;
import com.pomodairo.components.config.AdvancedConfigPanel;
	import com.pomodairo.events.PomodoroEvent;
	import com.pomodairo.settings.ConfigItemName;
	import com.pomodairo.settings.ConfigManager;
import com.pomodairo.settings.DefaultConfig;

import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	public class Storage extends EventDispatcher
	{
		public static const DATASET_CHANGED:String = "datasetChanged";
		public static const HISTORY_UPDATED:String = "historyUpdated";

		//-----------------------------
		// Instance
		//-----------------------------

		public static var _instance:Storage;

		public static function get instance():Storage {
			if (_instance == null) {
				_instance = new Storage();
			}
			return _instance;
		}



		private var _initialized:Boolean = false;

		public function get initialized():Boolean {
			return _initialized;
		}


		//-----------------------------
		// Injections
		//-----------------------------

		public var configManager:ConfigManager;
		public var eventDispatcher:PomodoroEventDispatcher;

		
		[Bindable]
		public var dataset:Array;

		public var pomodorosOfDayDataset:Array;

		[Bindable]
		public var pomodorosPerDayDataset:ArrayCollection;

		[Bindable]
		public var realityFactorDataset:ArrayCollection;


		private var sqlConnection:SQLConnection;
		
		public function Storage() {
			trace("[INFO][Storage] Constructor");
		}

		private function startPomodoro(e:PomodoroEvent):void {
			// Nothing to do here yet.
		}
		
		private function completeCurrentPomodoro(e:PomodoroEvent):void {
			increasePomodoroCount(e.pomodoro);
		}
		
		private function addInterruption(e:PomodoroEvent):void {
			addPomodoro(e.other);
			increaseInterruptionCount(e.pomodoro);
		}
		
		private function addUnplanned(e:PomodoroEvent):void {
			addPomodoro(e.other);
			increaseUnplannedCount(e.pomodoro);
		}
		
		private function editPomodoro(e:PomodoroEvent):void {
			updatePomodoro(e.other, e.pomodoro);
		}		
		
		private function addNewPomodoro(e:PomodoroEvent):void {
			addPomodoro(e.other);
		}
		
		private function closePomodoro(e:PomodoroEvent):void {
			markDone(e.pomodoro);
		}
		
		public function initialize():void {
			if (_initialized) {
				return;
			}

			/** Database file location path */
			var databaseFolderLocation:String = configManager.getConfig(ConfigItemName.DATABASE_LOCATION);
			var sqlConnectionFile:File;
			if (databaseFolderLocation == null || databaseFolderLocation == "") {
				sqlConnectionFile = File.userDirectory.resolvePath(DefaultConfig.DATABASE_FILE);
			} else {
				var file:File = new File(databaseFolderLocation);
				if (file.exists == false) {
					trace("[ERROR][Storage] initialize: Invalid database location. Change it at settings");
					sqlConnectionFile = File.userDirectory.resolvePath(DefaultConfig.DATABASE_FILE);
				} else {
					if (file.isDirectory)
						sqlConnectionFile = new File(databaseFolderLocation+File.separator+DefaultConfig.DATABASE_FILE);
					else
						sqlConnectionFile = file;
				}
			}
			
			sqlConnection = new SQLConnection();
			
			if(sqlConnectionFile.exists) {
				trace("[INFO][Storage] initialize: Load database from '" + sqlConnectionFile.url + "'");
				sqlConnection.addEventListener(SQLEvent.OPEN, onSQLConnectionOpened);
				sqlConnection.open(sqlConnectionFile, SQLMode.UPDATE);
			} else {
				trace("[INFO][Storage] initialize: Create database at " + sqlConnectionFile.url + "'");
				sqlConnection.open(sqlConnectionFile, SQLMode.CREATE);
				createTable();
			}

			eventDispatcher.addEventListener(PomodoroEvent.START_POMODORO, startPomodoro);
			eventDispatcher.addEventListener(PomodoroEvent.TIME_OUT, completeCurrentPomodoro);
			eventDispatcher.addEventListener(PomodoroEvent.NEW_INTERRUPTION, addInterruption);
			eventDispatcher.addEventListener(PomodoroEvent.NEW_UNPLANNED, addUnplanned);
			eventDispatcher.addEventListener(PomodoroEvent.NEW_POMODORO, addNewPomodoro);
			eventDispatcher.addEventListener(PomodoroEvent.DONE, closePomodoro);
			eventDispatcher.addEventListener(PomodoroEvent.EDITED, editPomodoro);

			_initialized = true;
		}
		
		public function initViews():void {
			getPromodorosByDate(new Date());
			getPomodorosPerDay();
			getRealityFactors();
//			getPomodoroHashTags();
//			getInterruptionHashTags();
		}
		
		private function onSQLConnectionOpened(event:SQLEvent):void {
			if (event.type == "open") {
				migrateFrom15to16();
				getAllPomodoros();
			}
		}
		
		
		private function createTable():void {
			trace("[INFO][Storage] createTable: Create new table");
		 	var q:SQLStatement = new SQLStatement();
		 	q.sqlConnection = sqlConnection;
		 	q.text = "CREATE TABLE IF NOT EXISTS pomodoro( " +
				"id INTEGER PRIMARY KEY ASC, " +
				"name TEXT, " +
				"type TEXT, " +
				"pomodoros INTEGER, " +
				"unplanned INTEGER, " +
				"interruptions INTEGER, " +
				"created DATETIME, " +
				"closed DATETIME, " +
				"parent INTEGER, " +
				"visible BOOLEAN, " +
				"ordinal INTEGER, " +
				"done BOOLEAN, " +
				"estimated INTEGER )";
		 	q.addEventListener( SQLErrorEvent.ERROR, createError );
		 	q.execute();
		}

		public function getAllPomodoros():void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "SELECT * FROM Pomodoro WHERE (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"') and visible=true order by ordinal desc, done desc, closed, strftime('%Y/%m/%d',created)!=strftime('%Y/%m/%d','now') desc, pomodoros desc, estimated desc";
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.execute();
		}
		
		public function getOpenPomodoros():ArrayCollection {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select * from Pomodoro where (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"') and visible=true " +
					"and done=false order by ordinal desc";
			dbStatement.text = sqlQuery;
			dbStatement.execute();
			var result:SQLResult = dbStatement.getResult();
			return new ArrayCollection(result.data);
		}

		public function getAllItems():void
		{
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "SELECT * from Pomodoro";
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.execute();
		}

		private function getStartDate(date:Date, range:Number):Date {
			if(range < 0) {
				return new Date(date.fullYear, date.month, date.date + range);
			}
			else {
				return new Date(date.fullYear, date.month, date.date);
			}
		}
		private function getEndDate(date:Date, range:Number):Date {
			if(range <= 0) {
				return new Date(date.fullYear, date.month, date.date, 23, 59, 59);
			}
			else {
				return new Date(date.fullYear, date.month, date.date + range, 23, 59, 59);
			}
		}

		public function getPromodorosByDate(day:Date, range:Number = -1, filter:String = ""):void {
			trace("[INFO][Storage] getPomodorosByDate " + day + ", range=" + range + ", filter=");
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "SELECT name, substr(type,0,1) AS type, closed, estimated, pomodoros, unplanned, interruptions FROM Pomodoro WHERE closed > strftime( '%J', :startDate ) AND closed <= strftime('%J', :endDate) AND done=1 AND (type=:typePomodoro or type=:typeUnplanned) ";
			if (filter) {
				dbStatement.text += "AND name like '%" + filter + "%'";
			}
			dbStatement.parameters[":startDate"] = getStartDate(day, range);
			dbStatement.parameters[":endDate"] = getEndDate(day, range);
			dbStatement.parameters[":typePomodoro"] = Pomodoro.TYPE_POMODORO;
			dbStatement.parameters[":typeUnplanned"] = Pomodoro.TYPE_UNPLANNED;
			dbStatement.addEventListener(SQLEvent.RESULT, pomodorosOfDayResult1);
			dbStatement.execute();
		}

		public function getPomodorosPerDay(eventHandler:Function = null):void {
			trace("[INFO][Storage] getPomodorosPerDay ");
			// Created pomodoros per day, not the pomodoros done!
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text =
				"SELECT strftime('%Y-%m-%d', created) AS name, sum(estimated) AS estimated, sum(pomodoros) AS pomodoros, (sum(interruptions) + sum(unplanned)) AS interruptions "
				+ "FROM Pomodoro "
				+ "GROUP BY name ";
			if (eventHandler == null) {
				eventHandler = pomodorosOfDayResult1;
			}
			dbStatement.addEventListener(SQLEvent.RESULT, eventHandler);
			dbStatement.execute();
		}
		
		public function getRealityFactors():void {
			trace("[INFO][Storage] getRealityFactors ");
			// Created pomodoros per week, not the pomodoros done!
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text =
				"SELECT strftime('%Y%W',created) AS week, strftime('%Y week %W',created) AS name, round(cast(sum(pomodoros) as real)/sum(estimated),2) AS factor, sum(estimated) AS estimated, sum(pomodoros) AS pomodoros, (sum(interruptions) + sum(unplanned)) AS interruptions, (sum(pomodoros)-sum(estimated)) AS delta "
					+ "FROM Pomodoro "
					+ "GROUP BY week ";
			dbStatement.addEventListener(SQLEvent.RESULT, pomodorosOfDayResult1);
			dbStatement.execute();
		}
		
//		public function getPomodoroHashTags():void
//		{
//			var regexUtils:RegexUtils = new RegexUtils();
//			var dbStatement:SQLStatement = new SQLStatement();
//			dbStatement.itemClass = Pomodoro;
//			dbStatement.sqlConnection = sqlConnection;
//			var sqlQuery:String = "SELECT * FROM pomodoro WHERE name like '%#%' and (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"')";
//			dbStatement.text = sqlQuery;
//			dbStatement.execute();
//			var tempResult:SQLResult = dbStatement.getResult();
//			var result:Array = [];
//			if(tempResult.data != null) {
//				for(var i:int = 0; i<tempResult.data.length; i++) {
//					var tags:Array = regexUtils.extractHashTags(tempResult.data[i].name);
//					for(var j:int=0; j < tags.length; j++) {
//						result.push(tags[j]);
//					}
//				}
//				this.datasetStatistics5 = removeDuplicates(result);
//			}
//			else {
//				this.datasetStatistics6 = result;
//			}
//		}
//		public function getInterruptionHashTags():void
//		{
//			var regexUtils:RegexUtils = new RegexUtils();
//			var dbStatement:SQLStatement = new SQLStatement();
//			dbStatement.itemClass = Pomodoro;
//			dbStatement.sqlConnection = sqlConnection;
//			var sqlQuery:String = "SELECT * FROM pomodoro WHERE name like '%#%' and (type='"+Pomodoro.TYPE_INTERRUPTION+"' or type='"+Pomodoro.TYPE_UNPLANNED+"')";
//			dbStatement.text = sqlQuery;
//			dbStatement.execute();
//			var tempResult:SQLResult = dbStatement.getResult();
//			var result:Array = [];
//			if(tempResult.data != null) {
//				for(var i:int = 0; i<tempResult.data.length; i++) {
//					var tags:Array = regexUtils.extractHashTags(tempResult.data[i].name);
//					for(var j:int=0; j < tags.length; j++) {
//						result.push(tags[j]);
//					}
//				}
//				this.datasetStatistics6 = removeDuplicates(result);
//			}
//			else {
//				this.datasetStatistics6 = result;
//			}
//		}
		
		private function removeDuplicates(arr:Array):Array
		{
			var currentValue:String = "";
			var tempArray:Array = [];
			arr.sort(Array.CASEINSENSITIVE);
			arr.forEach(
				function(item:*, index:uint, array:Array):void {
					if (currentValue != item) {
						tempArray.push(item);
						currentValue= item;
					}
				}
			);
			return tempArray.sort(Array.CASEINSENSITIVE);
		}
		
		private function pomodorosOfDayResult1(event:SQLEvent):void {

			var statement:SQLStatement = event.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, pomodorosOfDayResult1);
			var result:SQLResult = statement.getResult();
		    if (result != null && result.data != null && result.data.length > 0) {
				trace("[INFO][Storage] historyResult, no result " + result.data.length);
		    	pomodorosOfDayDataset = result.data;
				dispatchEvent(new Event(Storage.HISTORY_UPDATED));
		    } else {
				pomodorosOfDayDataset = [];
				dispatchEvent(new Event(Storage.HISTORY_UPDATED));
				trace("[INFO][Storage] historyResult, no result");
			}
		}

		private function resultWrapper(event:SQLEvent):void {

		}



		private function pomodorosPerDayResult(event:SQLEvent):void {
			var statement:SQLStatement = event.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, pomodorosPerDayResult);

			var result:SQLResult = statement.getResult();
		    if (result != null)
		    {
		    	pomodorosPerDayDataset = new ArrayCollection(result.data);
		    }
		}

		private function realityFactorResult(event:SQLEvent):void {
			var statement:SQLStatement = event.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, realityFactorResult);

			var result:SQLResult = statement.getResult();
		    if (result != null)
		    {
		    	realityFactorDataset = new ArrayCollection(result.data);
		    }
		}
		
		private function onDBStatementSelectResult(event:SQLEvent):void
		{
			var statement:SQLStatement = event.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, onDBStatementSelectResult);

			var result:SQLResult = statement.getResult();
		    if (result != null)
		    {
		    	dataset = result.data;
		    }
			dispatchEvent(new Event(DATASET_CHANGED));
		}
		
		private function onDBStatementInsertResult(event:SQLEvent):void {
			var statement:SQLStatement = event.currentTarget as SQLStatement;
			statement.removeEventListener(SQLEvent.RESULT, onDBStatementInsertResult);

		    if (sqlConnection.totalChanges >= 1) {
		    	getAllPomodoros();
		    }
		}

		private function createError(event:SQLErrorEvent):void {
		 	trace('[INFO][Storage] createError: Create Table Failed. Message: ' + event);
		}
		
		private function createResult(event:SQLEvent):void {
		 	trace('[INFO][Storage] createResult: Query Created Successfully');
		}
		
		public function addPomodoro(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "INSERT INTO Pomodoro  (name, type, pomodoros, estimated, unplanned, interruptions, created, closed, done, parent, visible, ordinal) VALUES (:name, :type, :pomodoros, :estimated, :unplanned, :interruptions, :created, :closed, :done, :parent, :visible, :ordinal);";
			dbStatement.parameters[":name"] = pom.name;
			dbStatement.parameters[":type"] = pom.type; 
			dbStatement.parameters[":pomodoros"] = pom.pomodoros; 
			dbStatement.parameters[":estimated"] = pom.estimated; 
			if(pom.estimated < 0) {
				dbStatement.parameters[":estimated"] = null; 
			}
			dbStatement.parameters[":unplanned"] = pom.unplanned; 
			dbStatement.parameters[":interruptions"] = pom.interruptions; 
			dbStatement.parameters[":created"] = pom.created; 
			dbStatement.parameters[":closed"] = pom.closed; 
			dbStatement.parameters[":done"] = pom.done;
			dbStatement.parameters[":parent"] = pom.parent;
			dbStatement.parameters[":visible"] = pom.visible;
			dbStatement.parameters[":ordinal"] = pom.ordinal;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}

		public function updatePomodoro(updated:Pomodoro, old:Pomodoro):void
		{
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "UPDATE Pomodoro SET name=:name, estimated=:estimated WHERE id=:id;";
			dbStatement.parameters[":name"] = updated.name;
			dbStatement.parameters[":estimated"] = updated.estimated;
			dbStatement.parameters[":id"] = old.id;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();        	
		}
	
	
		public function remove(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "delete from Pomodoro where id=:id;";
			dbStatement.parameters[":id"] = pom.id;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}
		
		public function markDone(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "update Pomodoro set done=:done, closed=strftime( '%J', :closed ) where id=:id;";
			dbStatement.parameters[":id"] = pom.id;
			dbStatement.parameters[":done"] = pom.done;
			dbStatement.parameters[":closed"] = pom.closed;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function updateVisibility(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "UPDATE Pomodoro SET visible=:visible WHERE id=:id;";
			dbStatement.parameters[":id"] = pom.id;
			dbStatement.parameters[":visible"] = pom.visible;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}	
		
		public function updateOrdinal(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			dbStatement.text = "update Pomodoro set ordinal = :ordinal where id=:id;";
			dbStatement.parameters[":id"] = pom.id;
			dbStatement.parameters[":ordinal"] = pom.ordinal;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increasePomodoroCount(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			trace("Increase DB Pomodoro count: "+pom.pomodoros);
			pom.pomodoros++;
			dbStatement.text = "update Pomodoro set pomodoros=:pomodoros where id=:id;";
			dbStatement.parameters[":pomodoros"] = pom.pomodoros;
			dbStatement.parameters[":id"] = pom.id;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increaseInterruptionCount(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			pom.interruptions++;
			dbStatement.text = "update Pomodoro set interruptions = "+pom.interruptions+" where id='"+pom.id+"';";
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increaseUnplannedCount(pom:Pomodoro):void {
			var dbStatement:SQLStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			pom.unplanned++;
			dbStatement.text = "update Pomodoro set unplanned = "+pom.unplanned+" where id='"+pom.id+"';";
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}
		
		
		/* ----------------------------------------------------
			        CONFIGURATION TABLE STUFF
		   ---------------------------------------------------- */

		private var dbCfgStatement:SQLStatement;

		/**
		 * New since 1.4. This method will create a configuration table if none exists.
		 */
		private function checkConfigurationTable():void {
		 	var q:SQLStatement = new SQLStatement();
		 	q.sqlConnection = sqlConnection;
		 	q.text = "CREATE TABLE IF NOT EXISTS config(name TEXT PRIMARY KEY, value TEXT)";
		 	q.addEventListener(SQLEvent.RESULT, createResult);
		 	q.addEventListener(SQLErrorEvent.ERROR, createError);
		 	q.execute();
		}
		
		public function getAllConfig():void {
			trace("[INFO][Storage] getAllConfig");
			dbCfgStatement = new SQLStatement();
			dbCfgStatement.itemClass = ConfigProperty;
			dbCfgStatement.sqlConnection = sqlConnection;
			dbCfgStatement.text = "SELECT * FROM Config";
			dbCfgStatement.addEventListener(SQLEvent.RESULT, getSelectConfigResult);
			dbCfgStatement.execute();
		}
		
		private function getSelectConfigResult(event:SQLEvent):void {
			var result:SQLResult = dbCfgStatement.getResult();
		    if (result != null) {
				ConfigManager.instance.setUserValueFrom(result.data);
		    }
		}
		
		private function updateConfigResult(event:SQLEvent):void {
		    if (sqlConnection.totalChanges >= 1)  {
		    	getAllConfig();
		    }
		}
				
		public function updateConfig(name:String, value:String):void {
			trace("[INFO][Storage] setConfigurationValue name='" + name + "', value='" + value + "'");
			dbCfgStatement.text = "REPLACE INTO Config (name,value) VALUES (:name, :value)";
			dbCfgStatement.parameters[":name"] = name;
			dbCfgStatement.parameters[":value"] = value;
			dbCfgStatement.addEventListener(SQLEvent.RESULT, updateConfigResult);
			dbCfgStatement.execute()
		}
		
		public function removeConfig(key:String):void {
			trace("[INFO][Storage] removeConfig, key='" + key + "'");
			dbCfgStatement.text = "DELETE FROM Config WHERE name=:name";
			dbCfgStatement.parameters[":name"] = key;
			dbCfgStatement.execute();
		}
		   
		/* ----------------------------------------------------
			        END OF CONFIGURATION TABLE STUFF
		   ---------------------------------------------------- */
		   
   	    /* ----------------------------------------------------
		        	MIGRATION STUFF
	   	  ---------------------------------------------------- */
   
		public function migrateFrom15to16():void {
			var statement:SQLStatement = new SQLStatement();
			statement.itemClass = ConfigProperty;
			statement.sqlConnection = sqlConnection;
			statement.text = "ALTER TABLE pomodoro ADD estimated INTEGER";
			try {
				statement.execute();
			} catch (err:SQLError) {
			  // Ignore migration errors
			  // Alert.show("Migration reported error: "+err);
			}
		}

		/* ----------------------------------------------------
		        	END OF MIGRATION STUFF
	   	  ---------------------------------------------------- */
	}
	
}