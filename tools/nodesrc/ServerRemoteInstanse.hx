/**
* Copyright (c) 2012-2018 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
* 1. Redistributions of source code must retain the above copyright notice, this list of
*   conditions and the following disclaimer.
* 
* 2. Redistributions in binary form must reproduce the above copyright notice, this list
*   of conditions and the following disclaimer in the documentation and/or other materials
*   provided with the distribution.
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
**/
#if nodejs
import js.node.ChildProcess;
import sys.io.File;
import haxe.io.BytesOutput;
import pony.net.SocketClient;
import pony.Pair;

/**
 * ServerRemoteInstanse
 * @author AxGord <axgord@gmail.com>
 */
class ServerRemoteInstanse {

	private var client:SocketClient;
	private var currentCommand:String;
	private var currentCommandN:Int;
	private var key:String;
	private var protocol:RemoteProtocol;
	private var commands:Map<String, Array<Pair<Bool, String>>> = new Map();
	private var zipRLog:Bool = true;
	private var packLog:BytesOutput;

	private var activity:Void -> Void;

	public function new(client:SocketClient, key:String, commands:Map<String, Array<Pair<Bool, String>>>) {
		this.client = client;
		this.key = key;
		this.commands = commands;
		client.onClose < closeHandler;
		protocol = new RemoteProtocol(client);
		activity = protocol.ping.watch();
		client.onData << activity;
		protocol.ping.onLostConnection < lostHandler;
		protocol.ping.onWarning << function() Sys.println('Problem with connection');
		protocol.ping.onRestore << function() Sys.println('Connection restore');

		if (key == null) {
			start();
		} else {
			protocol.onAuth < authHandler;
		}
	}

	private function closeHandler():Void {
		Sys.println('Disconnect');
		protocol.file.cancel();
	}

	private function lostHandler():Void {
		Sys.println('Lost connection');
		protocol.file.cancel();
		client.destroy();
	}

	private function authHandler(v:String):Void {
		if (v == key) {
			log('Auth success');
			start();
		} else {
			log('Auth failed');
			pony.time.DeltaTime.skipUpdate(client.destroy);
		}
	}

	private function start():Void {
		protocol.file.enable();
		protocol.file.onData << function() Sys.print('.');
		protocol.onCommand << commandHandler;
		protocol.onGetInitFile << getInitFileHandler;
		protocol.readyRemote();
	}

	private function getInitFileHandler():Void {
		var file = 'init.zip';
		Sys.println('Send file: $file');
		protocol.file.sendFile(file);
	}

	private function log(s:String):Void {
		activity();
		Sys.println(s);
		protocol.log.log(s);
	}

	private function prlog(s:String):Void {
		activity();
		if (s.substr(-1) == '\n')
			s = s.substr(0, -1);
		if (s == '') return;
		Sys.println(s);
		if (zipRLog)
			packLog.writeString(s + '\n');
		else
			protocol.log.log(s);
	}

	private function commandHandler(command:String):Void {
		Sys.println('');
		currentCommandN = 0;
		packLog = new BytesOutput();
		currentCommand = command;
		if (!commands.exists(command)) {
			childExitHandler(404);
			return;
		}
		runNextCommand();
	}

	private function runNextCommand():Void {
		var c:Pair<Bool, String> = commands[currentCommand][currentCommandN];
		log('Command $currentCommand $currentCommandN');
		log(c.b);
		zipRLog = c.a;
		onBeginCommand();
		var p = ChildProcess.exec(c.b, execHandler);
		p.stdout.on('data', prlog);
		p.stderr.on('data', prlog);
		p.on('exit', childExitHandler);
	}

	private function execHandler(err:Null<ChildProcessExecError>, a1:String, a2:String):Void {
		log('procss is exec');
	}

	private function childExitHandler(code:Int):Void {
		trace('childExitHandler: $code');
		onEndCommand();
		activity();
		currentCommandN++;
		if (code == 0 && currentCommandN < commands[currentCommand].length) {
			runNextCommand();
			return;
		}

		if (packLog.length > 0) {
			packLog.flush();
			//protocol.zipLogRemote(haxe.zip.Compress.run(packLog.getBytes(), 9));
			protocol.zipLogRemote(packLog.getBytes());
		}
		//log('Child exited with code $code');
		protocol.commandCompleteRemote(currentCommand, code);
	}

	public dynamic function onBeginCommand():Void {}
	public dynamic function onEndCommand():Void {}

}
#end