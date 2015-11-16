/**
* Copyright (c) 2012-2015 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
*
*   1. Redistributions of source code must retain the above copyright notice, this list of
*      conditions and the following disclaimer.
*
*   2. Redistributions in binary form must reproduce the above copyright notice, this list
*      of conditions and the following disclaimer in the documentation and/or other materials
*      provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY ALEXANDER GORDEYKO ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ALEXANDER GORDEYKO OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Alexander Gordeyko <axgord@gmail.com>.
**/
package pony.ui.touch;

import pony.events.Signal0;
import pony.events.Signal1;
import pony.magic.HasSignal;
import pony.TypedPool;

/**
 * Toucheble
 * @author AxGord <axgord@gmail.com>
 */
class TouchebleBase implements HasSignal {

	static private var touches:Map<Int, Touch> = new Map<Int, Touch>();
	static private var touchPool:TypedPool<Touch> = new TypedPool<Touch>();
	
	@:auto public var onOver:Signal1<Touch>;
	@:auto public var onOut:Signal1<Touch>;
	@:auto public var onOutUp:Signal1<Touch>;
	@:auto public var onOverDown:Signal1<Touch>;
	@:auto public var onOutDown:Signal1<Touch>;
	@:auto public var onDown:Signal1<Touch>;
	@:auto public var onUp:Signal1<Touch>;
	@:auto public var onClick:Signal0;
	
	public function new() {
		onDown << function() onUp < eClick;
		onOutUp << function() onUp >> eClick;
	}
	
	public function destroy():Void {
		eOver.destroy();
		eOut.destroy();
		eOutUp.destroy();
		eOverDown.destroy();
		eOutDown.destroy();
		eDown.destroy();
		eUp.destroy();
		eClick.destroy();
	}
	
	/**
	 * Use this method if object has moved
	 */
	public function check():Void {}
	
	private function dispatchDown(id:Int = 0, x:Float, y:Float, safe:Bool = false):Void {
		if (touches.exists(id)) 
			@:privateAccess touches[id].eDown.dispatch(touches[id].set(x, y));
		else
			touches[id] = @:privateAccess touchPool.get().set(x, y);
		eDown.dispatch(touches[id], safe);
	}
	
	private function dispatchUp(id:Int = 0, safe:Bool = false):Void {
		if (!touches.exists(id)) return;
		@:privateAccess touches[id].eUp.dispatch(touches[id]);
		eUp.dispatch(touches[id], safe);
	}
	
	private function dispatchOver(id:Int = 0, safe:Bool = false):Void {
		if (touches.exists(id)) 
			@:privateAccess touches[id].eOver.dispatch(touches[id]);
		else
			touches[id] = touchPool.get();
		eOver.dispatch(touches[id], safe);
	}
	
	private function dispatchOutDown(id:Int = 0, safe:Bool = false):Void {
		if (!touches.exists(id)) return;
		@:privateAccess touches[id].eOutDown.dispatch(touches[id]);
		eOutDown.dispatch(touches[id], safe);
	}
	
	private function dispatchOverDown(id:Int = 0, safe:Bool = false):Void {
		if (touches.exists(id)) 
			@:privateAccess touches[id].eOverDown.dispatch(touches[id]);
		else
			touches[id] = touchPool.get();
		eOverDown.dispatch(touches[id], safe);
	}
	
	private function dispatchOut(id:Int = 0, safe:Bool = false):Void {
		if (!touches.exists(id)) return;
		@:privateAccess touches[id].eOut.dispatch(touches[id]);
		eOut.dispatch(touches[id], safe);
		removeTouch(id);
	}
	
	private function dispatchOutUpListener(id:Int):Void dispatchOutUp(id);
	
	private function dispatchOutUp(id:Int = 0, safe:Bool = false):Void {
		if (touches.exists(id))
			@:privateAccess touches[id].eOutUp.dispatch(touches[id]);
		eOutUp.dispatch(touches[id], safe);
		removeTouch(id);
	}
	
	static private function dispatchMove(id:Int = 0, x:Float, y:Float):Void {
		if (touches.exists(id))
			@:privateAccess touches[id].eMove.dispatch(touches[id].set(x,y));
	}
	
	static private function removeTouch(id:Int):Void {
		if (id == 0 || !touches.exists(id)) return;
		touches[id].clear();
		touchPool.ret(touches[id]);
		touches.remove(id);	
	}
	
}