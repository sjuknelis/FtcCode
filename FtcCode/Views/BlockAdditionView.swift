//
//  BlockAdditionView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/25/24.
//

import SwiftUI

struct BlockAdditionView: View {
    @ObservedObject var context: UserContext
    
    var expandedHeight: CGFloat?
    let action: (Block) -> Void
    
    var body: some View {
        if context.selectedBlock?.props.type == .Action || context.selectedBlock?.props.type == .Bracket {
            Color.white
                .opacity(0.01)
                .frame(minHeight: expandedHeight != nil ? expandedHeight : 30)
                .overlay(
                    Triangle()
                        .fill(insertColor)
                        .frame(width: 20, height: 20),
                    alignment: expandedHeight != nil ? .topLeading : .leading
                )
                .onTapGesture {
                    if let newBlock = context.selectedBlock {
                        if newBlock.props.type != .Action && newBlock.props.type != .Bracket {
                            return
                        }
                        
                        action(newBlock)
                        if let parent = newBlock.parent {
                            parent.deleteChild(newBlock)
                        }
                        
                        context.selectedBlock = nil
                    }
                }
        } else if expandedHeight != nil {
            Color.white
                .opacity(0.01)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}
