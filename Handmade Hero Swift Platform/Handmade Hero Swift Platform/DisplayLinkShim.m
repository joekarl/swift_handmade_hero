//
//  DisplayLinkShim.m
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/23/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#import "DisplayLinkShim.h"

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