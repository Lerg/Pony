package module;

import pony.Fast;
import pony.Logable;
import pony.Queue;
import pony.Tools;
import pony.events.Signal0;
import pony.magic.HasAbstract;
import pony.magic.HasLink;

import types.BASection;

/**
 * Module
 * @author AxGord <axgord@gmail.com>
 */
@:nullSafety(Strict) class Module extends Logable implements HasAbstract implements HasLink {

	@:auto public static var onEndQueue: Signal0;
	public static var busy(link, never): Bool = GLOBALQUEUE.busy;

	private static inline var CONFIG_PRIORITY: Int = -100;
	private static var GLOBALQUEUE: Queue<(Void -> Void) -> Void> = new Queue<(Void -> Void) -> Void>(globalRunNextRun);

	@:nullSafety(Off) public var modules: Modules;

	private var xml(get, never): Null<Fast>;
	#if (haxe_ver >= 4.000)
	private var nodes(get, never): Array<Fast>;
	#else
	private var nodes(get, never): List<Fast>;
	#end
	private var _xml: Null<Fast>;

	public var xname(default, null): Null<String>;

	private var currentSection: Null<BASection>;
	private var startTime: Float = 0;

	public function new(?xname: String) {
		super();
		this.xname = xname;
	}

	private function get_xml(): Null<Fast> {
		if (_xml == null) _xml = xname == null ? modules.xml : modules.getNode(xname);
		return _xml;
	}

	@:extern private inline function parseGroup(xml: Fast): Null<Array<String>> {
		if (xml != null && xml.has.group) {
			var r: Array<String> = xml.att.group.split(' ').filter(checkLength);
			return r.length > 0 ? r : null;
		} else {
			return null;
		}
	}

	private function checkLength(s: String): Bool return s.length > 0;

	#if (haxe_ver >= 4.000)
	private function get_nodes(): Array<Fast> {
		return xname == null ? [] : @:nullSafety(Off) modules.xml.nodes.resolve(xname);
	}
	#else
	private function get_nodes(): List<Fast> {
		return xname == null ? new List<Fast>() : @:nullSafety(Off) modules.xml.nodes.resolve(xname);
	}
	#end

	private static function globalRunNextRun(fn: Void -> Void): Void fn();
	public static function lockQueue(): Void GLOBALQUEUE.call(Tools.nullFunction0);
	public static function unlockQueue(): Void GLOBALQUEUE.next();

	private function addToRun(fn: Void -> Void): Void {
		GLOBALQUEUE.call(function(): Void {
			begin();
			fn();
		});
	}

	private function finishCurrentRun(): Void {
		end();
		GLOBALQUEUE.next();
		if (!GLOBALQUEUE.busy) eEndQueue.dispatch();
	}

	private function begin(): Void {
		log('Start $xname');
		startTime = Sys.time();
	}

	private function end(): Void {
		log('Complete $xname, time: ' + Std.int((Sys.time() - startTime) * 1000) / 1000);
	}

	@:abstract public function init(): Void;
	@:abstract private function runModule(before: Bool, section: BASection): Void;
	@:abstract private function readConfig(ac: AppCfg): Void;

	private function initSections(priority: Int, ?current: BASection): Void {
		currentSection = current;
		addConfigListener();
		addListeners(priority, moduleBefore, moduleAfter);
	}

	private function moduleBefore(section: BASection): Void runModule(true, section);
	private function moduleAfter(section: BASection): Void runModule(false, section);

	private function addConfigListener(): Void {
		modules.commands.onServer.once(emptyConfig, CONFIG_PRIORITY);
		modules.commands.onPrepare.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onBuild.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onCordova.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onAndroid.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onIphone.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onElectron.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onRun.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onZip.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onFtp.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onRemote.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onHash.once(getConfig, CONFIG_PRIORITY);
		modules.commands.onUnpack.once(getConfig, CONFIG_PRIORITY);
	}

	private function removeConfigListener(): Void {
		modules.commands.onServer >> emptyConfig;
		modules.commands.onPrepare >> getConfig;
		modules.commands.onBuild >> getConfig;
		modules.commands.onCordova >> getConfig;
		modules.commands.onIphone >> getConfig;
		modules.commands.onAndroid >> getConfig;
		modules.commands.onElectron >> getConfig;
		modules.commands.onRun >> getConfig;
		modules.commands.onZip >> getConfig;
		modules.commands.onFtp >> getConfig;
		modules.commands.onRemote >> getConfig;
		modules.commands.onHash >> emptyConfig;
		modules.commands.onUnpack >> emptyConfig;
	}

	private function addListeners(priority: Int, before: BASection -> Void, after: BASection -> Void): Void {
		modules.commands.onServer.once(before.bind(Server), CONFIG_PRIORITY + priority);
		modules.commands.onPrepare.once(before.bind(Prepare), CONFIG_PRIORITY + priority);
		modules.commands.onBuild.once(before.bind(Build), CONFIG_PRIORITY + priority);
		modules.commands.onCordova.once(before.bind(Cordova), CONFIG_PRIORITY + priority);
		modules.commands.onAndroid.once(before.bind(Android), CONFIG_PRIORITY + priority);
		modules.commands.onIphone.once(before.bind(Iphone), CONFIG_PRIORITY + priority);
		modules.commands.onElectron.once(before.bind(Electron), CONFIG_PRIORITY + priority);
		modules.commands.onRun.once(before.bind(Run), CONFIG_PRIORITY + priority);
		modules.commands.onZip.once(before.bind(Zip), CONFIG_PRIORITY + priority);
		modules.commands.onFtp.once(before.bind(Ftp), CONFIG_PRIORITY + priority);
		modules.commands.onRemote.once(before.bind(Remote), CONFIG_PRIORITY + priority);
		modules.commands.onHash.once(before.bind(Hash), CONFIG_PRIORITY + priority);
		modules.commands.onUnpack.once(before.bind(Unpack), CONFIG_PRIORITY + priority);

		modules.commands.onServer.once(after.bind(Server), priority);
		modules.commands.onPrepare.once(after.bind(Prepare), priority);
		modules.commands.onBuild.once(after.bind(Build), priority);
		modules.commands.onCordova.once(after.bind(Cordova), priority);
		modules.commands.onAndroid.once(after.bind(Android), priority);
		modules.commands.onIphone.once(after.bind(Iphone), priority);
		modules.commands.onElectron.once(after.bind(Electron), priority);
		modules.commands.onRun.once(after.bind(Run), priority);
		modules.commands.onZip.once(after.bind(Zip), priority);
		modules.commands.onFtp.once(after.bind(Ftp), priority);
		modules.commands.onRemote.once(after.bind(Remote), priority);
		modules.commands.onHash.once(after.bind(Hash), priority);
		modules.commands.onUnpack.once(after.bind(Unpack), priority);
	}

	private function getConfig(a: String, b: String): Void {
		modules.checkXml();
		removeConfigListener();
		readConfig(Utils.parseArgs([a, b]));
	}

	private function emptyConfig(): Void {
		modules.checkXml();
		removeConfigListener();
		readConfig({debug: false, app: null});
	}

}