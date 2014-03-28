/* 
*	ARDUINO CLASS - version 1.0 - 30-12-2005
*  	this Actionscript class makes it easier to connect Flash to the Arduino Board (www.arduino.cc)
*	# copyleft beltran berrocal, 2005 - b@progetto25zero1.com - www.progetto25zero1.com
*   # updates and examples: www.progetto25zero1.com/b/tools/Arduino
* 
* 	# credits must also be given to:
*	Yaniv Steiner and the instant soup crew (instantsoup.interaction-ivrea.it) for generating the original flash client
*
*  	# you will also need the serialProxy developed by Stefano Busti(1999) and David A. Mellis(2005)
*   that can be found either on the Arduino Site (www.arduino.cc) or redistributed with this example (see update url)
*
*---------------------------------------------------------------
*
*   # METHODS & DESCRIPTIONS
*
*	@@ CONSTRUCTOR
*	@@ creates the Arduino Object inside Flash 
*				usage:
*						var portNumber   = 5333;		//read the serialProxy documentation to understand this
*						var hostIpAdress = "127.0.0.1"; //optional it deafaults to this
*						var ArduinoInstance:Arduino = new Arduino(portNumber, hostIpAdress);
*	
*	@@ CONNECT
*	@@ connects to the XMLSocket server, you must have provided a port and a host adress via the constructor
*				usage:
*						ArduinoInstance.connect()
*	
*	@@ DISCONNECT
*	@@ disconnects from the XMLSocket server
*				usage:
*						ArduinoInstance.disconnect()
*	
*	@@ SEND
*	@@ sends data to Arduino via the XMLSocket server(the serialProxy)
*				usage:
*						ArduinoInstance.send("some data here");
*	
*	## EVENT: onDataReceived
*	## handler of a listener object that listens to data sent from Arduino through the XMLSocket server(the serial Proxy)
*				usage:
*						Arduino_Listener = new Object(); //create a listener object
*						Arduino_Listener.onDataReceived = function() { 
*								//handle the received data in here
*						}
*						ArduinoInstance.addEventListener("onReceiveData",Arduino_Listener); //register to listen to the events
*	
*	## OTHER EVENTS: onConnect,  onConnectError,  onDisconnect
*				usage: use in the same way as the onDataReceived event
*
*-----------------------------------------------------------------------------
*	LICENCE
*   Copyright (C) 2005 beltran berrocal | b@progetto25zero1.com  |
*
*   This library is free software; you can redistribute it and/or modify it 
*	under the terms of the GNU Lesser General Public License 
*	as published by the Free Software Foundation; either version 2.1 of the License
*	
*   You should have received a copy of the GNU Lesser General Public License along with this library;
*   Alternatively you can find it here http://www.gnu.org/licenses/lgpl.html
*    
*   Brief Explanation of the Licence:
*   - you can you use, redistribute, modify this software for free,
*	- you can put it into commercial projects
*   - but if you modify/enhance this Library you should release it under the same licence or alternatively under the GPL licence
*   - in all cases you should also credit the original author and all contributors
*
* 
*-----------------------------------------------------------------------------
*/

package {
	import flash.display.Sprite;
	import flash.net.XMLSocket;
	import flash.events.*;
 
	public class Arduino extends XMLSocket{
 
		private var _connected		:Boolean = false;	// 是否已連結
		private var _host		:String  = "127.0.0.1"; // 主機名稱或是IP位址
		private var _port			:int  = 5333;		// 設定連結埠號
 
		public function Arduino(port:int = 5331, host:String = "127.0.0.1") {
			//initialize
 			
			super();
 
			if((port < 1024) || (port > 65536)){
				trace("** Arduino ** Port must be from 1024 to 65535 ! read the Flash Documentation and the serProxy config file to better understand");
			}else{
				_port = port;
			}
 
			_host = host;
 
			//autoconnect
			xconnect();
		}
		//connect to the XMLsocket
		public function xconnect ():void {
			super.connect(_host, _port);
		}
 
		//disconnects from the xmlsocket (not Arduino itself)
		public function disconnect () {
			if (_connected)	{
				super.close();
				_connected = false;
			}
		}
	}
}