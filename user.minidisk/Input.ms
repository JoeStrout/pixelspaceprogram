// Input system extracted from my custom wip library

dsl = {}
dsl.keys = {
	"a": {"code": "a", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 0, "state" : "up", "lastChecked": -1}, 
	"b": {"code": "b", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 1, "state" : "up", "lastChecked": -1}, 
	"c": {"code": "c", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 2, "state" : "up", "lastChecked": -1}, 
	"d": {"code": "d", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 3, "state" : "up", "lastChecked": -1}, 
	"e": {"code": "e", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 4, "state" : "up", "lastChecked": -1}, 
	"f": {"code": "f", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 5, "state" : "up", "lastChecked": -1}, 
	"g": {"code": "g", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 6, "state" : "up", "lastChecked": -1}, 
	"h": {"code": "h", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 7, "state" : "up", "lastChecked": -1}, 
	"i": {"code": "i", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 8, "state" : "up", "lastChecked": -1}, 
	"j": {"code": "j", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 9, "state" : "up", "lastChecked": -1}, 
	"k": {"code": "k", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 10, "state" : "up", "lastChecked": -1}, 
	"l": {"code": "l", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 11, "state" : "up", "lastChecked": -1}, 
	"m": {"code": "m", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 12, "state" : "up", "lastChecked": -1}, 
	"n": {"code": "n", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 13, "state" : "up", "lastChecked": -1}, 
	"o": {"code": "o", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 14, "state" : "up", "lastChecked": -1}, 
	"p": {"code": "p", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 15, "state" : "up", "lastChecked": -1}, 
	"q": {"code": "q", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 16, "state" : "up", "lastChecked": -1}, 
	"r": {"code": "r", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 17, "state" : "up", "lastChecked": -1}, 
	"s": {"code": "s", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 18, "state" : "up", "lastChecked": -1}, 
	"t": {"code": "t", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 19, "state" : "up", "lastChecked": -1}, 
	"u": {"code": "u", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 20, "state" : "up", "lastChecked": -1}, 
	"v": {"code": "v", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 21, "state" : "up", "lastChecked": -1}, 
	"w": {"code": "w", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 22, "state" : "up", "lastChecked": -1}, 
	"x": {"code": "x", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 23, "state" : "up", "lastChecked": -1}, 
	"y": {"code": "y", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 24, "state" : "up", "lastChecked": -1}, 
	"z": {"code": "z", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 25, "state" : "up", "lastChecked": -1}, 
	"1": {"code": "1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 26, "state" : "up", "lastChecked": -1}, 
	"2": {"code": "2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 27, "state" : "up", "lastChecked": -1}, 
	"3": {"code": "3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 28, "state" : "up", "lastChecked": -1}, 
	"4": {"code": "4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 29, "state" : "up", "lastChecked": -1}, 
	"5": {"code": "5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 30, "state" : "up", "lastChecked": -1}, 
	"6": {"code": "6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 31, "state" : "up", "lastChecked": -1}, 
	"7": {"code": "7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 32, "state" : "up", "lastChecked": -1}, 
	"8": {"code": "8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 33, "state" : "up", "lastChecked": -1}, 
	"9": {"code": "9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 34, "state" : "up", "lastChecked": -1}, 
	"0": {"code": "0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 35, "state" : "up", "lastChecked": -1}, 
	"-": {"code": "-", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 36, "state" : "up", "lastChecked": -1}, 
	"=": {"code": "=", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 37, "state" : "up", "lastChecked": -1}, 
	"[": {"code": "[", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 38, "state" : "up", "state" : "up", "lastChecked": -1}, 
	"]": {"code": "]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 39, "state" : "up", "lastChecked": -1}, 
	"\": {"code": "\", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 40, "state" : "up", "lastChecked": -1}, 
	",": {"code": ",", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 41, "state" : "up", "lastChecked": -1}, 
	".": {"code": ".", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 42, "state" : "up", "lastChecked": -1}, 
	"/": {"code": "/", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 43, "state" : "up", "lastChecked": -1}, 
	";": {"code": ";", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 44, "state" : "up", "lastChecked": -1}, 
	"'": {"code": "'", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 45, "state" : "up", "lastChecked": -1}, 
	"`": {"code": "`", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 46, "state" : "up", "lastChecked": -1}, 
	"f1": {"code": "f1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 47, "state" : "up", "lastChecked": -1}, 
	"f2": {"code": "f2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 48, "state" : "up", "lastChecked": -1}, 
	"f3": {"code": "f3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 49, "state" : "up", "lastChecked": -1}, 
	"f4": {"code": "f4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 50, "state" : "up", "lastChecked": -1}, 
	"f5": {"code": "f5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 51, "state" : "up", "lastChecked": -1}, 
	"f6": {"code": "f6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 52, "state" : "up", "lastChecked": -1}, 
	"f7": {"code": "f7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 53, "state" : "up", "lastChecked": -1}, 
	"f8": {"code": "f8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 54, "state" : "up", "lastChecked": -1}, 
	"f9": {"code": "f9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 55, "state" : "up", "lastChecked": -1}, 
	"f10": {"code": "f10", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 56, "state" : "up", "lastChecked": -1}, 
	"f11": {"code": "f11", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 57, "state" : "up", "lastChecked": -1}, 
	"f12": {"code": "f12", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 58, "state" : "up", "lastChecked": -1}, 
	"f13": {"code": "f13", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 59, "state" : "up", "lastChecked": -1}, 
	"f14": {"code": "f14", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 60, "state" : "up", "lastChecked": -1}, 
	"f15": {"code": "f15", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 61, "state" : "up", "lastChecked": -1}, 
	"up": {"code": "up", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 62, "state" : "up", "lastChecked": -1}, 
	"down": {"code": "down", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 63, "state" : "up", "lastChecked": -1}, 
	"left": {"code": "left", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 64, "state" : "up", "lastChecked": -1}, 
	"right": {"code": "right", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 65}, 
	"[1]": {"code": "[1]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 66, "state" : "up", "lastChecked": -1}, 
	"[2]": {"code": "[2]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 67, "state" : "up", "lastChecked": -1}, 
	"[3]": {"code": "[3]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 68, "state" : "up", "lastChecked": -1}, 
	"[4]": {"code": "[4]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 69, "state" : "up", "lastChecked": -1}, 
	"[5]": {"code": "[5]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 70, "state" : "up", "lastChecked": -1}, 
	"[6]": {"code": "[6]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 71, "state" : "up", "lastChecked": -1}, 
	"[7]": {"code": "[7]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 72, "state" : "up", "lastChecked": -1}, 
	"[8]": {"code": "[8]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 73, "state" : "up", "lastChecked": -1}, 
	"[9]": {"code": "[9]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 74, "state" : "up", "lastChecked": -1}, 
	"[0]": {"code": "[0]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 75, "state" : "up", "lastChecked": -1}, 
	"[+]": {"code": "[+]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 76, "state" : "up", "lastChecked": -1}, 
	"[-]": {"code": "[-]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 77, "state" : "up", "lastChecked": -1}, 
	"[*]": {"code": "[*]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 78, "state" : "up", "lastChecked": -1}, 
	"[/]": {"code": "[/]", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 79, "state" : "up", "lastChecked": -1}, 
	"enter": {"code": "enter", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 80, "state" : "up", "lastChecked": -1}, 
	"equals": {"code": "equals", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 81, "state" : "up", "lastChecked": -1}, 
	"clear": {"code": "clear", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 82, "state" : "up", "lastChecked": -1}, 
	"left shift": {"code": "left shift", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 83, "state" : "up", "lastChecked": -1}, 
	"right shift": {"code": "right shift", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 84, "state" : "up", "lastChecked": -1}, 
	"left ctrl": {"code": "left ctrl", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 85, "state" : "up", "lastChecked": -1}, 
	"right ctrl": {"code": "right ctrl", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 86, "state" : "up", "lastChecked": -1}, 
	"left alt": {"code": "left alt", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 87, "state" : "up", "lastChecked": -1}, 
	"right alt": {"code": "right alt", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 88, "state" : "up", "lastChecked": -1}, 
	"left cmd": {"code": "left cmd", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 89, "state" : "up", "lastChecked": -1}, 
	"right cmd": {"code": "right cmd", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 90, "state" : "up", "lastChecked": -1}, 
	"backspace": {"code": "backspace", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 91, "state" : "up", "lastChecked": -1}, 
	"tab": {"code": "tab", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 92, "state" : "up", "lastChecked": -1}, 
	"return": {"code": "return", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 93, "state" : "up", "lastChecked": -1}, 
	"escape": {"code": "escape", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 94, "state" : "up", "lastChecked": -1}, 
	"space": {"code": "space", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 95, "state" : "up", "lastChecked": -1}, 
	"delete": {"code": "delete", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 96, "state" : "up", "lastChecked": -1}, 
	"insert": {"code": "insert", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 97, "state" : "up", "lastChecked": -1}, 
	"home": {"code": "home", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 98, "state" : "up", "lastChecked": -1}, 
	"end": {"code": "end", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 99, "state" : "up", "lastChecked": -1}, 
	"page up": {"code": "page up", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 100, "state" : "up", "lastChecked": -1}, 
	"page down": {"code": "page down", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 101, "state" : "up", "lastChecked": -1}, 
	"mouse 0": {"code": "mouse 0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 102, "state" : "up", "lastChecked": -1}, 
	"mouse 1": {"code": "mouse 1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 103, "state" : "up", "lastChecked": -1}, 
	"mouse 2": {"code": "mouse 2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 104, "state" : "up", "lastChecked": -1}, 
	"mouse 3": {"code": "mouse 3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 105, "state" : "up", "lastChecked": -1}, 
	"mouse 4": {"code": "mouse 4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 106, "state" : "up", "lastChecked": -1}, 
	"mouse 5": {"code": "mouse 5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 107, "state" : "up", "lastChecked": -1}, 
	"mouse 6": {"code": "mouse 6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 108, "state" : "up", "lastChecked": -1}, 
	"joystick button 0": {"code": "joystick button 0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 109, "state" : "up", "lastChecked": -1}, 
	"joystick button 1": {"code": "joystick button 1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 110, "state" : "up", "lastChecked": -1}, 
	"joystick button 2": {"code": "joystick button 2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 111, "state" : "up", "lastChecked": -1}, 
	"joystick button 3": {"code": "joystick button 3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 112, "state" : "up", "lastChecked": -1}, 
	"joystick button 4": {"code": "joystick button 4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 113, "state" : "up", "lastChecked": -1}, 
	"joystick button 5": {"code": "joystick button 5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 114, "state" : "up", "lastChecked": -1}, 
	"joystick button 6": {"code": "joystick button 6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 115, "state" : "up", "lastChecked": -1}, 
	"joystick button 7": {"code": "joystick button 7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 116, "state" : "up", "lastChecked": -1}, 
	"joystick button 8": {"code": "joystick button 8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 117, "state" : "up", "lastChecked": -1}, 
	"joystick button 9": {"code": "joystick button 9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 118, "state" : "up", "lastChecked": -1}, 
	"joystick button 10": {"code": "joystick button 10", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 119, "state" : "up", "lastChecked": -1}, 
	"joystick button 11": {"code": "joystick button 11", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 120, "state" : "up", "lastChecked": -1}, 
	"joystick button 12": {"code": "joystick button 12", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 121, "state" : "up", "lastChecked": -1}, 
	"joystick button 13": {"code": "joystick button 13", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 122, "state" : "up", "lastChecked": -1}, 
	"joystick button 14": {"code": "joystick button 14", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 123, "state" : "up", "lastChecked": -1}, 
	"joystick button 15": {"code": "joystick button 15", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 124, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 0": {"code": "joystick 1 button 0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 125, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 1": {"code": "joystick 1 button 1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 126, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 2": {"code": "joystick 1 button 2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 127, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 3": {"code": "joystick 1 button 3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 128, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 4": {"code": "joystick 1 button 4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 129, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 5": {"code": "joystick 1 button 5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 130, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 6": {"code": "joystick 1 button 6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 131, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 7": {"code": "joystick 1 button 7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 132, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 8": {"code": "joystick 1 button 8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 133, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 9": {"code": "joystick 1 button 9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 134, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 10": {"code": "joystick 1 button 10", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 135, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 11": {"code": "joystick 1 button 11", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 136, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 12": {"code": "joystick 1 button 12", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 137, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 13": {"code": "joystick 1 button 13", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 138, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 14": {"code": "joystick 1 button 14", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 139, "state" : "up", "lastChecked": -1}, 
	"joystick 1 button 15": {"code": "joystick 1 button 15", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 140, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 0": {"code": "joystick 2 button 0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 141, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 1": {"code": "joystick 2 button 1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 142, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 2": {"code": "joystick 2 button 2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 143, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 3": {"code": "joystick 2 button 3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 144, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 4": {"code": "joystick 2 button 4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 145, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 5": {"code": "joystick 2 button 5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 146, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 6": {"code": "joystick 2 button 6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 147, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 7": {"code": "joystick 2 button 7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 148, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 8": {"code": "joystick 2 button 8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 149, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 9": {"code": "joystick 2 button 9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 150, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 10": {"code": "joystick 2 button 10", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 151, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 11": {"code": "joystick 2 button 11", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 152, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 12": {"code": "joystick 2 button 12", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 153, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 13": {"code": "joystick 2 button 13", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 154, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 14": {"code": "joystick 2 button 14", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 155, "state" : "up", "lastChecked": -1}, 
	"joystick 2 button 15": {"code": "joystick 2 button 15", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 156, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 0": {"code": "joystick 3 button 0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 157, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 1": {"code": "joystick 3 button 1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 158, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 2": {"code": "joystick 3 button 2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 159, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 3": {"code": "joystick 3 button 3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 160, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 4": {"code": "joystick 3 button 4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 161, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 5": {"code": "joystick 3 button 5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 162, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 6": {"code": "joystick 3 button 6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 163, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 7": {"code": "joystick 3 button 7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 164, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 8": {"code": "joystick 3 button 8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 165, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 9": {"code": "joystick 3 button 9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 166, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 10": {"code": "joystick 3 button 10", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 167, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 11": {"code": "joystick 3 button 11", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 168, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 12": {"code": "joystick 3 button 12", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 169, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 13": {"code": "joystick 3 button 13", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 170, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 14": {"code": "joystick 3 button 14", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 171, "state" : "up", "lastChecked": -1}, 
	"joystick 3 button 15": {"code": "joystick 3 button 15", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 172, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 0": {"code": "joystick 4 button 0", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 173, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 1": {"code": "joystick 4 button 1", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 174, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 2": {"code": "joystick 4 button 2", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 175, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 3": {"code": "joystick 4 button 3", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 176, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 4": {"code": "joystick 4 button 4", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 177, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 5": {"code": "joystick 4 button 5", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 178, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 6": {"code": "joystick 4 button 6", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 179, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 7": {"code": "joystick 4 button 7", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 180, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 8": {"code": "joystick 4 button 8", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 181, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 9": {"code": "joystick 4 button 9", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 182, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 10": {"code": "joystick 4 button 10", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 183, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 11": {"code": "joystick 4 button 11", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 184, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 12": {"code": "joystick 4 button 12", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 185, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 13": {"code": "joystick 4 button 13", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 186, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 14": {"code": "joystick 4 button 14", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 187, "state" : "up", "lastChecked": -1}, 
	"joystick 4 button 15": {"code": "joystick 4 button 15", "lastPressed": -1, "lastReleased": -1, "wasDown": 0, "index": 188, "state" : "up", "lastChecked": -1}}

dsl.checkKeyState = function(k)
	if  dsl.keys[k].lastChecked == frameCount then 
		return dsl.keys[k].state
	end if

	dsl.keys[k].lastChecked = frameCount

	if key.pressed(k) then
		if dsl.keys[k].state == "up" or dsl.keys[k].state == "released" then
			dsl.keys[k].state = "pressed"
		else
			dsl.keys[k].state = "down"
		end if
	else
		if dsl.keys[k].state == "down" or dsl.keys[k].state == "pressed" then
			dsl.keys[k].state = "released"
		else
			dsl.keys[k].state = "up"
		end if
	end if

	return dsl.keys[k].state
end function

keyPressed = function(k)
	cState = dsl.checkKeyState(k)
	return cState == "pressed"
end function

keyDown = function(k)
	cState = dsl.checkKeyState(k)
	return cState == "down"
end function

keyReleased = function(k)
	cState = dsl.checkKeyState(k)
	return cState == "released"
end function

keyUp = function(k)
	cState = dsl.checkKeyState(k)
	return cState == "up"
end function

