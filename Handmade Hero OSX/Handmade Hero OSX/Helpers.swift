//
//  Helpers.swift
//  Handmade Hero Swift Platform
//
//  Created by Karl Kirch on 12/25/14.
//  Copyright (c) 2014 Handmade Hero. All rights reserved.
//

class Helpers {

    class func kilobytes(m: uint64) -> uint64 {
        return m * 1024
    }

    class func megabytes(m: uint64) -> uint64 {
        return kilobytes(m) * 1024
    }

    class func gigabytes(m: uint64) -> uint64 {
        return megabytes(m) * 1024
    }
}