package pony.ui.xml;

import h3d.Vector;
import h2d.Font;
import h2d.Scene;
import h2d.Object;
import h2d.Drawable;
import h2d.Graphics;
import h2d.Text;
import pony.magic.HasAbstract;
import pony.geom.Point;
import pony.geom.Border;
import pony.geom.Align;
import pony.geom.Rect;
import pony.color.UColor;
import pony.heaps.HeapsApp;
import pony.heaps.HeapsAssets;
import pony.heaps.ui.gui.Node;
import pony.heaps.ui.gui.NodeBitmap;
import pony.heaps.ui.gui.NodeRepeat;
import pony.heaps.ui.gui.Button;
import pony.heaps.ui.gui.slices.Slice;
import pony.heaps.ui.gui.layout.IntervalLayout;
import pony.heaps.ui.gui.layout.RubberLayout;
import pony.heaps.ui.gui.layout.AlignLayout;
import pony.heaps.ui.gui.layout.BGLayout;
import pony.heaps.ui.gui.layout.BaseLayout;
import pony.ui.xml.UiTags;
import pony.ui.xml.AttrVal;
import pony.ui.gui.BaseLayoutCore;

using pony.text.TextTools;

/**
 * HeapsXmlUi
 * @author AxGord <axgord@gmail.com>
 */
#if !macro
@:autoBuild(pony.ui.xml.XmlUiBuilder.build({
	node: h2d.Drawable,
	rect: h2d.Graphics,
	line: h2d.Graphics,
	circle: h2d.Graphics,
	text: h2d.Text,
	image: pony.heaps.ui.gui.NodeBitmap,
	tile: pony.heaps.ui.gui.NodeRepeat,
	slice: pony.heaps.ui.gui.Node,
	layout: pony.heaps.ui.gui.layout.TLayout
}))
#end
class HeapsXmlUi extends Scene implements HasAbstract {
	
	private static inline var HALF:Float = 0.5;
	private static var fonts:Map<String, Font> = new Map();
	private static var DYNS:Array<AttrVal> = [dynX, dynY, dynWidth, dynHeight, dyn];

	private var SCALE:Float = 1;
	public var app(default, null):HeapsApp;
	private var watchList:Array<Pair<Object, Dynamic<String>>> = [];
	
	private function createUIElement(name:String, attrs:Dynamic<String>, content:Array<Dynamic>):Dynamic {
		if (attrs.reverse.isTrue()) content.reverse();
		var obj:Object = switch name {
			case UiTags.node:
				var s:Object = new Object();
				for (e in content) s.addChild(e);
				s;
			case UiTags.rect:
				var color:UColor = UColor.fromString(attrs.color);
				var g:Graphics = new Graphics();
				g.beginFill(color.rgb, color.invertAlpha.af);
				if (attrs.round == null)
					g.drawRect(0, 0, parseAndScale(attrs.w), parseAndScale(attrs.h));
				else
					g.drawRoundedRect(0, 0, parseAndScale(attrs.w), parseAndScale(attrs.h), parseAndScaleInt(attrs.round));
				g.endFill();
				g;
			case UiTags.line:
				var color:UColor = UColor.fromString(attrs.color);
				var g:Graphics = new Graphics();
				g.lineStyle(parseAndScale(attrs.size), color.rgb, color.invertAlpha.af);
				g.moveTo(0, 0);
				g.lineTo(parseAndScale(attrs.w), parseAndScale(attrs.h));
				g;
			case UiTags.circle:
				var g = new Graphics();
				if (attrs.line != null) {
					var a = attrs.line.split(' ');
					if (a[0].charAt(0) == '#') a.unshift(a.pop());
					var lsize:Float = parseAndScale(a[0]);
					var lcolor = UColor.fromString(a[1]);
					g.lineStyle(lsize, lcolor.rgb, lcolor.invertAlpha.af);
				} else {
					g.lineStyle();
				}
				if (attrs.color != null) {
					var color = UColor.fromString(attrs.color);
					g.beginFill(color.rgb, color.invertAlpha.af);
				}
				g.drawCircle(0, 0, parseAndScale(attrs.r));
				g.endFill();
				g;
			case UiTags.image:
				Slice.create(
					HeapsAssets.animation(attrs.src, attrs.name),
					attrs.name == null ? attrs.src : attrs.name,
					attrs.repeat.isTrue()
				);
			case UiTags.layout:
				createLayout(attrs, content);
			case UiTags.text:
				createText(attrs, content);
			case UiTags.button:
				new Button(cast content);
			case _:
				customUIElement(name, attrs, content);
		}
		if (Std.is(obj, Node)) setNodeAttrs(cast obj, attrs);
		if (attrs.x != null) obj.x = parseAndScale(attrs.x);
		if (attrs.y != null) obj.y = parseAndScale(attrs.y);
		if (attrs.visible.isFalse()) obj.visible = false;
		if (attrs.alpha != null) obj.alpha = Std.parseFloat(attrs.alpha);
		if (attrs.scale != null) {
			var a:Array<String> = attrs.scale.split(' ');
			if (a.length == 1) {
				obj.scale(Std.parseFloat(a[0]));
			} else {
				obj.scaleX = Std.parseFloat(a[0]);
				obj.scaleY = Std.parseFloat(a[1]);
			}
		}
		if (attrs.tint != null) {
			var c:UColor = attrs.tint;
			cast(obj, Drawable).color = Vector.fromColor(c.rgb);
		}
		setWatchers(obj, attrs);
		return obj;
	}

	private function getWhPoint(v:String):Point<Float> {
		if (v != null) {
			v = StringTools.trim(v);
			return switch v {
				case AttrVal.stage:
					app.canvas.stageInitSize;
				case AttrVal.dyn:
					new Point(app.canvas.dynStage.width, app.canvas.dynStage.height);
				case _:
					var a:Array<Float> = v.split(' ').map(parseAndScaleWithoutNull);
					new Point(a[0], a.length == 1 ? a[0] : a[1]);
			}
		} else {
			return null;
		}
	}

	@:extern private inline function setNodeAttrs(node:Node, attrs:Dynamic<String>):Void {
		var w:Float = null;
		var h:Float = null;
		var p:Point<Float> = getWhPoint(attrs.wh);
		if (p != null) {
			w = p.x;
			h = p.y;
		}
		if (attrs.w != null)
			w = parseAndScaleWithoutNull(attrs.w);
		if (attrs.h != null)
			h = parseAndScaleWithoutNull(attrs.h);
		if (w != null && h != null)
			node.wh = new Point(w, h);
		else if (w != null)
			node.w = w;
		else if (h != null)
			node.h = h;
		
		if (attrs.flipx.isTrue()) node.flipx = true;
		if (attrs.flipy.isTrue()) node.flipy = true;
	}

	@:extern private inline function createText(attrs:Dynamic<String>, content:Array<Dynamic>):Object {
		var t:Text = new Text(getFont(attrs));
		if (attrs.color != null)
			t.textColor = UColor.fromString(attrs.color).rgb;
		if (attrs.align != null)
			t.textAlign = h2d.Text.Align.createByName(TextTools.bigFirst(attrs.align));
		if (attrs.shadow != null && attrs.shadow.length > 0) {
			var a:Array<String> = StringTools.trim(attrs.shadow).split(' ');
			var color:UColor = 0;
			if (a[0].charAt(0) == '#')
				color = a.shift();
			else if (a[a.length - 1].charAt(0) == '#')
				color = a.pop();
			var dx:Int = null;
			var dy:Int = null;
			if (a.length > 0)
				dy = Std.parseInt(a.pop());
			if (a.length > 0) {
				dx = Std.parseInt(a.pop());
			} else {
				if (dx == null)
					dx = 4;
				dy = dx;
			}
			t.dropShadow = {dx: dx, dy: dy, color: color.rgb, alpha: color.invertAlpha.af};
		}
		if (attrs.smooth.isTrue())
			t.smooth = true;
		t.text = textTransform(_putData(content), attrs.transform);
		return t;
	}

	@:extern private inline function createLayout(attrs:Dynamic<String>, content:Array<Dynamic>):Object {
		var align = Align.fromString(attrs.align);
		return if (attrs.src != null) {
			var l = new BGLayout(HeapsAssets.image(attrs.src, attrs.name), attrs.vert.isTrue(), scaleBorderInt(attrs.border));
			for (e in content) l.add(e);
			l;
		} else if (attrs.iv != null) {
			var l = new IntervalLayout(parseAndScaleInt(attrs.iv), true, scaleBorderInt(attrs.border), align);
			for (e in content) l.add(e);
			l;
		} else if (attrs.ih != null) {
			var l = new IntervalLayout(parseAndScaleInt(attrs.ih), false, scaleBorderInt(attrs.border), align);
			for (e in content) l.add(e);
			l;
		} else if (attrs.w != null || attrs.h != null) {
			var r = new RubberLayout(
				parseAndScale(attrs.w),
				parseAndScale(attrs.h),
				attrs.vert.isTrue(),
				scaleBorderInt(attrs.border),
				attrs.padding == null ? true : attrs.padding.isTrue(),
				align
			);
			for (e in content) r.add(e);
			r;
		} else if (attrs.wh != null) {
			var p:Point<Float> = getWhPoint(attrs.wh);
			var r = new RubberLayout(
				p.x,
				p.y,
				attrs.vert.isTrue(),
				scaleBorderInt(attrs.border),
				attrs.padding == null ? true : attrs.padding.isTrue(),
				align
			);
			for (e in content) r.add(e);
			r;
		} else {
			var s = new AlignLayout(align, scaleBorderInt(attrs.border));
			for (e in content) s.add(e);
			s;
		}
	}

	private static function textTransform(text:String, transform:String):String {
		return switch transform {
			case 'uppercase': text.toUpperCase();
			case 'lowercase': text.toLowerCase();
			case _: text;
		}
	}

	@:extern private inline function parseSizePointFloat(a:Dynamic<String>):Point<Float> {
		return new Point<Float>(parseAndScale(a.w), parseAndScale(a.h));
	}
	
	private inline function parseFloat(s:String):Float {
		return s == null ? 0 : Std.parseFloat(s);
	}

	private inline function parseAndScaleWithoutNull(s:String):Float {
		return switch s {
			case AttrVal.stageWidth:
				app.canvas.stageInitSize.x;
			case AttrVal.stageHeight:
				app.canvas.stageInitSize.y;
			case AttrVal.dynWidth:
				app.canvas.dynStage.width;
			case AttrVal.dynHeight:
				app.canvas.dynStage.height;
			case AttrVal.dynX:
				app.canvas.dynStage.x;
			case AttrVal.dynY:
				app.canvas.dynStage.y;
			case _:
				Std.parseFloat(s) * SCALE;
		}
	}
	
	private inline function parseAndScale(s:String):Float {
		return s == null ? 0 : parseAndScaleWithoutNull(s);
	}
	
	inline function parseAndScaleInt(s:String):Int {
		return s == null ? 0 : Std.int(Std.parseInt(s) * SCALE);
	}
	
	@:extern private inline function scaleBorderInt(s:String):Border<Int> return cast (Border.fromString(s) * SCALE);

	private function getFont(attrs:Dynamic<String>):Font {
		var name:String = attrs.src;
		var cacheName:String = name;
		var size:Int = parseAndScaleInt(attrs.size);
		if (size != 0) cacheName += size;
		var font:Font = fonts[cacheName];
		if (font != null) return font;
		font = HeapsAssets.font(attrs.src).clone();
		HeapsAssets.setFontType(font, attrs.type);
		if (size != 0) font.resizeTo(size);
		fonts[cacheName] = font;
		return font;
	}

	private function _putData(content:Array<Dynamic>):String return putData(content.length > 0 ? content[0] : '');
	private function putData(c:String):String return c;
	private function customUIElement(name:String, attrs:Dynamic<String>, content:Array<Dynamic>):Dynamic throw 'Unknown component $name';
	
	private static function splitAttr(s:String):Array<String> {
		return s.split(',').map(StringTools.trim).map(function(v):String return v == '' ? null : v);
	}
	
	@:abstract private function _createUI():Object return null;
	
	private function createUI(?app:HeapsApp, scale:Float = 1):Void {
		if (this.app == null)
			this.app = app == null ? HeapsApp.instance : app;
		SCALE = scale;
		addChild(_createUI());
		this.app.canvas.onDynStageResize << dynStageHandler;
	}

	private function createFilters(data:Dynamic<Dynamic<String>>):Void {}

	private function setWatchers(obj:Object, attrs:Dynamic<String>):Void {
		var na:Dynamic<String> = {};
		var founded:Bool = false;
		for (f in Reflect.fields(attrs)) {
			var a = StringTools.trim(Reflect.field(attrs, f));
			if (checkInDyns(a)) {
				Reflect.setField(na, f, a);
				founded = true;
			}
		}
		if (founded) {
			watchList.push(new Pair(obj, na));
		}
	}

	private static inline function checkInDyns(v:String):Bool return DYNS.indexOf(v) != -1;

	private function dynStageHandler(r:Rect<Float>):Void {
		watchList = watchList.filter(watchFilter);
		for (e in watchList) {
			for (f in Reflect.fields(e.b)) {
				var a = Reflect.field(e.b, f);
				switch a {
					case dyn:
						var p:Point<Float> = new Point(r.width, r.height);
						if (Std.is(e.a, BaseLayout)) {
							var o:BaseLayout<Dynamic> = cast e.a;
							o.wh = p;
						} else if (Std.is(e.a, Node)) {
							var o:Node = cast e.a;
							o.wh = p;
						} else {
							Reflect.setProperty(e.a, f, p);
						}
					case dynWidth:
						if (Std.is(e.a, BaseLayout)) {
							var o:BaseLayout<Dynamic> = cast e.a;
							o.w = r.width;
						} else {
							Reflect.setProperty(e.a, f, r.width);
						}
					case dynHeight:
						if (Std.is(e.a, BaseLayout)) {
							var o:BaseLayout<Dynamic> = cast e.a;
							o.h = r.height;
						} else {
							Reflect.setProperty(e.a, f, r.height);
						}
					case dynX:
						Reflect.setProperty(e.a, f, r.x);
					case dynY:
						Reflect.setProperty(e.a, f, r.y);
					case _:
				}
				
			}
		}
	}

	private function watchFilter(p:Pair<Object, Dynamic<String>>):Bool {
		return p.a.parent != null;
	}

}
