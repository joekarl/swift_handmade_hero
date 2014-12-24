//
//  GameView.swift
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/23/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

import Cocoa
import CoreVideo

@objc class GameView: NSOpenGLView {
    
    //textureId that we'll use to store reference to our opengl texture
    var textureId: GLuint = GLuint()
    
    //reference to a CVDisplayLinkRef
    var displayLink = UnsafeMutablePointer<Unmanaged<CVDisplayLink>?>.alloc(1)
    
    //lock for safely updating input
    var inputLock = NSLock()
    
    override func awakeFromNib() {
        let attrs: [NSOpenGLPixelFormatAttribute] = [
                                                        UInt32(NSOpenGLPFADoubleBuffer),
                                                        UInt32(NSOpenGLPFAAccelerated),
                                                        UInt32(NSOpenGLPFADepthSize), UInt32(24),
                                                        UInt32(0)
                                                    ]
        let pf = NSOpenGLPixelFormat(attributes: attrs)
        let glContext = NSOpenGLContext(format: pf, shareContext: nil)
        self.pixelFormat = pf
        self.openGLContext = glContext
    }
    
    override func prepareOpenGL() {
        super.prepareOpenGL()
        
        openGLContext.makeCurrentContext()
        
        //setup opengl defaults
        glDisable(GLenum(GL_DEPTH_TEST))
        glLoadIdentity()
        //glViewport(0, 0, graphicsBuffer->width, graphicsBuffer->height);
        
        //set to use vsync
        var vsync = GLint(1)
        openGLContext.setValues(&vsync, forParameter:NSOpenGLContextParameter.GLCPSwapInterval)
        
        CGLLockContext(openGLContext.CGLContextObj)
        
        glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
        
        //create texture for later
        glGenTextures(1, &textureId)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        
        //clear texture
        //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, graphicsBuffer->width, graphicsBuffer->height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);
        
        //setup texture smoothing mode
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_REPLACE)
        
        CGLUnlockContext(openGLContext.CGLContextObj)
        
        //create displaylink
        CVDisplayLinkCreateWithActiveCGDisplays(displayLink);
        
        //get reference to display link now it's been created
        var displayLinkRef: CVDisplayLinkRef? = displayLink.memory?.takeUnretainedValue()
        
        //setup displaylink callback
        let dlContext = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        CVDisplayLinkSetOutputCallback(displayLinkRef, getDisplayLinkCallback(), dlContext)
        
        //setup opengl for displaylink
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLinkRef, openGLContext.CGLContextObj, pixelFormat!.CGLPixelFormatObj)
        
        CVDisplayLinkStart(displayLinkRef)

    }
    
    func getFrame() {
        println("WHOOO HOOOO")
    }
    
}

