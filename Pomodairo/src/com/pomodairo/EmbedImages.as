/**
 * Created by akalanitski on 02.12.2016.
 */
package com.pomodairo {
import flash.display.Bitmap;

public class EmbedImages {

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-145-folder-open.png")]
	public static const ICON_FOLDER_OPEN_CLASS:Class;
	public static const ICON_FOLDER_OPEN:Bitmap = new ICON_FOLDER_OPEN_CLASS() as Bitmap;

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-512-copy.png")]
	public static const ICON_COPY_CLASS:Class;
	public static const ICON_COPY:Bitmap = new ICON_COPY_CLASS() as Bitmap;

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-433-plus.png")]
	public static const ICON_PLUS_CLASS:Class;
	public static const ICON_PLUS:Bitmap = new ICON_PLUS_CLASS() as Bitmap;

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-68-cleaning.png")]
	public static const ICON_CLEANING_CLASS:Class;
	public static const ICON_CLEANING:Bitmap = new ICON_CLEANING_CLASS() as Bitmap;

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-174-play.png")]
	public static const ICON_PLAY_CLASS:Class;
	public static const ICON_PLAY:Bitmap = new ICON_PLAY_CLASS() as Bitmap;

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-176-stop.png")]
	public static const ICON_STOP_CLASS:Class;
	public static const ICON_STOP:Bitmap = new ICON_STOP_CLASS() as Bitmap;

	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-177-forward.png")]
	public static const ICON_FORWARD_CLASS:Class;
	public static const ICON_FORWARD:Bitmap = new ICON_FORWARD_CLASS() as Bitmap;

	/**
	 * Used as symbol of statistic window
	 */
	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-41-stats.png")]
	public static const ICON_STATS_CLASS:Class;
	public static const ICON_STATS:Bitmap = new ICON_STATS_CLASS() as Bitmap;

	/**
	 * Used as symbol of settings window
	 */
	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-140-adjust-alt.png")]
	public static const ICON_ADJUST_CLASS:Class;
	public static const ICON_ADJUST:Bitmap = new ICON_ADJUST_CLASS() as Bitmap;

	/**
	 * Used as symbol of task list
	 */
	[Embed(source="/assets/glyphicons/glyphicons_free/glyphicons/png/glyphicons-115-list.png")]
	public static const ICON_LIST_CLASS:Class;
	public static const ICON_LIST:Bitmap = new ICON_LIST_CLASS() as Bitmap;
}
}
