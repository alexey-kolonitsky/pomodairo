/**
 * Created by akalanitski on 07.12.2016.
 */
package com.pomodairo.components {
import com.pomodairo.EmbedStyle;
import com.pomodairo.utils.DateUtil;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import mx.controls.DateChooser;

import mx.core.UIComponent;

[Event(name="timelineValueChanged", type="flash.events.Event")]

[Event(name="timelineValueCommited", type="flash.events.Event")]

public class TimeLine extends UIComponent {

    public static const CHANGD:String = "timelineValueChanged";
    public static const COMMITED:String = "timelineValueCommited";

    public static const SCALE_TASK:String = "task";
    public static const SCALE_DAY:String = "day";
    public static const SCALE_WEEK:String = "week";

    private var cursorPoint:Number = NaN;
    private var mouseDownPoint:Number = NaN;

    private var monthNameBitmap:Vector.<BitmapData>;
    private var yearBitmap:BitmapData;
    private var tf:TextField = new TextField();


    public function TimeLine() {
        var today:Date = new Date();
        today.date -= 30;
        _dateCount = 30;
        _startDate = today;
        addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

        tf.defaultTextFormat = new TextFormat("_sans", 8, EmbedStyle.BACKGROUND_COLOR, true);
        tf.autoSize = TextFieldAutoSize.LEFT;

        var names:Vector.<String> = DateUtil.getMontNames();
        var sizes:Vector.<uint> = DateUtil.getMonthSizeByDate(today);

        monthNameBitmap = new Vector.<BitmapData>(12);
        for (var i:int = 0; i < sizes.length; i++) {
            tf.text = names[i];
            monthNameBitmap[i] = new BitmapData(sizes[i] - 2, 12, false, EmbedStyle.COMMON_TEXT_COLOR);
            monthNameBitmap[i].draw(tf, new Matrix(1, 0, 0, 1, 0, 0));
        }
    }

    private function mouseUpHandler(event:MouseEvent):void {
        mouseDownPoint = NaN;
        dispatchEvent(new Event(COMMITED));
    }

    private function mouseDownHandler(event:MouseEvent):void {
        mouseDownPoint = event.localX;
    }

    private function mouseOverHandler(event:MouseEvent):void {
        cursorPoint = event.localX;
        invalidateDisplayList();
    }

    private function mouseOutHandler(event:MouseEvent):void {
        cursorPoint = NaN;
        invalidateDisplayList();
    }

    private var _scale:String = SCALE_TASK;

    [Bindable]
    public function get scale():String {
        return _scale;
    }

    public function set scale(value:String):void {
        if (_scale == value) {
            return;
        }
        _scale = value;
        invalidateDisplayList();
    }

    private var _startDate:Date;
    private var _dateCount:int;

    public function get startDate():Date {
        return _startDate;
    }

    public function get dateCount():int {
        return _dateCount;
    }


    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (unscaledWidth > 0 && unscaledHeight > 0) {
            drawBackground();
        }
    }

    private function drawBackground():void {
        var today:Date = new Date();
        graphics.clear();
        for (var i:int = 0; i < unscaledWidth; i++) {
            var yPosition:Number = 0;
            var xPosition:Number = unscaledWidth - i;
            var stickHeight:Number = unscaledHeight;
            var color:uint = EmbedStyle.SECTION_BACKGROUND_COLOR;

            if (today.day == 5 || today.day == 6) {
                color = EmbedStyle.LIST_OVER_BACKGROUND;
            }
            if (today.date == 1) {
                color = EmbedStyle.COMMON_TEXT_COLOR;
                if (today.month == 0) {
                    color = EmbedStyle.BACKGROUND_COLOR;
                }
            }

            today.date--;
            trace(today.fullYear + "-" + today.month + "-" + today.date + " ");
            graphics.beginFill(color);
            graphics.drawRect(xPosition, yPosition, 1, stickHeight);
            if (today.date == 1) {
                var bmd:BitmapData = monthNameBitmap[today.month];
                graphics.beginBitmapFill(bmd, new Matrix(1, 0, 0, 1, xPosition, 0), false);
                graphics.drawRect(xPosition, 0, bmd.width, bmd.height);
                if (today.month == 0) {
                    tf.text = today.fullYear.toString();
                    yearBitmap = new BitmapData(29, 12, false, EmbedStyle.COMMON_TEXT_COLOR);
                    yearBitmap.draw(tf, new Matrix(1, 0, 0, 1, 0, 0));

                    graphics.beginBitmapFill(yearBitmap, new Matrix(1, 0, 0, 1, xPosition, 12), false);
                    graphics.drawRect(xPosition, 12, yearBitmap.width, yearBitmap.height);
                }
            }

        }

        //Draw selected range
        if (!isNaN(mouseDownPoint) && !isNaN(cursorPoint)) {
            var x:Number  = Math.min(cursorPoint, mouseDownPoint);
            var w:Number = Math.abs(cursorPoint - mouseDownPoint);
            var delta:int = unscaledWidth- x;
            today = new Date();
            today.date -= delta;
            _startDate = today;
            _dateCount = w;
            graphics.beginFill(0xFFFF00, 0.5);
            graphics.drawRect(x, 0, w, unscaledHeight);
            dispatchEvent(new Event(CHANGD));
        } else {
            today = new Date();
            var delta:int = DateUtil.getDaysBetweenDates(today, startDate);
            var x:Number = unscaledWidth - delta;
            var w:Number = _dateCount;
            graphics.beginFill(0xFFFF00, 0.5);
            graphics.drawRect(x, 0, w, unscaledHeight);
        }

        //Draw cursor
        if (!isNaN(cursorPoint)) {
            graphics.beginFill(0xFFFF00);
            graphics.drawRect(cursorPoint, 0, 1, unscaledHeight);
        }
    }
}
}
