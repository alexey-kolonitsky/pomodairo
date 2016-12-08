/**
 * Created by akalanitski on 08.12.2016.
 */
package com.pomodairo.date {
public class DateUtil {

    public static const MONTH_NAME:Vector.<String> = new <String>["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    public static const MONTH_SIZE:Vector.<uint> = new <uint>[       31,    28,    31,    30,    31,    30,    31,    31,    30,    31,    30,    31];

    public static function getMontNames():Vector.<String> {
        return MONTH_NAME.slice();
    }

    public static function isLeapYear(date:Date):Boolean {
        var result:Boolean = (date.fullYear % 4 == 0) && (date.fullYear % 100 != 0);
        return result;
    }

    public static function getMonthSizeByDate(date:Date):Vector.<uint> {
        var result:Vector.<uint> = MONTH_SIZE.slice();
        if (isLeapYear(date)) {
            result[1] += 1;
        }
        return result;
    }

    public static function substract(date1:Date,  date2:Date):TimeSpan {
        return new TimeSpan(date1.time - date2.time);
    }

    public static function clone(source:Date):Date {
        var result:Date = new Date();
        result.time = source.time;
        return result;
    }

    public static function add(date:Date, timeSpan:TimeSpan):Date {
        var result:Date = new Date(date.time + timeSpan.time);
        return result;
    }
}
}
