//
//  Include all c headers that should be exposed to swift
//

// include opengl C calls
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

// include platform layer header
#import "handmadeSrc/handmade_platform.h"

// include the obj shims
#import "DisplayLinkShim.h"
#import "GameCodeShim.h"

// include dylib handling code
#import <dlfcn.h>