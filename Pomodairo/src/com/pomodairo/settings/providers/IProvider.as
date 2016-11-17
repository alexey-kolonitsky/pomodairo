/**
 * Created by akalanitski on 16.11.2016.
 */
package com.pomodairo.settings.providers {
import com.pomodairo.ConfigProperty;

public interface IProvider {
		function isReadonly():Boolean;
		function load():void;
		function flush():void;
		function getKeyValuePairs():Vector.<ConfigProperty>;
	}
}
