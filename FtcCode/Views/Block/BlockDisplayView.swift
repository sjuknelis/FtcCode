//
//  BlockDisplayView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/25/24.
//

import SwiftUI

struct BlockDisplayView: View {
    @ObservedObject var block: Block
    @ObservedObject var context: UserContext
    
    var body: some View {
        HStack {
            ForEach(block.props.display) { item in
                DisplayItemView(block: block, context: context, item: item)
            }
        }
    }
}
