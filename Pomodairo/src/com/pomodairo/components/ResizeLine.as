/**
 * Created by akalanitski on 09.12.2016.
 */
package com.pomodairo.components {
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.core.WindowedApplication;

public class ResizeLine extends Canvas{

    [Bindable]
    public var app:WindowedApplication;

    private var clickX:Number;
    private var clickY:Number;
    private var isResizing:Boolean;
    private var windowOriginHeight:Number;

    private var cursorId:int;

    public function ResizeLine() {
        addEventListener(MouseEvent.MOUSE_DOWN, resizeLine_mouseDownHandler);
        addEventListener(MouseEvent.ROLL_OVER, resizeLine_rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, resizeLine_rollOutHandler);
    }

    private function stage_mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        clickX = 0.0;
        clickY = 0.0;
        windowOriginHeight = 0.0;
        isResizing = false;
        setDefaultCursor();
    }

    private function stage_mouseMoveHandler(event:MouseEvent):void {
        var dy:Number = event.stageY - clickY;
        if (dy * dy > 25 && isResizing == false) {
            isResizing = true;
            windowOriginHeight = app.nativeWindow.height;
        }

        if (isResizing) {
            app.nativeWindow.height = windowOriginHeight + dy;
        }
    }

    [Embed(source="/style/kingnarestyle.swf", symbol="DividedBox_verticalCursor")]
    public static const ResizeCursorClass:Class;

    private function resizeLine_rollOverHandler(event:MouseEvent):void {
        cursorId = cursorManager.setCursor(ResizeCursorClass);
    }

    private function resizeLine_rollOutHandler(event:MouseEvent):void {
        if (isResizing == false) {
            setDefaultCursor();
        }
    }

    private function resizeLine_mouseDownHandler(event:MouseEvent):void {
        clickX = event.stageX;
        clickY = event.stageY;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler)
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
    }

    private function setDefaultCursor():void {
        cursorManager.removeAllCursors();
        cursorId = -1;
    }
}
}
