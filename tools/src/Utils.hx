package;
import haxe.xml.Fast;
import sys.io.File;

/**
 * Share
 * @author AxGord <axgord@gmail.com>
 */
class Utils {
	
	public static inline var MAIN_FILE:String = 'pony.xml';
	
	public static inline var XML_REMSP_LEFT:String = '{REMSP_LEFT}';
	public static inline var XML_REMSP_RIGHT:String = '{REMSP_RIGHT}';

	public static function parseArgs(args:Array<String>):AppCfg {
		var debug = args.indexOf('debug') != -1;
		var app:String = null;
		for (a in args) if (a != 'debug' && a != 'release') {
			app = a;
			break;
		}
		return {app: app, debug:debug};
	}
	
	public static function getXml():Fast return new Fast(Xml.parse(File.getContent(MAIN_FILE))).node.project;
	
	public static function error(message:String, errCode:Int = 1):Void {
		Sys.println(message);
		Sys.exit(errCode);
	}

	public static function saveJson(file:String, jdata:Dynamic):Void {
		var tdata = haxe.Json.stringify(jdata, '\n');
		while (true) {
			var ndata = StringTools.replace(tdata, '\n\n', '\n');
			if (ndata == tdata) {
				tdata = ndata;
				break;
			} else {
				tdata = ndata;
			}
		}
		File.saveContent(file, tdata);
		Sys.println('$file saved');
	}

	public static function saveXML(file:String, xml:Xml):Void {
		var doc = Xml.createDocument();
		doc.addChild(Xml.createProcessingInstruction('xml version="1.0" encoding="utf-8"'));
		doc.addChild(xml);
		var r = haxe.xml.Printer.print(doc, true);
		
		var a = r.split(XML_REMSP_LEFT);
		r = '';
		for (e in a) r += e.substring(0, e.lastIndexOf('>') + 1);
		a = r.split(XML_REMSP_RIGHT);
		r = '';
		for (e in a) r += e.substring(e.indexOf('<'));

		File.saveContent(file, r);
	}

	public static function savePonyProject(xml:Xml):Void saveXML(MAIN_FILE, xml);

	public static function xmlData(data:String):Xml {
		return Xml.createPCData(XML_REMSP_LEFT + data + XML_REMSP_RIGHT);
	}

	public static function xmlSimple(v:String, data:String):Xml {
		var e = Xml.createElement(v);
		e.addChild(Utils.xmlData(data));
		return e;
	}
	
}