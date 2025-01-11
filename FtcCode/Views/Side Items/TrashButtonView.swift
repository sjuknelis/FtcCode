//
//  TrashButtonView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/27/24.
//

import SwiftUI

struct TrashButtonView: View {
    @ObservedObject var context: UserContext
    
    var body: some View {
        if let block = context.selectedBlock, let parent = block.parent {
            Button(action: {
                parent.deleteChild(block)
                context.selectedBlock = nil
            }) {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    PlayButtonView(program: Program())
}
