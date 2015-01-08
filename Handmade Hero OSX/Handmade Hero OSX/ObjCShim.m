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
#import "Handmade_Hero_OSX-Swift.h"

CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
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
    return displayLinkCallback;
}

OSStatus coreAudioCallback(void* inRefCon,
                           AudioUnitRenderActionFlags* ioActionFlags,
                           const AudioTimeStamp* inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList* ioData)
{
    return [(__bridge SoundManager*)inRefCon coreAudioCallback:inRefCon ioActionFlags:ioActionFlags inTimeStamp:inTimeStamp inBusNumber:inBusNumber inNumberFrames:inNumberFrames ioData:ioData];
}

AURenderCallback getCoreAudioCallback()
{
    return coreAudioCallback;
}

void shimCallGameUpdateAndRenderFn(game_update_and_render fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_input* input,
                                   game_offscreen_buffer* buffer)
{
    fn(threadContext, memory, input, buffer);
}

void shimCallGameGetSoundSamplesFn(game_get_sound_samples fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_sound_output_buffer* buffer)
{
    fn(threadContext, memory, buffer);
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

// TODO write all this in swift and shim it
DEBUG_PLATFORM_FREE_FILE_MEMORY(DEBUGPlatformFreeFileMemory)
{
    if (Memory)
    {
        free(Memory);
    }
}

// TODO write all this in swift and shim it
DEBUG_PLATFORM_READ_ENTIRE_FILE(DEBUGPlatformReadEntireFile)
{
    debug_read_file_result Result = {};
    
    NSString *frameworksPath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%s", frameworksPath, Filename];
    
    int fd = open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
    if (fd != -1)
    {
        struct stat fileStat;
        if (fstat(fd, &fileStat) == 0)
        {
            uint32 FileSize32 = fileStat.st_size;

            kern_return_t result = vm_allocate((vm_map_t)mach_task_self(),
                                               (vm_address_t*)&Result.Contents,
                                               FileSize32,
                                               VM_FLAGS_ANYWHERE);
            if ((result == KERN_SUCCESS) && Result.Contents)
            {
                ssize_t BytesRead;
                BytesRead = read(fd, Result.Contents, FileSize32);
                if (BytesRead == FileSize32) // should have read until EOF
                {
                    Result.ContentsSize = FileSize32;
                }
                else
                {
                    DEBUGPlatformFreeFileMemory(Thread, Result.Contents);
                    Result.Contents = 0;
                }
            }
            else
            {
                printf("DEBUGPlatformReadEntireFile %s:  vm_allocate error: %d: %s\n",
                       Filename, errno, strerror(errno));
            }
        }
        else
        {
            printf("DEBUGPlatformReadEntireFile %s:  fstat error: %d: %s\n",
                   Filename, errno, strerror(errno));
        }
        
        close(fd);
    }
    else
    {
        printf("DEBUGPlatformReadEntireFile %s:  open error: %d: %s\n",
               Filename, errno, strerror(errno));
    }
    
    return Result;
}

// TODO write all this in swift and shim it
DEBUG_PLATFORM_WRITE_ENTIRE_FILE(DEBUGPlatformWriteEntireFile)
{
    bool32 Result = false;
    
    NSString *frameworksPath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%s", frameworksPath, Filename];
    
    int fd = open([filePath cStringUsingEncoding:NSUTF8StringEncoding], O_WRONLY | O_CREAT, 0644);
    if (fd != -1)
    {
        ssize_t BytesWritten = write(fd, Memory, MemorySize);
        Result = (BytesWritten == MemorySize);
        
        if (!Result)
        {
            
        }
        
        close(fd);
    }
    else
    {
    }
    
    return Result;
}

debug_platform_read_entire_file* getReadFileFn()
{
    return DEBUGPlatformReadEntireFile;
}

debug_platform_write_entire_file* getWriteFileFn()
{
    return DEBUGPlatformWriteEntireFile;
}

debug_platform_free_file_memory* getFreeFileFn()
{
    return DEBUGPlatformFreeFileMemory;
}
