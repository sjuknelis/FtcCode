//
//  BlockProps.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/23/24.
//

import Foundation
import SwiftUI

protocol BlockProps {
    var display: [DisplayItem] { get }
    var colorPair: BlockColorPair { get }
    var type: BlockType { get }
    
    func evaluate(arguments: [BlockData], program: Program) throws -> BlockData?
}

enum BlockData {
    case BracketState(shouldEnter: Bool, shouldRepeat: Bool)
    case Boolean(Bool)
    case Number(Double)
}
