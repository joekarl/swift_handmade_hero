//
//  PlatformLayer.swift
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/26/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Foundation

class PlatformLayer {
    // lock for safely updating input
    var inputLock = NSLock()
    
    // uninitialized pointers to our platform layer memory
    var gameMemory = UnsafeMutablePointer<game_memory>.alloc(1)
    var gameInput = UnsafeMutablePointer<game_input>.alloc(1)
    var gameOffscreenBuffer = UnsafeMutablePointer<game_offscreen_buffer>.alloc(1)
    var gameThreadContext = UnsafeMutablePointer<thread_context>.null()
    
    // game code loader
    var gameCodeLoader = GameCodeLoader()
    
    init() {
        // initialize all of our memory
        let permanantStorageSize = Helpers.megabytes(64)
        let TransientStorageSize = Helpers.gigabytes(1)
        gameMemory.memory.PermanentStorageSize = permanantStorageSize
        gameMemory.memory.TransientStorageSize = TransientStorageSize
        gameMemory.memory.PermanentStorage = UnsafeMutablePointer<Void>.alloc(Int(permanantStorageSize))
        gameMemory.memory.TransientStorage = UnsafeMutablePointer<Void>.alloc(Int(TransientStorageSize))
        
        
        gameOffscreenBuffer.memory.Width = 800
        gameOffscreenBuffer.memory.Height = 600
        gameOffscreenBuffer.memory.BytesPerPixel = 4
        gameOffscreenBuffer.memory.Pitch = gameOffscreenBuffer.memory.Width * gameOffscreenBuffer.memory.BytesPerPixel
        
        var totalBufferSize = gameOffscreenBuffer.memory.Pitch * gameOffscreenBuffer.memory.Height
        gameOffscreenBuffer.memory.Memory = UnsafeMutablePointer<Void>.alloc(Int(totalBufferSize))
        
        var pixelPtr = unsafeBitCast(gameOffscreenBuffer.memory.Memory, UnsafeMutablePointer<UInt32>.self)
        for y in 0 ... (gameOffscreenBuffer.memory.Height - 1) {
            for x in 0 ... (gameOffscreenBuffer.memory.Width - 1) {
                // everytime through the loop, advance by one pixel
                pixelPtr = pixelPtr.advancedBy(1)
                let pixelVal = UInt32(0xFFFF0000) //ARGB here
                pixelPtr.memory = pixelVal
            }
        }

        // load our dylib game code
        gameCodeLoader.loadGameCode()
    }
    
    func platformGameUpdateAndRender() {
        // reload our dylib if it's changed
        gameCodeLoader.reloadGameCodeIfNeeded()
        
        // sanity check
        if (gameCodeLoader.isInitialized) {
            // run function pointer in objc b/c swift can't call function pointers o_0
            shimCallGameUpdateAndRenderFn(gameCodeLoader.gameUpdateAndRenderFn, gameThreadContext, gameMemory, gameInput, gameOffscreenBuffer)
        }
    }
    
    
}