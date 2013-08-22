# ScrollLocker

Standalone Windows application writte in D that locks keyboard and mouse when scroll lock is enabled.

## Features 

* Locks keyboard and mouse with one key
* Tray icon shows the application is running
* ScrollLocker can be killed with hotkey (STRG+ALT+SHIFT+Q by default)
* Keys can be easily customized in code

## Installation

The application does not need to be installed. To run it everytime you start the computer just copy or link it in the "Startup" folder of your start menu.

## Notes

* The project was created with Xamarin Studio with D/DMD2 and the ResourceCompiler installed
* It is very easy to modify main.d to change the quit or lock(toggle) key
* ScrollLocker can't work when a window with higher privileges is in foreground
* STRG+ALT+ENTF can't be blocked because Windows catches it on a very high level
* Contributions are always wellcome, expecially a settings GUI would be nice

## Possible Uses

The application can be usefull everytime your running applications should not be interrupted. 
Example use cases:

* Important process is running and must in no case be interrupted
* Cat is about to conquer the keyboard
* A toddler wants to play minesweeper
* Some friend visits who is known to change your music