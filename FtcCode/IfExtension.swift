//
//  IfExtension.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/24/24.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
