/**
 * Created by akalanitski on 08.12.2016.
 */
package com.pomodairo.date {
public class TimeSpan {

    public static const SECOND:Number = 1000;
    public static const MINUTE:Number = 60 * SECOND;
    public static const HOUR:Number = 60 * MINUTE;
    public static const DAY:Number = 24 * HOUR;
    public static const WEEK:Number = 7 * DAY;


    public var time:Number;

    public function TimeSpan(time:Number) {
        this.time = time;
    }

    public function get seconds():Number {
        return time / SECOND;
    }

    public function get minutes():Number {
        return time / MINUTE;
    }

    public function get hour():Number {
        return time / HOUR;
    }

    public function get day():int {
        return Math.round(time / DAY);
    }

    public function get week():int {
        return Math.round(time / WEEK);
    }

    public static function fromDays(days:int):TimeSpan {
        return new TimeSpan(days * DAY);
    }

    public static function fromMinutes(minutes:int):TimeSpan {
        return new TimeSpan(minutes * MINUTE);
    }
}
}
