//
//  UserContext.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/25/24.
//

import Foundation

class UserContext: ObservableObject {
    @Published var selectedBlock: Block?
    @Published var variableNames: [String] = []
}
