//
//  ObjcShim.h
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/23/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#ifndef Handmade_Hero_Swift_Platform_DisplayLinkShim_h
#define Handmade_Hero_Swift_Platform_DisplayLinkShim_h

#import <CoreVideo/CoreVideo.h>
#import <IOKit/hid/IOHIDLib.h>
#import <AudioUnit/AudioUnit.h>
#include "handmade_platform.h"

// Display link shims
CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
                             const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut, void *displayLinkContext);
CVDisplayLinkOutputCallback getDisplayLinkCallback();

// Core Audio shims
OSStatus coreAudioCallback(void* inRefCon,
                           AudioUnitRenderActionFlags* ioActionFlags,
                           const AudioTimeStamp* inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList* ioData);
AURenderCallback getCoreAudioCallback();

// Platform indepent layer shims
void shimCallGameUpdateAndRenderFn(game_update_and_render fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_input* input,
                                   game_offscreen_buffer* buffer);

void shimCallGameGetSoundSamplesFn(game_get_sound_samples fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_sound_output_buffer* buffer);

// HID lib shims
void hidDeviceAdded(void* context, IOReturn result, void* sender, IOHIDDeviceRef device);
void hidDeviceRemoved(void* context, IOReturn result, void* sender, IOHIDDeviceRef device);
void hidDeviceAction(void* context, IOReturn result, void* sender, IOHIDValueRef value);
IOHIDDeviceCallback getHidDeviceAddedCallback();
IOHIDDeviceCallback getHidDeviceRemovedCallback();
IOHIDValueCallback getHidDeviceActionCallback();

// game_controller_input shim due to lack of union support in swift :/
typedef struct game_controller_input_shim {
    bool32 IsConnected;
    bool32 IsAnalog;
    real32 StickAverageX;
    real32 StickAverageY;
    game_button_state MoveUp;
    game_button_state MoveDown;
    game_button_state MoveLeft;
    game_button_state MoveRight;
    
    game_button_state ActionUp;
    game_button_state ActionDown;
    game_button_state ActionLeft;
    game_button_state ActionRight;
    
    game_button_state LeftShoulder;
    game_button_state RightShoulder;
    
    game_button_state Back;
    game_button_state Start;
    
    // NOTE(casey): All buttons must be added above this line
    
    game_button_state Terminator;
} game_controller_input_shim;

game_controller_input_shim * unsafeControllerInputCast(game_input * input, int controller);

// Get debug file read callbacks
debug_platform_read_entire_file* getReadFileFn();
debug_platform_write_entire_file* getWriteFileFn();
debug_platform_free_file_memory* getFreeFileFn();

#endif
