//
//  BlockView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/21/24.
//

import SwiftUI

struct BlockView: View {
    @ObservedObject var block: Block
    @ObservedObject var context: UserContext
    
    var body: some View {
        if block.props.type == .Bracket {
            VStack(spacing: 0) {
                HStack {
                    BlockDisplayView(block: block, context: context)
                        .padding()
                        .background(
                            UnevenRoundedRectangle(topLeadingRadius: 5, bottomLeadingRadius: 0, bottomTrailingRadius: 5, topTrailingRadius: 5)
                                .fill(block.props.colorPair.bg)
                                .onTapGesture {
                                    if context.selectedBlock?.uuid == block.uuid {
                                        context.selectedBlock = nil
                                    } else {
                                        context.selectedBlock = block
                                    }
                                }
                        )
                        .if(context.selectedBlock?.uuid == block.uuid) { view in
                            view.overlay(
                                TopBracketBorder(flipped: false)
                                    .stroke(.green, lineWidth: 5)
                            )
                        }
                    Spacer()
                }
                
                HStack {
                    Rectangle()
                        .fill(block.props.colorPair.bg)
                        .frame(maxWidth: 25)
                        .onTapGesture {
                            if context.selectedBlock?.uuid == block.uuid {
                                context.selectedBlock = nil
                            } else {
                                context.selectedBlock = block
                            }
                        }
                        .if(context.selectedBlock?.uuid == block.uuid) { view in
                            view
                                .overlay(
                                    SideBracketBorder(left: true)
                                        .stroke(.green, lineWidth: 5)
                                )
                                .overlay(
                                    SideBracketBorder(left: false)
                                        .stroke(.green, lineWidth: 5)
                                )
                        }
                    
                    if block.parent != nil {
                        VStack {
                            Color.white
                                .opacity(0.01)
                                .frame(maxHeight: 0)
                            
                            if let bracketBlocks = block.bracketBlocks {
                                ForEach(Array(bracketBlocks.enumerated()), id: \.element.uuid) { index, bracketBlock in
                                    if block.isModifiable && !block.isAncestor(context.selectedBlock) {
                                        BlockAdditionView(context: context) { newBlock in
                                            block.bracketBlocks!.insert(newBlock.clone(parent: block), at: index)
                                        }
                                    }
                                    
                                    HStack {
                                        BlockView(block: bracketBlock, context: context)
                                        Spacer()
                                    }
                                }
                                
                                if block.isModifiable && !block.isAncestor(context.selectedBlock) {
                                    BlockAdditionView(context: context) { newBlock in
                                        block.bracketBlocks!.append(newBlock.clone(parent: block))
                                    }
                                }
                            }
                            
                            Color.white
                                .opacity(0.01)
                                .frame(maxHeight: 0)
                        }
                    }
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                
                if case .Text(let label) = block.props.display[0] {
                    HStack {
                        Text("end " + label.split(separator: " ")[0])
                            .padding()
                            .background(
                                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 5, bottomTrailingRadius: 5, topTrailingRadius: 5)
                                    .fill(block.props.colorPair.bg)
                            )
                            .onTapGesture {
                                if context.selectedBlock?.uuid == block.uuid {
                                    context.selectedBlock = nil
                                } else {
                                    context.selectedBlock = block
                                }
                            }
                            .if(context.selectedBlock?.uuid == block.uuid) { view in
                                view.overlay(
                                    TopBracketBorder(flipped: true)
                                        .stroke(.green, lineWidth: 5)
                                )
                            }
                        Spacer()
                    }
                }
            }
        } else {
            HStack {
                BlockDisplayView(block: block, context: context)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(block.props.colorPair.bg)
                            .onTapGesture {
                                if context.selectedBlock?.uuid == block.uuid {
                                    context.selectedBlock = nil
                                } else {
                                    context.selectedBlock = block
                                }
                            }
                    )
                    .if(block.parent != nil && (block.props.type == .Boolean || block.props.type == .Number)) { view in
                        view.overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.white, lineWidth: 2)
                        )
                    }
                    .if(context.selectedBlock?.uuid == block.uuid) { view in
                        view.overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.green, lineWidth: 5)
                        )
                    }
            }
        }
    }
}

struct TopBracketBorder: Shape {
    let flipped: Bool
    
    init(flipped: Bool) {
        self.flipped = flipped
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let top = flipped ? rect.maxY : rect.minY
        let bottom = flipped ? rect.minY : rect.maxY
        
        path.move(to: CGPoint(x: rect.minX, y: bottom))
        path.addArc(
            tangent1End: CGPoint(x: rect.minX, y: top),
            tangent2End: CGPoint(x: rect.midX, y: top),
            radius: 5
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: top),
            tangent2End: CGPoint(x: rect.maxX, y: rect.midY),
            radius: 5
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: bottom),
            tangent2End: CGPoint(x: rect.minX + 25, y: bottom),
            radius: 5
        )
        path.addLine(to: CGPoint(x: rect.minX + 25, y: bottom))
        
        return path
    }
}

struct SideBracketBorder: Shape {
    let left: Bool
    
    init(left: Bool) {
        self.left = left
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let x = left ? rect.minX : rect.maxX
        
        path.move(to: CGPoint(x: x, y: rect.minY))
        path.addLine(to: CGPoint(x: x, y: rect.maxY))
        
        return path
    }
}

#Preview {
    BlockView(block: Block(props: bankBlockProps[0], program: Program()), context: UserContext())
}
