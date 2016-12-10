/**
 * Created by akalanitski on 10.12.2016.
 */
package com.pomodairo.components.config {
import com.pomodairo.date.TimeSpan;

public class DefaultConfig {
    public static const POMODORO_TIME:TimeSpan = TimeSpan.fromMinutes(25);
    public static const BREAK_TIME:TimeSpan = TimeSpan.fromMinutes(5);
    public static const LONG_BREAK_TIME:TimeSpan = TimeSpan.fromMinutes(30);

}
}
