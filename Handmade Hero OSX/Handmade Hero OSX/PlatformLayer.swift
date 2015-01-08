//
//  PlatformLayer.swift
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/26/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Foundation

class PlatformLayer {
    
    // uninitialized pointers to our platform layer memory
    var gameMemory = UnsafeMutablePointer<game_memory>.alloc(1)
    var gameInput = UnsafeMutablePointer<game_input>.alloc(1)
    var gameOffscreenBuffer = UnsafeMutablePointer<game_offscreen_buffer>.alloc(1)
    var gameThreadContext = UnsafeMutablePointer<thread_context>.null()
    
    // game code loader
    private var gameCodeLoader = GameCodeLoader()
    
    // input manager
    private let inputManager: InputManager
    private let soundManager = SoundManager()
    
    init(anInputManager: InputManager) {
        inputManager = anInputManager
        
        // initialize all of our memory
        let permanantStorageSize = Helpers.megabytes(64)
        let TransientStorageSize = Helpers.gigabytes(1)
        gameMemory.memory.PermanentStorageSize = permanantStorageSize
        gameMemory.memory.TransientStorageSize = TransientStorageSize
        gameMemory.memory.PermanentStorage = UnsafeMutablePointer<Void>.alloc(Int(permanantStorageSize))
        gameMemory.memory.TransientStorage = UnsafeMutablePointer<Void>.alloc(Int(TransientStorageSize))
        gameMemory.memory.DEBUGPlatformFreeFileMemory = getFreeFileFn()
        gameMemory.memory.DEBUGPlatformReadEntireFile = getReadFileFn()
        gameMemory.memory.DEBUGPlatformWriteEntireFile = getWriteFileFn()
        
        gameOffscreenBuffer.memory.Width = 960 /*magic value*/
        gameOffscreenBuffer.memory.Height = 540 /*magic value*/
        gameOffscreenBuffer.memory.BytesPerPixel = 4 /*magic value*/
        gameOffscreenBuffer.memory.Pitch = gameOffscreenBuffer.memory.Width * gameOffscreenBuffer.memory.BytesPerPixel
        
        var totalBufferSize = gameOffscreenBuffer.memory.Pitch * gameOffscreenBuffer.memory.Height
        gameOffscreenBuffer.memory.Memory = UnsafeMutablePointer<Void>.alloc(Int(totalBufferSize))

        // load our dylib game code
        gameCodeLoader.loadGameCode()
    }
    
    func platformGameUpdateAndRender() {
        // reload our dylib if it's changed
        gameCodeLoader.reloadGameCodeIfNeeded()
        
        // update input state
        inputManager.updateInputState(gameInput)
        
        // have to do this every frame because of me copying over all of the input state :/
        // TODO: get this value from display link
        gameInput.memory.dtForFrame = 1.0 / 60.0
        
        // sanity check
        if (gameCodeLoader.isInitialized) {
            // run function pointer in objc b/c swift can't call function pointers o_0
            shimCallGameUpdateAndRenderFn(gameCodeLoader.gameUpdateAndRenderFn, gameThreadContext, gameMemory, gameInput, gameOffscreenBuffer)
            
            // delegate sound handling to sound manager
            soundManager.updateAudioBuffer(gameCodeLoader.gameGetSoundSamplesFn, threadContext: gameThreadContext, gameMemory: gameMemory)
        }
    }
}