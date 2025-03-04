package pony.html;

import haxe.Log;
import haxe.PosInfos;
import pony.ILogable;
import js.html.Element;
import js.Browser;

using StringTools;

@:nullSafety(Strict) class HtmlLog {

	private final origTrace: Null<Dynamic -> ?PosInfos -> Void>;
	private final container: Element;
	private final reverse: Bool;

	public function new(
		containerId: String = 'log', obj: ILogable = null, handleTrace: Bool = true, handleGlobalError: Bool = true, reverse: Bool = false
	) {
		this.reverse = reverse;
		container = Browser.document.getElementById(containerId);
		if (container == null) return;
		if (handleTrace) {
			origTrace = Log.trace;
			Log.trace = traceHandler;
			if (obj != null) @:nullSafety(Off) {
				obj.onLog << origTrace;
				obj.onError << origTrace;
			}
		}
		if (obj != null) {
			obj.onLog << logHandler;
			obj.onError << errorHandler;
		}
		if (handleGlobalError) Browser.window.onerror = windowsErrorHandler;
	}

	private function traceHandler(v: Dynamic, ?p: PosInfos): Void {
		('$v'.startsWith('Catch error') ? errorHandler : logHandler)(
			[Std.string(v)].concat(p != null && p.customParams != null ? p.customParams.map(Std.string) : []).join(', '), p
		);
		@:nullSafety(Off) origTrace(v, p);
	}

	public inline function print(message: String): Void if (container != null) logHandler(message, null);

	private function logHandler(message: String, ?pos: PosInfos): Void {
		addToContainer(pos != null ?
			'<p><span class="gray">${pos.fileName}:${pos.lineNumber}:</span> <span>$message</span></p>' :
			'<p><span>$message</span></p>');
	}

	private function errorHandler(message: String, ?pos: PosInfos): Void {
		addToContainer(pos != null ?
			'<p><span class="gray">${pos.fileName}:${pos.lineNumber}:</span> <span class="error">$message</span></p>' :
			'<p><span class="error">$message</span></p>');
	}

	private function windowsErrorHandler(_, _, _, _, _): Bool {
		addToContainer('<p><span class="error">Fatal error</span></p>');
		return false;
	}

	private function addToContainer(s: String): Void {
		if (reverse)
			container.innerHTML = s + container.innerHTML;
		else
			container.innerHTML += s;
	}

}