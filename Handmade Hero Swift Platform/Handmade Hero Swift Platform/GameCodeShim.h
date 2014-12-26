//
//  GameCodeShim.h
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/26/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

#ifndef Handmade_Hero_Swift_Platform_GameCodeShim_h
#define Handmade_Hero_Swift_Platform_GameCodeShim_h

// include platform layer header
#import "handmadeSrc/handmade_platform.h"

void shimCallGameUpdateAndRenderFn(game_update_and_render fn,
                                   thread_context* threadContext,
                                   game_memory* memory,
                                   game_input* input,
                                   game_offscreen_buffer* buffer);

#endif
