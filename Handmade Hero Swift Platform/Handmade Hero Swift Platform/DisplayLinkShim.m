//
//  DisplayLinkShim.m
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/23/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#import "DisplayLinkShim.h"
#import "Handmade_Hero_Swift_Platform-Swift.h"

CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
                             const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut, void *displayLinkContext)
{
    @autoreleasepool {
        [(__bridge GameView*)displayLinkContext getFrame];
    }
    
    return kCVReturnSuccess;
}

CVDisplayLinkOutputCallback getDisplayLinkCallback()
{
    return DisplayLinkCallback;
}