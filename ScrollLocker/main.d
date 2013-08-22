//###################################################################################################
/*
    Copyright (c) since 2013 - Paul Freund 
    
    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.
*/
//###################################################################################################

//// These values allow basic configuration, for extended Hotkeys, see the RegisterHotKey calls.

// Key to enable/disable the lock
const uint KEY_TOGGLE = VK_SCROLL;

// Character that with: STRG + ALT + SHIFT + {CHAR_QUIT} closes the app (must not be empty!)
const char CHAR_QUIT = 'Q';

// Set the icon ID, has to match ID in Win32Resources.rc
const uint ID_ICON = 0x002;

//===================================================================================================

import std.conv;
import std.string;
import core.runtime;
import std.c.windows.windows;

import tray;
import hooks;

extern (Windows): SHORT VkKeyScanA(CHAR ch);
extern (Windows): BOOL RegisterHotKey(HWND hWnd, int id, UINT fsModifiers, UINT vk);
extern (Windows): BOOL UnregisterHotKey(HWND hWnd, int id);

//===================================================================================================

enum WindowMessages
{
	WM_HOTKEY = 0x0312
}

enum KeyCodes
{
	ALT		= 0x0001,
	CONTROL	= 0x0002,
	SHIFT	= 0x0004
}

//===================================================================================================

union KeyCodeScanValue
{
	char ShiftState;
	char KeyCode;
}

//===================================================================================================

extern(Windows)	int WinMain(HINSTANCE hInst, HINSTANCE hPrevInst, LPSTR lpCmdLine, int iCmdShow)
{
	try
	{
		//-------------------------------------------------------------------------------------------

		Runtime.initialize();

		const int hotkeyToggle = 1;
		const int hotkeyClose = 2;

		short scanValue = VkKeyScanA(CHAR_QUIT);
		uint keyCodeQuit = (cast(KeyCodeScanValue*)&scanValue).KeyCode;
		
		string tip = "[ScrollLocker] Press SCROLL -> un/lock, CTRL+ALT+SHIFT+"~CHAR_QUIT~" -> quit";

		TrayIcon trayIcon = new TrayIcon(ID_ICON, tip);
		InputHooks inputHooks = new InputHooks(KEY_TOGGLE, keyCodeQuit);

		//-------------------------------------------------------------------------------------------

		trayIcon.Show();

		RegisterHotKey(null, hotkeyClose, KeyCodes.ALT|KeyCodes.SHIFT|KeyCodes.CONTROL, keyCodeQuit);
		RegisterHotKey(null, hotkeyToggle, 0, KEY_TOGGLE );

		// Get current state and lock if neccessary
		if( inputHooks.IsModifierEnabled(KEY_TOGGLE) )
			inputHooks.RegisterHooks();

		//-------------------------------------------------------------------------------------------

		// Main loop, as seen in many win32 apps
		MSG msg;
		while (GetMessageA(&msg, null, 0, 0) != 0)
		{
			if (msg.message == WindowMessages.WM_HOTKEY) 
			{
				if( msg.wParam == hotkeyToggle )
				{
					if(inputHooks.IsModifierEnabled(KEY_TOGGLE) )
						inputHooks.RegisterHooks();
					else 
						inputHooks.UnregisterHooks();
				}
				else if( msg.wParam == hotkeyClose )
				{
					break;
				}
			}
			
			TranslateMessage(&msg);
			DispatchMessageA(&msg);		
		} 

		//-------------------------------------------------------------------------------------------

		inputHooks.UnregisterHooks();

		UnregisterHotKey(null, hotkeyToggle);
		UnregisterHotKey(null, hotkeyClose);

		trayIcon.Hide();

		Runtime.terminate();

		//-------------------------------------------------------------------------------------------
	}
	catch (Throwable e) { return -1; }

	// Everything is okay
	return 0;
}

//===================================================================================================