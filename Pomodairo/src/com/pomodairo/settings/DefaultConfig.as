/**
 * Created by akalanitski on 10.12.2016.
 */
package com.pomodairo.settings {
import com.pomodairo.date.TimeSpan;

public class DefaultConfig {
    public static const POMODORO_TIME:TimeSpan = TimeSpan.fromMinutes(25);
    public static const BREAK_TIME:TimeSpan = TimeSpan.fromMinutes(5);
    public static const LONG_BREAK_TIME:TimeSpan = TimeSpan.fromMinutes(30);


    // Window settings
    public static const MIN_WIDTH:Number = 320;

    public static const MINI_HEIGHT:Number = 52;
    public static const SHORT_HEIGHT:Number = 150;
    public static const FULL_HEIGHT:Number = SHORT_HEIGHT + 300;

    //
    public static const DEFAULT_SETTINGS_FILE_PATH:String = "assets/settings.properties";

    /** Database default file name  */
    public static var DATABASE_FILE:String = "pomodairo-1.1.db";

}
}
