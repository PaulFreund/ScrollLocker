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

pragma(lib, "shell32.lib");

import std.string;
import std.c.windows.windows;

extern (Windows): BOOL DestroyWindow(HWND hWnd);
extern (Windows): BOOL Shell_NotifyIcon(DWORD dwMessage, NOTIFYICONDATA * lpdata);
extern (Windows): BOOL DestroyIcon(HICON hIcon);

//===================================================================================================

enum NotifyIconMessage
{
	NIM_ADD 	= 0x00000000,
	NIM_DELETE	= 0x00000002
}

enum IconDataFlags
{
	NIF_MESSAGE = 0x00000001,
	NIF_ICON 	= 0x00000002,
	NIF_TIP 	= 0x00000004
}
//===================================================================================================

struct GUID 
{
	DWORD	Data1;
	WORD	Data2;
	WORD	Data3;
	BYTE	Data4[8];
}

struct NOTIFYICONDATA 
{
	DWORD	cbSize;
	HWND	hWnd;
	UINT	uID;
	UINT	uFlags;
	UINT	uCallbackMessage;
	HICON	hIcon;
	CHAR	szTip[64];
	DWORD	dwState;
	DWORD	dwStateMask;
	CHAR	szInfo[256];
	union {
		UINT	uTimeout;
		UINT	uVersion;
	};
	CHAR	szInfoTitle[64];
	DWORD	dwInfoFlags;
	GUID	guidItem;
	HICON	hBalloonIcon;
}

//===================================================================================================

class TrayIcon
{
	//-----------------------------------------------------------------------------------------------

	HICON _iconData = null;
	HWND _dummyWindow = null;
	NOTIFYICONDATA _trayData;

	//-----------------------------------------------------------------------------------------------

	this(uint iconID, string tipText = "")
	{
		HINSTANCE instance = GetModuleHandleA(null);
		_trayData.cbSize = NOTIFYICONDATA.sizeof;
		_trayData.uFlags = IconDataFlags.NIF_ICON;

		// Dummy window
		_dummyWindow = CreateWindowExA(0, "Static", "TrayDummy", 0, 0, 0, 0, 0, 
		                               cast(HWND)-3, null, instance, null);
		_trayData.hWnd = _dummyWindow;

		// Set icon data (series of casts equals MAKEINTRESOURCE macro in C++ MFC)
		_iconData = LoadIconA(instance, cast(LPSTR)cast(ULONG_PTR)cast(WORD)iconID);
		_trayData.hIcon = _iconData;
		
		// Set tip message if supplied
		if( tipText.length > 0 )
		{
			char[] tipTextBuffer = (tipText ~ '\0').dup;
			tipTextBuffer.length = 64;

			_trayData.szTip = tipTextBuffer;
			_trayData.uFlags |= IconDataFlags.NIF_TIP;
		}
	}

	//-----------------------------------------------------------------------------------------------

	~this()
	{
		Hide();
		
		if( _dummyWindow != null )
			DestroyWindow(_dummyWindow);
		
		if( _iconData != null )
			DestroyIcon(_iconData);
	}

	//-----------------------------------------------------------------------------------------------

	bool Show()
	{
		if( _iconData == null && _dummyWindow == null )
			return false;

		return Shell_NotifyIcon(NotifyIconMessage.NIM_ADD, &_trayData) == TRUE ? true : false;
	}

	//-----------------------------------------------------------------------------------------------

	bool Hide()
	{
		return Shell_NotifyIcon(NotifyIconMessage.NIM_DELETE, &_trayData) == TRUE ? true : false;
	}

	//-----------------------------------------------------------------------------------------------
}

//===================================================================================================