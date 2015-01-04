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
    
    // opengl defines
    // textureId that we'll use to store reference to our opengl texture
    var textureId: GLuint = GLuint()
    // pixel format attributes
    let pixelFormatAttrsBestCase: [NSOpenGLPixelFormatAttribute] = [
        UInt32(NSOpenGLPFADoubleBuffer),
        UInt32(NSOpenGLPFAAccelerated),
        UInt32(NSOpenGLPFADepthSize), UInt32(24),
        UInt32(0)
    ]
    let pixelFormatAttrsFallbackCase: [NSOpenGLPixelFormatAttribute] = [
        UInt32(NSOpenGLPFADepthSize), UInt32(24),
        UInt32(0)
    ]
    // list of vertices we'll use for defining our triangles
    let vertices: [GLfloat] = [
        -1, -1, 0,
        -1,  1, 0,
        1,  1, 0,
        1, -1, 0,
    ]
    // list of coordinates that we'll bind our texture to
    let texCoords: [GLfloat] = [
        0, 1,
        0, 0,
        1, 0,
        1, 1,
    ]
    // list of vertices to be used to draw triangles
    let triangleIndices: [GLushort] = [ 0, 1, 2, 0, 2, 3 ]

    
    // pointer to an uninitialized CVDisplayLinkRef
    var displayLink = UnsafeMutablePointer<Unmanaged<CVDisplayLink>?>.alloc(1)
    
    let inputManager = InputManager()
    
    var platformLayer: PlatformLayer

    required init?(coder: NSCoder) {
        platformLayer = PlatformLayer(anInputManager: inputManager)
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        var pf = NSOpenGLPixelFormat(attributes: pixelFormatAttrsBestCase)
        if (pf == nil) {
            NSLog("Couldn't init opengl the way we wanted, using fallback")
            pf = NSOpenGLPixelFormat(attributes: pixelFormatAttrsFallbackCase)
        }
        if (pf == nil) {
            NSLog("Couldn't init opengl at all, sorry :(")
            abort()
        }
        let glContext = NSOpenGLContext(format: pf, shareContext: nil)
        self.pixelFormat = pf
        self.openGLContext = glContext
    }
    
    override func prepareOpenGL() {
        super.prepareOpenGL()
        
        // make current context for use
        openGLContext.makeCurrentContext()
        
        // lock context just in case something else is using it (shouldn't be though)
        CGLLockContext(openGLContext.CGLContextObj)
        
        // setup opengl defaults
        glDisable(GLenum(GL_DEPTH_TEST))
        glLoadIdentity()
        
        // setup viewport for opengl
        glViewport(0, 0, platformLayer.gameOffscreenBuffer.memory.Width, platformLayer.gameOffscreenBuffer.memory.Height);
        
        // set to use vsync (will default to 60hz in theory)
        var vsync = GLint(1)
        openGLContext.setValues(&vsync, forParameter:NSOpenGLContextParameter.GLCPSwapInterval)
        
        // I don't know what this does o_0
        glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
        
        // create texture for later so we can draw into it
        glGenTextures(1, &textureId)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        
        // clear texture initially to get rid of junk from previous memory
        glTexImage2D(
            GLenum(GL_TEXTURE_2D),
            GLint(0),
            GLint(GL_RGBA),
            GLsizei(platformLayer.gameOffscreenBuffer.memory.Width), GLsizei(platformLayer.gameOffscreenBuffer.memory.Height),
            GLint(0),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), UnsafePointer<Void>.null())
        
        // setup texture modes
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        glTexEnvi(GLenum(GL_TEXTURE_ENV), GLenum(GL_TEXTURE_ENV_MODE), GL_REPLACE)
        
        // release lock on the opengl context
        CGLUnlockContext(openGLContext.CGLContextObj)
        
        // create displaylink and store in displayLink pointer
        CVDisplayLinkCreateWithActiveCGDisplays(displayLink)
        
        // get reference to displayLink memory now it's been created
        var displayLinkRef: CVDisplayLinkRef? = displayLink.memory?.takeUnretainedValue()
        
        // setup displaylink callback
        // need to create an UnsafeMutablePointer by using an unsafeBitCast
        let dlContext = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        // call shim to get the displaylink callback (the shim calls getFrame when fired)
        CVDisplayLinkSetOutputCallback(displayLinkRef, getDisplayLinkCallback(), dlContext)
        
        // setup opengl for displaylink
        CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLinkRef, openGLContext.CGLContextObj, pixelFormat!.CGLPixelFormatObj)
        
        // start the display link
        CVDisplayLinkStart(displayLinkRef)

    }
    
    // callback that our shim will call on cvdisplaylink fire
    func getFrame(time: UnsafePointer<CVTimeStamp>) {
        // lock the opengl context because the main thread might be drawing
        CGLLockContext(openGLContext.CGLContextObj)
        
        // make current for subsequent opengl calls
        openGLContext.makeCurrentContext()
        
        glClearColor(0x00, 0x00, 0x00, 0xFF)
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        
        glVertexPointer(GLint(3), GLenum(GL_FLOAT), GLsizei(0), vertices)
        glTexCoordPointer(GLint(2), GLenum(GL_FLOAT), GLsizei(0), texCoords)
        
        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
        glEnableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        
        glEnable(GLenum(GL_TEXTURE_2D))
        
        // TODO: update input
        
        // TODO: call into platform layer to update the game
        platformLayer.platformGameUpdateAndRender()
        
        // TODO: update texture and draw to screen
        glTexSubImage2D(
            GLenum(GL_TEXTURE_2D),
            GLint(0),
            GLint(0),
            GLint(0),
            GLsizei(platformLayer.gameOffscreenBuffer.memory.Width), GLsizei(platformLayer.gameOffscreenBuffer.memory.Height),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), platformLayer.gameOffscreenBuffer.memory.Memory)
        
        glColor4f(1, 1, 1, 1)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(6), GLenum(GL_UNSIGNED_SHORT), triangleIndices)
        glDisable(GLenum(GL_TEXTURE_2D))
        
        glDisableClientState(GLenum(GL_VERTEX_ARRAY))
        glDisableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        
        glFlush()
        
        // we're double buffered so need to flush to screen
        openGLContext.flushBuffer()
        
        CGLUnlockContext(openGLContext.CGLContextObj)
    }
    
    // resize the viewport when window size changes
    override func reshape() {
        // lock the opengl context because the displaylink might be drawing
        CGLLockContext(openGLContext.CGLContextObj)
        
        openGLContext.makeCurrentContext()
        
        // resize the viewport based on the view's size
        glDisable(GLenum(GL_DEPTH_TEST))
        glLoadIdentity()
        glViewport(0, 0, GLsizei(bounds.width), GLsizei(bounds.height))
        
        glClearColor(0x00, 0x00, 0x00, 0xFF)
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        
        // just draw whatever we have cached in the texture here, don't worry about updating the game
        glVertexPointer(GLint(3), GLenum(GL_FLOAT), GLsizei(0), vertices)
        glTexCoordPointer(GLint(2), GLenum(GL_FLOAT), GLsizei(0), texCoords)
        
        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
        glEnableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
        
        glEnable(GLenum(GL_TEXTURE_2D))
        
        glColor4f(1, 1, 1, 1)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(6), GLenum(GL_UNSIGNED_SHORT), triangleIndices)
        glDisable(GLenum(GL_TEXTURE_2D))
        
        glDisableClientState(GLenum(GL_VERTEX_ARRAY))
        glDisableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        
        // we're double buffered so need to flush to screen
        openGLContext.flushBuffer()
        
        CGLUnlockContext(openGLContext.CGLContextObj);
    }
    
    
    func setAppIsActive(active: Bool) {
        inputManager.shouldProcessInput = active
    }
    
    // accept first responder and ignore keyboard events because we handle them in the input manager
    func acceptsFirstResponder() -> Bool {
        return true;
    }
    
    override func keyDown(theEvent: NSEvent) {
        // noop
    }
    
    override func keyUp(theEvent: NSEvent) {
        // noop
    }
}

