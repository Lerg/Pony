package module;

import pony.Fast;

import types.BASection;
import types.BmfontConfig;

/**
 * Bmfont module
 * @author AxGord <axgord@gmail.com>
 */
class Bmfont extends NModule<BmfontConfig> {

	private static inline var PRIORITY:Int = 19;

	public function new() super('bmfont');

	override public function init():Void initSections(PRIORITY, BASection.Prepare);

	override private function readNodeConfig(xml:Fast, ac:AppCfg):Void {
		new BmfontReader(xml, {
			debug: ac.debug,
			app: ac.app,
			before: false,
			section: BASection.Prepare,
			from: '',
			to: '',
			type: 'sdf', // msdf | sdf | psdf | svg
			format: 'xml', // xml | json | fnt
			font: [],
			distance: 2,
			padding: -1,
			allowCfg: true,
			cordova: false
		}, configHandler);
	}

	override private function writeCfg(protocol:NProtocol, cfg:Array<BmfontConfig>):Void protocol.bmfontRemote(cfg);

}

private class BmfontReader extends BAReader<BmfontConfig> {

	override private function readNode(xml:Fast):Void {
		switch xml.name {
			case 'font':
				cfg.font.push({
					file: StringTools.trim(xml.innerData),
					face: xml.has.face ? xml.att.face : null,
					size: Std.parseInt(xml.att.size),
					charset: xml.has.charset ? xml.att.charset : null,
					output: xml.has.output ? xml.att.output : null,
					lineHeight: xml.has.lineHeight ? Std.parseInt(xml.att.lineHeight) : null,
				});
			case _: super.readNode(xml);
		}
	}

	override private function clean():Void {
		cfg.from = '';
		cfg.to = '';
		cfg.type = 'sdf';
		cfg.format = 'xml';
		cfg.font = [];
		cfg.distance = 2;
		cfg.padding = -1;
	}

	override private function readAttr(name:String, val:String):Void {
		switch name {
			case 'from': cfg.from = val;
			case 'to': cfg.to = val;
			case 'type':
				cfg.type = val;
				if (val == 'msdf' && cfg.padding == -1)
					cfg.padding = 1;
			case 'format': cfg.format = val;
			case 'distance': cfg.distance = Std.parseInt(val);
			case 'padding': cfg.padding = Std.parseInt(val);
			case _:
		}
	}

}
