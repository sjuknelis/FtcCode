//
//  BlockBankView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/21/24.
//

import SwiftUI

struct BlockBankView: View {
    @ObservedObject var program: Program
    @ObservedObject var context: UserContext
    
    @State var blocks: [Block] = []
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack {
                Color.white
                    .opacity(0.01)
                    .frame(maxHeight: 0)
                
                ForEach(blocks, id: \.uuid) { block in
                    HStack {
                        BlockView(block: block, context: context)
                        Spacer()
                    }
                    .frame(minWidth: 500)
                }
                
                HStack {
                    CreateVariableButtonView(program: program, context: context)
                    Spacer()
                }
            }
            .padding()
        }
        .overlay(
            Rectangle()
                .frame(width: 1, height: nil, alignment: .leading)
                .foregroundColor(.black),
            alignment: .trailing
        )
        .onAppear {
            blocks = bankBlockProps.map { props in Block(props: props, program: program) }
        }
    }
}

#Preview {
    BlockBankView(program: Program(), context: UserContext())
}
