//
//  ProcessInfo+JIT.swift
//  Ignited
//
//  Created by Riley Testut on 9/14/21.
//  Copyright © 2021 Riley Testut. All rights reserved.
//

import UIKit

private let CS_OPS_STATUS: UInt32 = 0 /* OK */
private let CS_DEBUGGED: UInt32   = 0x10000000  /* Process is or has been attached to debugger. */

@_silgen_name("csops")
func csops(_ pid: pid_t, _ ops: UInt32, _ useraddr: UnsafeMutableRawPointer?, _ usersize: Int) -> Int

extension ProcessInfo
{
    static var isJITDisabled = false
    
    var isDebugging: Bool {
        var flags: UInt32 = 0
        let result = csops(getpid(), CS_OPS_STATUS, &flags, MemoryLayout<UInt32>.size)
        
        let isDebugging = result == 0 && (flags & CS_DEBUGGED == CS_DEBUGGED)
        return isDebugging
    }
    
    var isJITAvailable: Bool {
        guard UIDevice.current.supportsJIT && !ProcessInfo.isJITDisabled else { return false }
        
        return self.isDebugging
    }
}
