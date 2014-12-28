//
//  ObjCShim.m
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/23/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#import "ObjCShim.h"

// Imports the generated bridge from objc to swift
// This is available after setting Defines Module to YES in the Build Settings for the project
#import "Handmade_Hero_Swift_Platform-Swift.h"

CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
                             const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut, void *displayLinkContext)
{
    // wrap our call to swift in an autorelease pool because the cvdisplaylink thread doesn't
    // have an autorelease pool by default
    @autoreleasepool {
        [(__bridge GameView*)displayLinkContext getFrame:outputTime];
    }
    
    return kCVReturnSuccess;
}

CVDisplayLinkOutputCallback getDisplayLinkCallback()
{
    return DisplayLinkCallback;
}

void shimCallGameUpdateAndRenderFn(game_update_and_render fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_input* input,
                                   game_offscreen_buffer* buffer)
{
    fn(threadContext, memory, input, buffer);
}

void hidDeviceAdded(void* context, IOReturn result, void* sender, IOHIDDeviceRef device)
{
    [(__bridge InputManager*)context hidDeviceAdded:context result:result sender:sender device:device];
}

void hidDeviceRemoved(void* context, IOReturn result, void* sender, IOHIDDeviceRef device)
{
    [(__bridge InputManager*)context hidDeviceRemoved:context result:result sender:sender device:device];
}

void hidDeviceAction(void* context, IOReturn result, void* sender, IOHIDValueRef value)
{
    [(__bridge InputManager*)context hidDeviceAction:context result:result sender:sender value:value];
}

IOHIDDeviceCallback getHidDeviceAddedCallback()
{
    return hidDeviceAdded;
}

IOHIDDeviceCallback getHidDeviceRemovedCallback()
{
    return hidDeviceRemoved;
}

IOHIDValueCallback getHidDeviceActionCallback()
{
    return hidDeviceAction;
}

game_controller_input_shim * unsafeControllerInputCast(game_input * input, int controller)
{
    return (game_controller_input_shim *) &input->Controllers[controller];
}
