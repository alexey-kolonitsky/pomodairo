/**
 * Created by akalanitski on 02.12.2016.
 */
package com.pomodairo {
import flash.text.Font;
import flash.text.TextFormat;

public class EmbedStyle {

	public static const BACKGROUND_COLOR:uint = 0x292929;

	public static const LIST_OVER_BACKGROUND:uint = 0x555555;
	public static const LIST_SELECT_BACKGROUND:uint = 0x444444;

	public static const COMMON_TEXT_COLOR:uint = 0xCCCCCC;

	public static const POMODORO_ESTIMATED_COLOR:uint = 0xCCCCCC;
	public static const POMODORO_DONE_COLOR:uint = 0x009900;
	public static const POMODORO_UNPLANED_COLOR:uint = 0x66CCCC;
	public static const POMODORO_OVERFLOW_COLOR:uint = 0xCC0000;

	public static const SECTION_BACKGROUND_COLOR:uint = 0x404040;
	public static const SECTION_TEXT_COLOR:uint = 0xFFFFFF;


	//---------------------------------
	// Text style
	//---------------------------------

	public static const POMODORO_TIMER_COLOR:uint = 0xFFFF00;
	public static const POMODORO_BREACK_COLOR:uint = 0x00FF00;
	public static const POMODORO_TIMEOUT_COLOR:uint = 0xFF0000;

	[Embed(source="/assets/digital-7mono.ttf", fontName="Digital", mimeType="application/x-font-truetype", embedAsCFF="false", advancedAntiAliasing="true")]
	public static const DIGITAL_FONT_CLASS:Class;
	public static const DIGITAL_FONT_NAME:String = "Digital";

	public static function clockTextStyle():TextFormat {
		var result:TextFormat = new TextFormat(DIGITAL_FONT_NAME, 80);
		return result;
	}

	public static function miniClockTextStyle():TextFormat {
		var result:TextFormat = new TextFormat(DIGITAL_FONT_NAME, 27);
		return result;
	}


	//---------------------------------
	// API
	//---------------------------------

	public static function registerFonts():void {
		Font.registerFont(DIGITAL_FONT_CLASS);
	}

}
}
