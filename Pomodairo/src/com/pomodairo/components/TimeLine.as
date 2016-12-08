/**
 * Created by akalanitski on 07.12.2016.
 */
package com.pomodairo.components {
import com.pomodairo.EmbedStyle;
import com.pomodairo.date.DateUtil;
import com.pomodairo.date.DateUtil;
import com.pomodairo.date.DateUtil;
import com.pomodairo.date.TimeSpan;

import flash.display.Bitmap;

import flash.display.BitmapData;

import flash.events.Event;

import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Mouse;
import flash.ui.MouseCursor;

import mx.controls.DateChooser;

import mx.core.UIComponent;
import mx.managers.CursorManager;

[Event(name="timelineValueChanged", type="flash.events.Event")]

[Event(name="timelineValueCommited", type="flash.events.Event")]

public class TimeLine extends UIComponent {

    public static const MONTH_LABEL_HEIGHT:uint = 12;

    public static const CHANGD:String = "timelineValueChanged";
    public static const COMMITED:String = "timelineValueCommited";

    public static const SCALE_TASK:String = "task";
    public static const SCALE_DAY:String = "day";
    public static const SCALE_WEEK:String = "week";

    private var monthNameBitmap:Vector.<BitmapData>;
    private var yearBitmap:BitmapData;
    private var tf:TextField = new TextField();


    public function TimeLine() {
        _lastDay = new Date();
        var today:Date = new Date();
        var names:Vector.<String> = DateUtil.getMontNames();
        var sizes:Vector.<uint> = DateUtil.getMonthSizeByDate(today);

        today.date -= 30;
        _dateCount = 30;
        _cursorDate = today;

        addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

        tf.defaultTextFormat = new TextFormat("_sans", 8, EmbedStyle.BACKGROUND_COLOR, true);
        tf.autoSize = TextFieldAutoSize.LEFT;

        monthNameBitmap = new Vector.<BitmapData>(12);
        for (var i:int = 0; i < sizes.length; i++) {
            tf.text = names[i];
            monthNameBitmap[i] = new BitmapData(sizes[i] - 2, MONTH_LABEL_HEIGHT, false, EmbedStyle.COMMON_TEXT_COLOR);
            monthNameBitmap[i].draw(tf, new Matrix(1, 0, 0, 1, 0, 0));
        }
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

    private var _lastDay:Date;
    private var _firstDay:Date;
    private var _cursorDate:Date;
    private var _cursorDateBeforeDrag:Date;
    private var _dateCount:int;

    public function get startDate():Date {
        return _cursorDate;
    }

    public function get dateCount():int {
        return _dateCount;
    }


    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        if (unscaledWidth > 0 && unscaledHeight > 0) {
            _firstDay = DateUtil.add(_lastDay, TimeSpan.fromDays(-unscaledWidth))
            drawBackground();
        }
    }

    /**
     * offset of cursor date in pixels from right border.
     */
    private function get cursorX():int {
        var delta:int = DateUtil.substract(_lastDay, startDate).day;
        var result:int = unscaledWidth - delta;
        return result;
    }

    /**
     * date range in pixels
     */
    private function get cursorWidth():int {
        return _dateCount;
    }

    private function drawBackground():void {
        var today:Date = new Date();
        graphics.clear();

        // draw timeline
        for (var i:int = 0; i < unscaledWidth; i++) {
            var yPosition:Number = 2;
            var xPosition:Number = unscaledWidth - i;
            var stickHeight:Number = unscaledHeight - 4;
            var color:uint = EmbedStyle.BACKGROUND_COLOR;

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
                graphics.beginBitmapFill(bmd, new Matrix(1, 0, 0, 1, xPosition, yPosition), false);
                graphics.drawRect(xPosition, yPosition, bmd.width, bmd.height);
                if (today.month == 0) {
                    tf.text = today.fullYear.toString();
                    yearBitmap = new BitmapData(29, 12, false, EmbedStyle.COMMON_TEXT_COLOR);
                    yearBitmap.draw(tf, new Matrix(1, 0, 0, 1, 0, 0));

                    graphics.beginBitmapFill(yearBitmap, new Matrix(1, 0, 0, 1, xPosition, yPosition + MONTH_LABEL_HEIGHT), false);
                    graphics.drawRect(xPosition, yPosition + MONTH_LABEL_HEIGHT, yearBitmap.width, yearBitmap.height);
                }
            }
        }

        //Draw selected range and update cursorDate
        if (_isDrag) {
            moveBy(mouseStageX - mouseDownX);
            graphics.beginFill(0xFFFF00, 0.5);
            dispatchEvent(new Event(CHANGD));
        }

        graphics.beginFill(0xFFFF00, 0.5);
        graphics.drawRect(cursorX, 0, cursorWidth, unscaledHeight);

        //Draw cursor
        if (!isNaN(mouseStageX) && !isNaN(mouseStageY)) {
            var p:Point = this.globalToLocal(new Point(mouseStageX, mouseStageY));
            graphics.beginFill(0xFFFF00);
            graphics.drawRect(p.x, 0, 1, unscaledHeight);
        }
    }

    private function moveBy(deltaDays:int):void {
        var dStart:Date = DateUtil.add(_cursorDateBeforeDrag, TimeSpan.fromDays(deltaDays));
        var dEnd:Date = DateUtil.add(_cursorDateBeforeDrag, TimeSpan.fromDays(deltaDays + _dateCount));
        var delta:int = DateUtil.substract(_lastDay, dEnd).day;
        if (delta < 0) {
            _cursorDate = DateUtil.add(_lastDay, TimeSpan.fromDays(-_dateCount));
            return;
        }
        delta = DateUtil.substract(dStart, _firstDay).day;
        if (delta < 0) {
            _cursorDate = _firstDay;
            return;
        }
        _cursorDate = dStart;
    }


    private var mouseStageX:Number = NaN;
    private var mouseStageY:Number = NaN;
    private var mouseDownX:Number = NaN;
    private var _isDrag:Boolean = false;

    private function mouseInRange():Boolean {
        var localPoint = this.globalToLocal(new Point(mouseStageX, mouseStageY));
        var result:Boolean = localPoint.x > cursorX && localPoint.x < (cursorX + cursorWidth);
        return result;
    }

    private function mouseUpHandler(event:MouseEvent):void {
        mouseDownX = NaN;
        _isDrag = false;
        _cursorDateBeforeDrag = null;
        dispatchEvent(new Event(COMMITED));
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseDownHandler(event:MouseEvent):void {
        mouseDownX = event.stageX;
        _isDrag = false;
        _cursorDateBeforeDrag = null;
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseOverHandler(event:MouseEvent):void {
        mouseStageX = event.stageX;
        invalidateDisplayList();

        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }

    private function mouseMoveHandler(event:MouseEvent):void {
        mouseStageX = event.stageX;

        var dx:Number = 0;
        if (!isNaN(mouseDownX)) {
            dx = Math.abs(mouseStageX - mouseDownX);
        }
        if (mouseInRange()) {
            Mouse.cursor = MouseCursor.HAND;
            if (dx > 4 && !_isDrag) {
                _isDrag = true;
                _cursorDateBeforeDrag = DateUtil.clone(_cursorDate);
            }
        } else {
            Mouse.cursor = MouseCursor.BUTTON;
        }
        invalidateDisplayList();
    }

    private function mouseOutHandler(event:MouseEvent):void {
        mouseStageX = NaN;
        invalidateDisplayList();

        removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }
}
}
