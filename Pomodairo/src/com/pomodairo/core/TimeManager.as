/**
 * Created by akalanitski on 10.12.2016.
 */
package com.pomodairo.core {
import com.pomodairo.Pomodoro;
import com.pomodairo.PomodoroEventDispatcher;
import com.pomodairo.components.config.DefaultConfig;
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

    public static const CHANGED:String = "timeChanged";

    private var eventDispatcher:PomodoroEventDispatcher;

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

    public function get isLogBreak():Boolean {
        var result:Boolean = _pomodoroCounter % _longBreakInterval == 0;
        return result;
    }

    public function get isRunning():Boolean {
        return pomodoroTimer.running;
    }

    public function get isBreak():Boolean {
        return breakTimer.running;
    }


    public var taskManager:TaskManager;

    private var activeTask:Pomodoro;



    public function TimeManager(
//        pomodoroTime:TimeSpan,
//        breakTime:TimeSpan,
//        longBreakTime:TimeSpan,
//        longBreakInterval:uint
    )
    {
//        _pomodoroTime = pomodoroTime;
//        _breakTime = breakTime;
//        _longBreakTime = longBreakTime;
//        _longBreakInterval = longBreakInterval;
//
        eventDispatcher = PomodoroEventDispatcher.instance;
        eventDispatcher.addEventListener(ConfigurationUpdatedEvent.UPDATED, onConfigChanged);

        pomodoroTimer = new Timer(TIMER_INTERVAL);
        pomodoroTimer.addEventListener(TimerEvent.TIMER, updateTimer);

        breakTimer = new Timer(TIMER_INTERVAL);
        breakTimer.addEventListener(TimerEvent.TIMER, updateBreakTimer);
    }

    /**
     * This is the main function, will be called for every frame.
     * Check if time is up and perform other timer-related tasks.
     *
     */
    private function updateTimer(evt:TimerEvent):void {
        if (getTimer() >= baseTimer) {
            eventDispatcher.timeout(activeTask);
            _pomodoroCounter++;
            pomodoroTimer.stop();
            scheduleBreakTimerStart();
        } else {
            eventDispatcher.tick(activeTask);
        }
    }

    private function updateBreakTimer(evt:TimerEvent):void {
        // Check if break time is over
        if (isLogBreak) {
            // Check long break
            if (getTimer() >= baseTimer + _longBreakTime.time) {
                trace("Long break over. Pomodoros so far: " + _pomodoroCounter);
                eventDispatcher.stopBreak(activeTask);
                breakTimer.stop();
            }
        } else {
            // Check short break
            if (getTimer() >= baseTimer + _breakTime.time) {
                trace("Short break over. Pomodoros so far: " + _pomodoroCounter);
                eventDispatcher.stopBreak(activeTask);
                breakTimer.stop();
            }
        }
    }

    private function startBreakTimer(evt:TimerEvent):void {
        baseTimer = getTimer();
        breakTimer.start();
        eventDispatcher.startBreak(activeTask);
    }

    public function stopBreakTimer():void {
        breakTimer.stop();
        eventDispatcher.stopBreak(activeTask);
    }

    public function startTimer(activeTask:Pomodoro):void {

        baseTimer = getTimer();
        baseTimer += _pomodoroTime.time + 1000;
        // baseTimer += 5*1000;
        pomodoroTimer.start();

        // Dispatch event
        eventDispatcher.startTimer(activeTask);
    }


    private function scheduleBreakTimerStart():void {
        var delayBeforeBreakStartTimer:Timer = new Timer(DELAY_BEFORE_BREAK_STARTS, 1);
        delayBeforeBreakStartTimer.addEventListener(TimerEvent.TIMER, startBreakTimer);
        delayBeforeBreakStartTimer.start();
    }

    /**
     * Stop the Timer
     */
    public function stopTimer(event:Event = null):void {
        pomodoroTimer.stop();
        eventDispatcher.stopTimer(activeTask);
    }

    private function onConfigChanged(event:ConfigurationUpdatedEvent):void {
        if (event.configElement.name == ConfigItemName.POMODORO_LENGTH) {
            _pomodoroTime = TimeSpan.fromMinutes(parseFloat(event.configElement.value));
        }

        if (event.configElement.name == ConfigItemName.SHORT_BREAK_LENGTH) {
            _breakTime = TimeSpan.fromMinutes(parseFloat(event.configElement.value));
        }

        if (event.configElement.name == ConfigItemName.LONG_BREAK_LENGTH) {
            _longBreakTime = TimeSpan.fromMinutes(parseFloat(event.configElement.value));
        }

        if (event.configElement.name == ConfigItemName.LONG_BREAK_INTERVAL) {
            _longBreakInterval = parseInt(event.configElement.value);
        }
    }
}
}
