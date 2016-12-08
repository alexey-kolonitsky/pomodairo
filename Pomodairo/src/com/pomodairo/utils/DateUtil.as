/**
 * Created by akalanitski on 08.12.2016.
 */
package com.pomodairo.utils {
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


    public static function getDaysBetweenDates(date1:Date,  date2:Date):int
    {
        var one_day:Number = 1000 * 60 * 60 * 24;
        var date1_ms:Number = date1.getTime();
        var date2_ms:Number = date2.getTime();
        var difference_ms:Number = Math.abs(date1_ms - date2_ms);
        return Math.round(difference_ms/one_day);
    }
}
}
