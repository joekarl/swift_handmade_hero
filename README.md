##Handmade Hero Swift Cocoa Platform Layer

This is an ongoing OSX version of a platform layer for Casey Muratori's Handmade Hero.

The goal is to be able to drop in Casey's platform independent game source code and compile and run it unchanged.

###Xcode
I'm using xcode 6.1.1 on OSX 10.9.5. This targets 10.9 using the OSX 10.10 SDK.

###dylib support
The platform independent layer is wrapped up in a dylib and is loaded dynamically by the platform layer. This allows the code to be reloaded at runtime by simply building the dylib. Due to the way xcode projects work, this is as simple as building the main project (⌘-b or ⌘-⏎-b).

Ultimately how this works is the main project has the dylib as a compile dependency. A copy files build phase is setup to copy the dylib (once built) into the frameworks folder of our resulting app. The platform layer looks for this the dylib at runtime and checks to see whether the dylib has been updated. If it has been updated, it reloads the dylib.

###Game input
Right now this just supports keyboard input but has the beginnings of controller support (turns out this is just super messy on OSX).

As of right now, the controls are wasd for movement and you can also press the up arrow to speed up movement.

To connect to the game initially, press the space bar.

###Swift ObjC shim
So Swift is nice and all, but any API that takes a function pointer or needs to invoke the function behind a function pointer cannot be implemented in Swift. This is just a limitation of the language. So what you will find in this code is an ObjcShim file which is where anything that can't be done in Swift will reside. Some of these things just forward calls from the objc shim back in to the Swift layer, others will be invoked by the Swift layer to forward calls from the Swift layer into the platform independent layer.

####IMPORTANT

I removed Casey's platform-independent game code from this repository. At the moment that is just handmade*.cpp and handmade*.h files.

Once you clone or update from this repository, copy over the handmade .cpp/.h files from Casey's source code into the handmadeSrc folder (don't copy the platform layer files, just the platform independent files).
You also need to copy over the assets into the handmadeAssets folder. For this copy the entire contents of the assets zip into the assets folder (should end up with a handmadeAssets/test/*.bmp folder structure)

This repository works with Casey's handmade*.cpp/handmade*.h files from handmade_hero_050_source.

####Author

Karl Kirch

Handmade Hero is being created by Casey Muratori.

You can find more information about Handmade Hero at: http://handmadehero.org
