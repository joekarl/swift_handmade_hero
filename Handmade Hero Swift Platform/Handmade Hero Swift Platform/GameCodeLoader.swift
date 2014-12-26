//
//  GameCode.swift
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/26/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Foundation

class GameCodeLoader {
    var gameUpdateAndRenderFn = CFunctionPointer<game_update_and_render>.null()
    var gameGetSoundSamplesFn = CFunctionPointer<game_get_sound_samples>.null()
    var isInitialized = false
    let dylibPath: String
    var lastLoadTime = NSDate()
    var dylibRef = UnsafeMutablePointer<Void>.null()
    
    var LastWriteTime: time_t = 0
    
    init() {
        let frameworksPath = NSBundle.mainBundle().privateFrameworksPath
        let dylibName = "libHandmade Hero Dylib.dylib"
        dylibPath = frameworksPath! + "/" + dylibName
    }
    
    func reloadGameCodeIfNeeded() -> Bool {
        if (!isInitialized) {
            NSLog("ERROR: Must call loadGameCode before calling reloadGameCodeIfNeeded")
            abort()
        }
        
        var err = NSErrorPointer()
        var attributes = NSFileManager.defaultManager().attributesOfItemAtPath(dylibPath, error: err)
        if (attributes == nil) {
            return false
        }
        var currentLoadTime = attributes![NSFileModificationDate]! as NSDate
        if (currentLoadTime.compare(lastLoadTime) == NSComparisonResult.OrderedDescending) {
            // ie currentLoadTime > lastLoadTime
            lastLoadTime = currentLoadTime
            unloadGameCode()
            return loadGameCode()
        } else {
            return false
        }
    }
    
    func loadGameCode() -> Bool {
        var didLoadCorrectly = false
        
        dylibRef = dlopen(dylibPath, RTLD_LAZY | RTLD_LOCAL)
        if (dylibRef != UnsafeMutablePointer<Void>.null()) {
            gameUpdateAndRenderFn = unsafeBitCast(dlsym(dylibRef, "GameUpdateAndRender"), CFunctionPointer<game_update_and_render>.self)
            gameGetSoundSamplesFn = unsafeBitCast(dlsym(dylibRef, "GameGetSoundSamples"), CFunctionPointer<game_get_sound_samples>.self)
            
            if (gameUpdateAndRenderFn != CFunctionPointer<game_update_and_render>.null()
                && gameGetSoundSamplesFn != CFunctionPointer<game_get_sound_samples>.null()) {
                didLoadCorrectly = true
            }
        }
        
        if (didLoadCorrectly) {
            NSLog("Successfully loaded game code")
            isInitialized = true
        } else {
            unloadGameCode()
            NSLog("WARNING: Failed to load game code")
        }
        return isInitialized
    }
    
    func unloadGameCode() {
        isInitialized = false
        
        if (dylibRef != UnsafeMutablePointer<Void>.null()) {
            dlclose(dylibRef)
            //dylibRef = UnsafeMutablePointer<Void>.null()
        }
        
        // null out our pointers for good measure...
        gameUpdateAndRenderFn = CFunctionPointer<game_update_and_render>.null()
        gameGetSoundSamplesFn = CFunctionPointer<game_get_sound_samples>.null()
    }
}