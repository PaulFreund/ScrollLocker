# ScrollLocker

Standalone Windows application writte in D that locks keyboard and mouse when scroll lock is enabled.

## Features 

* Locks/Unlocks keyboard and mouse with only the scroll lock key (between print and pause)
* The scroll lock key is stateful so you have a light on your keyboard when active
* ScrollLocker can be killed from everywhere with STRG+ALT+SHIFT+Q 
* Tray icon shows the application is running
* Keys can be easily customized in code

## Download and Instalation

You can either download a [precompiled standalone .exe](https://github.com/PaulFreund/ScrollLocker/releases) from my Github relases or compile the source code yourself (see additional notes).

ScrollLocker doesn't need to be installed, just execute the exe. To run it on startup, just copy or link it in the "Startup" folder of your start menu.

## Additional Notes

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
