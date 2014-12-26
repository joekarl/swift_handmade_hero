//
//  GameCodeShim.m
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/26/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#import "GameCodeShim.h"
// Imports the generated bridge from objc to swift
// This is available after setting Defines Module to YES in the Build Settings for the project
#import "Handmade_Hero_Swift_Platform-Swift.h"

void shimCallGameUpdateAndRenderFn(game_update_and_render fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_input* input,
                                   game_offscreen_buffer* buffer)
{
    fn(threadContext, memory, input, buffer);
}