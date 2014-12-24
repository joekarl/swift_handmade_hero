//
//  DisplayLinkShim.h
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/23/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#ifndef Handmade_Hero_Swift_Platform_DisplayLinkShim_h
#define Handmade_Hero_Swift_Platform_DisplayLinkShim_h

#import <CoreVideo/CoreVideo.h>

CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
                             const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut, void *displayLinkContext);

CVDisplayLinkOutputCallback getDisplayLinkCallback();

#endif
