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

import std.c.windows.windows;

alias HANDLE HHOOK;

extern (Windows): HHOOK SetWindowsHookExA(int idHook, HOOKPROC lpfn, HINSTANCE hMod, DWORD dwThreadId);
extern (Windows): LRESULT CallNextHookEx(HHOOK hhk, int nCode, WPARAM wParam, LPARAM lParam);
extern (Windows): BOOL UnhookWindowsHookEx(HHOOK hhk);
extern (Windows): SHORT GetKeyState(int nVirtKey);

//===================================================================================================

enum HookCode
{
	HC_ACTION = 0
}

enum HookTypes
{
	WH_KEYBOARD_LL	= 13,
	WH_MOUSE_LL		= 14
}

enum KeyStates
{
	Active			= 1,
	Inactive		= 0,
	Activating		= -127,
	Deactivating	= -128
}

//===================================================================================================

struct KBDLLHOOKSTRUCT 
{
	DWORD		vkCode;
	DWORD		scanCode;
	DWORD		flags;
	DWORD		time;
	ULONG_PTR	dwExtraInfo;
} 

struct MSLLHOOKSTRUCT 
{
	POINT		pt;
	DWORD		mouseData;
	DWORD		flags;
	DWORD		time;
	ULONG_PTR	dwExtraInfo;
}

//===================================================================================================

class InputHooks
{
	//-----------------------------------------------------------------------------------------------

	// These are static because the callbacks for SetWindowsHookExA have to be static and I can't 
	// pass additional parameters. Of course there might be a better solution.
	static DWORD _keyToggle = 0;
	static DWORD _keyQuit = 0;

	HHOOK _hookKeyboard = null;
	HHOOK _hookMouse = null;

	//-----------------------------------------------------------------------------------------------

	this(DWORD keyToggle, DWORD keyQuit)
	{
		_keyToggle = keyToggle;
		_keyQuit = keyQuit;
	}

	//-----------------------------------------------------------------------------------------------

	~this()
	{
		UnregisterHooks();
	}


	//-----------------------------------------------------------------------------------------------

	void RegisterHooks()
	{
		if( _hookKeyboard == null )
			_hookKeyboard = SetWindowsHookExA(HookTypes.WH_KEYBOARD_LL, &LockKeyboardProc, null, 0); 

		if( _hookMouse == null )
			_hookMouse = SetWindowsHookExA(HookTypes.WH_MOUSE_LL, &LockMouseProc, null, 0); 
	}

	//-----------------------------------------------------------------------------------------------

	void UnregisterHooks()
	{
		if( _hookKeyboard != null )
			UnhookWindowsHookEx(_hookKeyboard);

		if( _hookMouse != null )
			UnhookWindowsHookEx(_hookMouse);

		_hookKeyboard = null;
		_hookMouse = null;
	}
	
	//-----------------------------------------------------------------------------------------------

	static extern (Windows) LRESULT LockKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) nothrow
	{
		bool passMessage = false;
		KBDLLHOOKSTRUCT* details = cast(KBDLLHOOKSTRUCT*) lParam;
		
		try
		{
			// Pass message if invalid nCode
			if( nCode != HookCode.HC_ACTION )
				passMessage = true;

			// If it is the scroll key we let pass so it is possible to deactivate
			else if( details.vkCode == _keyToggle )
				passMessage = true;

			// We have to let all variations of our exit modifiers through so it can be detected
			else if( IsModifierKey(details.vkCode))
			   passMessage = true;

			// Our close key will be let through if the modifiers are correct
			else if( details.vkCode == _keyQuit && AreModifiersPressed() )
				passMessage = true;


			// Pass message and exit
			if( passMessage )
				return CallNextHookEx(cast(HHOOK)0, nCode, wParam, lParam);
		}
		catch(Exception){ return 0; }
		
		// Hold message
		return 1;
	} 

	//-----------------------------------------------------------------------------------------------
	
	static extern (Windows) LRESULT LockMouseProc(int nCode, WPARAM wParam, LPARAM lParam) nothrow
	{
		try
		{
			// Pass message if invalid nCode
			if( nCode != HookCode.HC_ACTION )
				return CallNextHookEx(cast(HHOOK)0, nCode, wParam, lParam);
		}
		catch(Exception){ return 0; }
		
		// Hold message
		return 1;
	} 

	//-----------------------------------------------------------------------------------------------

	static bool IsModifierKey(DWORD keyCode)
	{
		switch(keyCode)
		{
			case VK_SHIFT:
			case VK_LSHIFT:
			case VK_RSHIFT:
			case VK_MENU:
			case VK_LMENU:
			case VK_RMENU:
			case VK_CONTROL:
			case VK_LCONTROL: 
			case VK_RCONTROL:
				return true;

			default:
				return false;
		}
	}

	//-----------------------------------------------------------------------------------------------

	static bool AreModifiersPressed()
	{
		return (IsKeyPressed(VK_SHIFT) && IsKeyPressed(VK_MENU) && IsKeyPressed(VK_CONTROL));
	}

	//-----------------------------------------------------------------------------------------------

	static bool IsKeyPressed(int keyCode)
	{
		int keyState = GetKeyState(keyCode);
		return (keyState == KeyStates.Activating || keyState == KeyStates.Deactivating);
	}

	//-----------------------------------------------------------------------------------------------

	static bool IsModifierEnabled(int keyCode)
	{
		switch(GetKeyState(keyCode))
		{
			case KeyStates.Inactive: 
			case KeyStates.Deactivating:
				return false; 
				break;
				
			case KeyStates.Active:
			case KeyStates.Activating:
				return true; 
				break;
				
			default: 
				return false;
				break;
		}
	}

	//-----------------------------------------------------------------------------------------------
}

//===================================================================================================