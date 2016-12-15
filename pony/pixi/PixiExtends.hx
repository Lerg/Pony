/**
* Copyright (c) 2012-2016 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
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
package pony.pixi;

import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.extras.BitmapText;
import pixi.filters.blur.BlurFilter;
import pixi.filters.color.ColorMatrixFilter;

/**
 * PixijsExtends
 * @author AxGord <axgord@gmail.com>
 */
class PixiExtends {

	@:extern inline public static function loaded(s:Sprite, f:Void->Void):Void {
		PixiExtendsTexture.loaded(s.texture, f);
	}
	
	public static function loadedList(a:Array<Sprite>, f:Void->Void):Void {
		var i = a.length;
		if (i == 0) f();
		else for (s in a) loaded(s, function() if (--i == 0) f());
	}
	
	@:extern inline public static function darkness(c:ColorMatrixFilter, v:Float):Void {
		c.matrix = [v, 0, 0, 0, 0, 0, v, 0, 0, 0, 0, 0, v, 0, 0, 1];
	}
	
	@:extern inline public static function darknessFilter(v:Float):ColorMatrixFilter {
		var c = new ColorMatrixFilter();
		darkness(c, v);
		return c;
	}
	
	@:extern inline public static function blurFilter():BlurFilter {
		var b = new BlurFilter();
		b.passes = 3;
		return b;
	}
	
	public static function childLevel(s:Sprite, lvl:Int):Sprite {
		for (_ in 0...lvl) s = cast s.getChildAt(0);
		return s;
	}
	
	@:extern inline public static function flipX(o:Sprite):Void o.scale.x = -o.scale.x;
	@:extern inline public static function flipY(o:Sprite):Void o.scale.y = -o.scale.y;
	@:extern inline public static function flipXpos(o:Sprite):Void o.x += o.width;
	@:extern inline public static function flipYpos(o:Sprite):Void o.y += o.height;

	
}

/**
 * PixijsExtendsTexture
 * @author AxGord <axgord@gmail.com>
 */
class PixiExtendsTexture {
	
	public static function loaded(t:Texture, f:Void->Void):Void {
		if (t.baseTexture.hasLoaded) f();
		else t.baseTexture.once('loaded', function(_) f());
	}
	
}

/**
 * PixijsExtendsText
 * @author AxGord <axgord@gmail.com>
 */
class PixiExtendsText {
	
	public static function glow(t:Text, blur:Int=10, ?color:Null<UInt>):Text {
		var f = new BlurFilter();
		f.blur = blur;
		var s:TextStyle = Reflect.copy(t.style);
		if (color != null) s.fill = color;
		var ct = new Text(t.text, s);
		ct.x = t.x;
		ct.y = t.y;
		ct.filters = [f];
		return ct;
	}
	
}/**
 * PixijsExtendsBitmapText
 * @author AxGord <axgord@gmail.com>
 */
class PixiExtendsBitmapText {
	
	public static function glow(t:BitmapText, style:BitmapTextStyle, blur:Int=10, ?color:Null<UInt>):BitmapText {
		var f = new BlurFilter();
		f.blur = blur;
		var s:BitmapTextStyle = Reflect.copy(style);
		if (color != null) s.tint = color;
		var ct = new BitmapText(t.text, s);
		ct.x = t.x;
		ct.y = t.y;
		ct.filters = [f];
		return ct;
	}
	
}