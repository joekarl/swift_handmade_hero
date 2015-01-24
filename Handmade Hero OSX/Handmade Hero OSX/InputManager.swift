//
//  InputManager.swift
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/27/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Foundation

@objc class InputManager {
    
    // lock for thread safety
    private let inputLock = NSLock()
    
    // local copy of input
    private var input = UnsafeMutablePointer<game_input>.alloc(1)
    
    private var hidManager: Unmanaged<IOHIDManager>
    
    var shouldProcessInput = true
    
    init() {
        //assume keyboard always connected
        input.memory.Controllers.0.IsConnected = 1
        
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone));
        
        let hidContext = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        let hidManagerVal = hidManager.takeUnretainedValue();
        // device types we want to monitor
        let deviceCriteria = [
            [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Joystick
            ],
            [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_GamePad
            ],
            [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_MultiAxisController
            ],
            [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
            ]
        ]
        IOHIDManagerSetDeviceMatchingMultiple(hidManagerVal, deviceCriteria)
        IOHIDManagerRegisterDeviceMatchingCallback(hidManagerVal, getHidDeviceAddedCallback(), hidContext);
        IOHIDManagerRegisterDeviceRemovalCallback(hidManagerVal, getHidDeviceRemovedCallback(), hidContext);
        IOHIDManagerScheduleWithRunLoop(hidManagerVal, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
        IOHIDManagerOpen(hidManagerVal, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerRegisterInputValueCallback(hidManagerVal, getHidDeviceActionCallback(), hidContext);
    }
    
    func updateInputState(inputPtr: UnsafeMutablePointer<game_input>) {
        inputLock.lock()
        memcpy(inputPtr, input, UInt(sizeof(game_input)))
        inputLock.unlock()
    }
    
    func hidDeviceAdded(context: UnsafeMutablePointer<Void>, result: IOReturn, sender: UnsafeMutablePointer<Void>, device: IOHIDDevice) {
        var manufacturer = "Unknown"
//        let mfnTypeRef: AnyObject = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey).takeUnretainedValue()
//        if (unsafeBitCast(mfnTypeRef, CFStringRef.self) != nil) {
//            manufacturer = unsafeBitCast(mfnTypeRef, CFStringRef.self) as String
//        }
        
        var product = "Unknown"
        let prodTypeRef: AnyObject = IOHIDDeviceGetProperty(device, kIOHIDProductKey).takeUnretainedValue()
        if (unsafeBitCast(prodTypeRef, CFStringRef.self) != nil) {
            product = unsafeBitCast(prodTypeRef, CFStringRef.self) as String
        }
        
        NSLog("Device added %@ %@", manufacturer, product)
    }
    
    func hidDeviceRemoved(context: UnsafeMutablePointer<Void>, result: IOReturn, sender: UnsafeMutablePointer<Void>, device: IOHIDDevice) {
        var manufacturer = "Unknown"
//        let mfnTypeRef: AnyObject = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey).takeUnretainedValue()
//        if (unsafeBitCast(mfnTypeRef, CFStringRef.self) != nil) {
//            manufacturer = unsafeBitCast(mfnTypeRef, CFStringRef.self) as String
//        }
        
        var product = "Unknown"
        let prodTypeRef: AnyObject = IOHIDDeviceGetProperty(device, kIOHIDProductKey).takeUnretainedValue()
        if (unsafeBitCast(prodTypeRef, CFStringRef.self) != nil) {
            product = unsafeBitCast(prodTypeRef, CFStringRef.self) as String
        }
        
        NSLog("Device removed %@ %@", manufacturer, product)
    }
    
    func hidDeviceAction(context: UnsafeMutablePointer<Void>, result: IOReturn, sender: UnsafeMutablePointer<Void>, value: IOHIDValueRef) {
        // make sure we should actually record our input
        // TODO: this should probably be more than a boolean
        // so that we can reset all input on window inactive
        if (!shouldProcessInput) {
            return
        }
        
        // PS3 controllers report bogus values
        // just throw them away
        // via itfrombit
        // https://github.com/itfrombit/osx_handmade/blob/master/Handmade%20Hero/HandmadeView.mm#L336-L337
        if (IOHIDValueGetLength(value) > 2)
        {
            //NSLog("OSXHIDAction: value length > 2: %ld", IOHIDValueGetLength(value));
            return
        }
        
        inputLock.lock()
        
        let element = IOHIDValueGetElement(value)
        let elementValue = IOHIDValueGetIntegerValue(value);
        let usagePage = Int(IOHIDElementGetUsagePage(element.takeUnretainedValue()))
        let usage = Int(IOHIDElementGetUsage(element.takeUnretainedValue()))
        
        switch(usagePage) {
        case kHIDPage_KeyboardOrKeypad:
            handleKeyboardInput(usage, isDown: elementValue == 1);
            break
        default:
            if (usage == 0x01 || (usage >= 0x30 && usage <= 0x35)) {
                break
            }
            NSLog("Unhandled usagePage %02x usage %02x val %02x", usagePage, usage, elementValue)
            break
        }
        
        inputLock.unlock()
    }
    
    private func handleKeyboardInput(usage: Int, isDown: Bool) {
        // get a non-unioned version of our controller input
        // (this is because Swift doesn't handle c structs with unions :/
        var controllerInput = unsafeControllerInputCast(input, 0)
        
        let endedDownVal = bool32(isDown ? 1 : 0)
        
        switch(usage) {
        case kHIDUsage_KeyboardA:
            controllerInput.memory.MoveLeft.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardW:
            controllerInput.memory.MoveUp.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardS:
            controllerInput.memory.MoveDown.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardD:
            controllerInput.memory.MoveRight.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardLeftArrow:
            controllerInput.memory.ActionLeft.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardRightArrow:
            controllerInput.memory.ActionRight.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardUpArrow:
            controllerInput.memory.ActionUp.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardDownArrow:
            controllerInput.memory.ActionDown.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardQ:
            controllerInput.memory.LeftShoulder.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardE:
            controllerInput.memory.RightShoulder.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardEscape:
            controllerInput.memory.Back.EndedDown = endedDownVal
            break
        case kHIDUsage_KeyboardSpacebar:
            controllerInput.memory.Start.EndedDown = endedDownVal
            break
            
        default:
            return
        }
    }
}