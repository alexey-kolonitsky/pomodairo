/**
 * Created by akalanitski on 07.12.2016.
 */
package com.pomodairo.components {
import com.pomodairo.EmbedStyle;

import flash.events.Event;

import flash.events.MouseEvent;

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
                color = EmbedStyle.LIST_SELECT_BACKGROUND;
            }
            today.date--;
            trace(today.fullYear + "-" + today.month + "-" + today.date + " ");
            graphics.beginFill(color);
            graphics.drawRect(xPosition, yPosition, 1, stickHeight);
        }
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
            var delta:int = getDaysBetweenDates(today, startDate);
            var x:Number = unscaledWidth - delta;
            var w:Number = _dateCount;
            graphics.beginFill(0xFFFF00, 0.5);
            graphics.drawRect(x, 0, w, unscaledHeight);
        }

        if (!isNaN(cursorPoint)) {
            graphics.beginFill(0xFFFF00);
            graphics.drawRect(cursorPoint, 0, 1, unscaledHeight);
        }
    }

    public static function getDaysBetweenDates(date1:Date,date2:Date):int
    {
        var one_day:Number = 1000 * 60 * 60 * 24;
        var date1_ms:Number = date1.getTime();
        var date2_ms:Number = date2.getTime();
        var difference_ms:Number = Math.abs(date1_ms - date2_ms);
        return Math.round(difference_ms/one_day);
    }
}
}
