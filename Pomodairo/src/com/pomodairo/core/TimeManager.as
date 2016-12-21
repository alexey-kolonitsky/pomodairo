/**
 * Created by akalanitski on 10.12.2016.
 */
package com.pomodairo.core {
import com.pomodairo.data.ConfigProperty;
import com.pomodairo.data.Pomodoro;
import com.pomodairo.core.PomodoroEventDispatcher;
import com.pomodairo.settings.ConfigItem;
import com.pomodairo.settings.ConfigManager;
import com.pomodairo.settings.DefaultConfig;
import com.pomodairo.date.TimeSpan;
import com.pomodairo.date.TimeSpan;
import com.pomodairo.date.TimeSpan;
import com.pomodairo.events.ConfigurationUpdatedEvent;
import com.pomodairo.events.PomodoroEvent;
import com.pomodairo.settings.ConfigItemName;

import flash.events.Event;

import flash.events.EventDispatcher;

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

public class TimeManager  {

    public var eventDispatcher:PomodoroEventDispatcher;
    public var config:ConfigManager;

    private const TIMER_INTERVAL:int = 10;
    private const DELAY_BEFORE_BREAK_STARTS:int = 5000; // Milliseconds

    private var baseTimer:int;
    private var pomodoroTimer:Timer;
    private var breakTimer:Timer;

    private var _pomodoroTime:TimeSpan = DefaultConfig.POMODORO_TIME;

    public function get pomodoroTime():TimeSpan {
        return _pomodoroTime;
    }

    private var _breakTime:TimeSpan = DefaultConfig.BREAK_TIME;

    public function get breakTime():TimeSpan {
        return _breakTime;
    }

    private var _longBreakTime:TimeSpan = DefaultConfig.LONG_BREAK_TIME;

    public function get longBreakTime():TimeSpan {
        return _longBreakTime;
    }


    private var _longBreakInterval:uint = 4;

    public function get longBreakInterval():uint {
        return _longBreakInterval;
    }

    private var _pomodoroCounter:int = 0;

    public function get pomodoroCounter():Number {
        return _pomodoroCounter;
    }


    public function get time():Date {
        var result:Date = new Date(baseTimer - getTimer());
        return result;

    }

    public function get isLongBreak():Boolean {
        var result:Boolean = _pomodoroCounter % _longBreakInterval == 0;
        return result;
    }

    private var _isRunning = false;

    public function get isRunning():Boolean {
        return _isRunning ;
    }

    public function get isBreak():Boolean {
        return breakTimer.running;
    }

    public function get isIdle():Boolean {
        return !_isRunning && !isRunning;
    }

    public function get isReady():Boolean {
        return _activeTask != null;
    }

    private var _activeTask:Pomodoro;

    public function get activeTask():Pomodoro {
        return _activeTask;
    }

    public function TimeManager() {
        trace("[INFO][TimeManager] constructor");

        pomodoroTimer = new Timer(TIMER_INTERVAL);
        pomodoroTimer.addEventListener(TimerEvent.TIMER, updateTimer);

        breakTimer = new Timer(TIMER_INTERVAL);
        breakTimer.addEventListener(TimerEvent.TIMER, updateBreakTimer);
    }

    public function initialize():void {
        trace("[INFO][TimeManager] initialize");

        eventDispatcher.addEventListener(ConfigurationUpdatedEvent.UPDATED, onConfigChanged);
        eventDispatcher.addEventListener(PomodoroEvent.SELECTED, onPomodoroSelected);
        eventDispatcher.addEventListener(PomodoroEvent.NEXT_TASK_SELECTED, onPomodoroSelected);

        _pomodoroTime = TimeSpan.fromMinutes(config.getFloat(ConfigItemName.POMODORO_LENGTH));
        _breakTime = TimeSpan.fromMinutes(config.getFloat(ConfigItemName.SHORT_BREAK_LENGTH));
        _longBreakTime = TimeSpan.fromMinutes(config.getFloat(ConfigItemName.LONG_BREAK_LENGTH));
        _longBreakInterval = config.getFloat(ConfigItemName.LONG_BREAK_INTERVAL)
    }

    private function onPomodoroSelected(event:PomodoroEvent):void {
        if (!isRunning) {
            _activeTask = event.pomodoro;
        }
    }

    /**
     * This is the main function, will be called for every frame.
     * Check if time is up and perform other timer-related tasks.
     *
     */
    private function updateTimer(evt:TimerEvent):void {
        if (getTimer() >= baseTimer) {
            eventDispatcher.timeout(_activeTask);
            _pomodoroCounter++;
            pomodoroTimer.stop();
            _activeTask = null;
            scheduleBreakTimerStart();
        } else {
            eventDispatcher.tick(_activeTask);
        }
    }

    private function updateBreakTimer(evt:TimerEvent):void {
        // Check if break time is over
        if (getTimer() >= baseTimer) {
            trace("Long break over. Pomodoros so far: " + _pomodoroCounter);
            eventDispatcher.sendEvent(PomodoroEvent.STOP_BREAK, _activeTask);
            breakTimer.stop();
        }
        eventDispatcher.sendEvent(PomodoroEvent.BREAK_TICK, _activeTask, null);
    }

    private function startBreakTimer(evt:TimerEvent):void {
        baseTimer = getTimer();
        baseTimer += isLongBreak ? _longBreakTime.time : _breakTime.time;
        breakTimer.start();
        eventDispatcher.startBreak(_activeTask);
    }

    public function stopBreakTimer():void {
        if (isBreak) {
            breakTimer.stop();
            eventDispatcher.sendEvent(PomodoroEvent.STOP_BREAK, _activeTask);
        }
    }

    public function startTimer(activeTask:Pomodoro):void {

        baseTimer = getTimer();
        baseTimer += _pomodoroTime.time + 1000;
        // baseTimer += 5*1000;
        pomodoroTimer.start();
        _isRunning = true;
        _activeTask = activeTask;

        // Dispatch event
        eventDispatcher.sendEvent(PomodoroEvent.START_POMODORO, _activeTask);
    }


    private function scheduleBreakTimerStart():void {
        var delayBeforeBreakStartTimer:Timer = new Timer(DELAY_BEFORE_BREAK_STARTS, 1);
        delayBeforeBreakStartTimer.addEventListener(TimerEvent.TIMER, startBreakTimer);
        delayBeforeBreakStartTimer.start();
    }

    public function stop():void {
        if (isBreak) {
            stopBreakTimer();
        }
        if (isRunning) {
            stopTimer();
        }
    }

    /**
     * Stop the Timer
     */
    public function stopTimer():void {
        _isRunning = false;
        pomodoroTimer.stop();
        eventDispatcher.sendEvent(PomodoroEvent.STOP_POMODORO, _activeTask);
    }

    private function onConfigChanged(event:ConfigurationUpdatedEvent):void {
        var configItem:ConfigProperty = event.configElement;
        if (configItem == null) {
            trace("[ERROR][TimeManager] onConfigChanged configItem is null");
            return;
        }
        switch (configItem.name) {
            case ConfigItemName.POMODORO_LENGTH:
                _pomodoroTime = TimeSpan.fromMinutes(parseFloat(event.configElement.value));
                break;
            case ConfigItemName.SHORT_BREAK_LENGTH:
                _breakTime = TimeSpan.fromMinutes(parseFloat(event.configElement.value));
                break;
            case ConfigItemName.LONG_BREAK_LENGTH:
                _longBreakTime = TimeSpan.fromMinutes(parseFloat(event.configElement.value));
                break;
            case ConfigItemName.LONG_BREAK_INTERVAL:
                _longBreakInterval = parseInt(event.configElement.value);
                break;
        }
    }
}
}
