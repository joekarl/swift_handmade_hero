//
//  SoundManager.swift
//  Handmade Hero OSX
//
//  Created by Karl Kirch on 12/31/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Foundation
import AudioUnit

@objc class SoundManager {
    
    // sound buffer that the game will use
    private let soundBuffer = UnsafeMutablePointer<game_sound_output_buffer>.alloc(1)
    
    // Lock for synchronizing between core audio thread and other threads
    private let audioLock = NSLock()
    
    init() {
        let samplesPerSec = 4800
        let bytesPerSample = sizeof(int16) * 2
        let numberOfSamples = bytesPerSample * samplesPerSec
        soundBuffer.memory.SamplesPerSecond = int32(samplesPerSec)
        soundBuffer.memory.SampleCount = 0
        soundBuffer.memory.Samples = UnsafeMutablePointer<int16>.alloc(numberOfSamples)
        
        // init core audio
        let audioComponentDescription = UnsafeMutablePointer<AudioComponentDescription>.alloc(1)
        audioComponentDescription.memory.componentType = OSType(kAudioUnitType_Output)
        audioComponentDescription.memory.componentSubType = OSType(kAudioUnitSubType_DefaultOutput)
        audioComponentDescription.memory.componentManufacturer = OSType(kAudioUnitManufacturer_Apple)
        
        let outputComponent = AudioComponentFindNext(nil, audioComponentDescription)
        let audioUnit = UnsafeMutablePointer<AudioUnit>.alloc(1)
        
        AudioComponentInstanceNew(outputComponent, audioUnit)
        AudioUnitInitialize(audioUnit.memory)
        
        let audioStreamBasicDescription = UnsafeMutablePointer<AudioStreamBasicDescription>.alloc(1)
        audioStreamBasicDescription.memory.mSampleRate = Float64(soundBuffer.memory.SamplesPerSecond)
        audioStreamBasicDescription.memory.mFormatID = AudioFormatID(kAudioFormatLinearPCM)
        audioStreamBasicDescription.memory.mFormatFlags = AudioFormatFlags(kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked)
        audioStreamBasicDescription.memory.mChannelsPerFrame = 2
        audioStreamBasicDescription.memory.mBitsPerChannel = 16
        audioStreamBasicDescription.memory.mBytesPerPacket = 4
        audioStreamBasicDescription.memory.mBytesPerFrame = 4
        
        AudioUnitSetProperty(audioUnit.memory, AudioUnitPropertyID(kAudioUnitProperty_StreamFormat), AudioUnitScope(kAudioUnitScope_Input), 0, audioStreamBasicDescription, UInt32(sizeof(AudioStreamBasicDescription)))
        
        let caContext = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        let audioUnitCallbacks = UnsafeMutablePointer<AURenderCallbackStruct>.alloc(1)
        audioUnitCallbacks.memory.inputProc = getCoreAudioCallback()
        audioUnitCallbacks.memory.inputProcRefCon = caContext
        
        AudioUnitSetProperty(audioUnit.memory, AudioUnitPropertyID(kAudioUnitProperty_SetRenderCallback), AudioUnitScope(kAudioUnitScope_Global), 0, audioUnitCallbacks, UInt32(sizeof(AURenderCallbackStruct)))
        
        //AudioOutputUnitStart(audioUnit.memory);
    }
    
    func updateAudioBuffer(sampleGameAudioFn: CFunctionPointer<game_get_sound_samples>, threadContext: UnsafeMutablePointer<thread_context>, gameMemory: UnsafeMutablePointer<game_memory>) {
        audioLock.lock()
        shimCallGameGetSoundSamplesFn(sampleGameAudioFn, threadContext, gameMemory, soundBuffer)
        audioLock.unlock()
    }
    
    func coreAudioCallback(inRefCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus{
        
        audioLock.lock()
        
        audioLock.unlock()
        return noErr
    }
}