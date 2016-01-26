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
package pony.geom;

/**
 * Align
 * @author AxGord <axgord@gmail.com>
 */
abstract Align(AlignType) from AlignType to AlignType {
	
	public var vertical(get, never):VAlign;
	public var horizontal(get, never):HAlign;

	
	@:extern inline public function new(v:AlignType) this = v;
	
	@:from @:extern inline public static function fromV(v:VAlign):Align {
		return new Pair(v, HAlign.Center);
	}
	
	@:from @:extern inline public static function fromH(v:HAlign):Align {
		return new Pair(VAlign.Middle, v);
	}
	
	@:to @:extern inline public function toV():VAlign return this.a;
	@:to @:extern inline public function toH():HAlign return this.b;
	
	@:extern inline private function get_vertical():VAlign return this.a;
	@:extern inline private function get_horizontal():HAlign return this.b;

	
}
 
typedef AlignType = Pair<VAlign, HAlign>;

enum VAlign {
	Top; Middle; Bottom;
}

enum HAlign {
	Left; Center; Right;
}