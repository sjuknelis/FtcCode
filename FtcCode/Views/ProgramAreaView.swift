//
//  ProgramAreaView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/21/24.
//

import SwiftUI

struct ProgramAreaView: View {
    @ObservedObject var program: Program
    @ObservedObject var context: UserContext
    
    @State private var fillerHeight = CGFloat.zero
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                Color.white
                    .opacity(0.01)
                    .frame(minWidth: geometry.size.width)
                
                VStack {
                    ForEach(Array(program.blocks.enumerated()), id: \.element.uuid) { index, block in
                        if !program.running {
                            BlockAdditionView(context: context) { newBlock in
                                program.blocks.insert(newBlock.clone(parent: program), at: index)
                            }
                        }
                        
                        HStack {
                            BlockView(block: block, context: context)
                            Spacer()
                        }
                    }
                    
                    if !program.running {
                        BlockAdditionView(context: context, expandedHeight: fillerHeight) { newBlock in
                            program.blocks.append(newBlock.clone(parent: program))
                        }
                        .frame(minHeight: fillerHeight)
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("parent")).origin.y)
                        })
                    } else {
                        Color.white
                            .opacity(0.01)
                            .frame(minHeight: fillerHeight)
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("parent")).origin.y)
                            })
                    }
                }
                .coordinateSpace(name: "parent")
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    fillerHeight = geometry.size.height - value
                }
                .padding([.leading], 5)
                .frame(minWidth: 3000)
            }
            .frame(minHeight: geometry.size.height)
        }
    }
}

private struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

#Preview {
    ProgramAreaView(program: Program(blocks: [
        Block(props: bankBlockProps[0], program: Program()),
        Block(props: bankBlockProps[1], program: Program())
    ]), context: UserContext())
}
