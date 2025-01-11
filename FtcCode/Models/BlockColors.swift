//
//  BlockColors.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/24/24.
//

import Foundation
import SwiftUI

let blockColors = BlockColors()

struct BlockColors {
    let command = BlockColorPair(bg: .purple, fg: .white)
    let request = BlockColorPair(bg: .orange, fg: .white)
    let operation = BlockColorPair(bg: .blue, fg: .white)
    let control = BlockColorPair(bg: .mint, fg: .black)
    let variable = BlockColorPair(bg: .red, fg: .white)
}

struct BlockColorPair {
    let bg: Color
    let fg: Color
}
