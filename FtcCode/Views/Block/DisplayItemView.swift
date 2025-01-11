//
//  DisplayItemView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/25/24.
//

import SwiftUI

let insertColor = Color(red: 0.75, green: 1, blue: 0.75)

struct DisplayItemView: View {
    @ObservedObject var block: Block
    @ObservedObject var context: UserContext
    let item: DisplayItem
    
    private let argHeight: CGFloat = 30
    
    @State private var isValueAlertShown = false
    @State private var alertValue = 0
    
    var body: some View {
        switch item {
        case .Text(let text):
            Text(text)
                .foregroundStyle(block.props.colorPair.fg)
            
        case .BooleanArgument(let index):
            if let argument = block.argumentBlocks[index] {
                BlockView(block: argument, context: context)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(block.isModifiable && context.selectedBlock?.props.type == .Boolean && !block.isAncestor(context.selectedBlock) ? insertColor : .white)
                    .frame(maxWidth: 75, minHeight: argHeight, maxHeight: argHeight)
                    .allowsHitTesting(block.isModifiable)
                    .onTapGesture {
                        if let argument = context.selectedBlock {
                            if argument.props.type != .Boolean || block.isAncestor(context.selectedBlock) {
                                return
                            }
                            
                            block.argumentBlocks[index] = argument.clone(parent: block)
                            if let parent = argument.parent {
                                parent.deleteChild(argument)
                            }
                            
                            context.selectedBlock = nil
                        }
                    }
            }
            
        case .NumberArgument(let index):
            if let argument = block.argumentBlocks[index] {
                BlockView(block: argument, context: context)
            } else {
                Text(String(block.argumentRawValues[index]))
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(block.isModifiable && context.selectedBlock?.props.type == .Number && !block.isAncestor(context.selectedBlock) ? insertColor : .white)
                            .frame(minWidth: 75, minHeight: argHeight)
                    )
                    .frame(minWidth: 75, minHeight: argHeight, maxHeight: argHeight)
                    .multilineTextAlignment(.center)
                    .allowsHitTesting(block.isModifiable)
                    .onTapGesture {
                        if let argument = context.selectedBlock {
                            if argument.props.type != .Number || block.isAncestor(argument) {
                                return
                            }
                            
                            block.argumentBlocks[index] = argument.clone(parent: block)
                            block.argumentRawValues[index] = 0
                            if let parent = argument.parent {
                                parent.deleteChild(argument)
                            }
                            
                            context.selectedBlock = nil
                        } else {
                            alertValue = block.argumentRawValues[index]
                            isValueAlertShown = true
                        }
                    }
                    .alert("Set number", isPresented: $isValueAlertShown) {
                        TextField("Value", value: $alertValue, format: .number)
                            .multilineTextAlignment(.center)
                        Button("OK") { block.argumentRawValues[index] = alertValue }
                        Button("Cancel", role: .cancel) { }
                    }
            }
            
        case .SelectableNumberArgument(let index, let options):
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                    .frame(maxHeight: argHeight)
                
                Menu {
                    ForEach(Array(options.enumerated()), id: \.offset) { item in
                        Button(item.element) {
                            block.argumentRawValues[index] = item.offset
                        }
                    }
                } label: {
                    Text(String(block.argumentRawValues[index]))
                        .frame(minWidth: 75, minHeight: argHeight, maxHeight: argHeight, alignment: .center)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5)
                        )
                }
                .allowsHitTesting(block.isModifiable)
            }
            .fixedSize(horizontal: true, vertical: false)
            
        case .VariableArgument(let index):
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                    .frame(maxHeight: argHeight)
                
                Menu {
                    ForEach(Array(context.variableNames.enumerated()), id: \.offset) { item in
                        Button(item.element) {
                            block.argumentRawValues[index] = item.offset
                        }
                    }
                } label: {
                    Text(context.variableNames.count == 0 ? "" : String(context.variableNames[block.argumentRawValues[index]]))
                        .frame(minWidth: 75, minHeight: argHeight, maxHeight: argHeight, alignment: .center)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 5)
                        )
                }
                .allowsHitTesting(block.isModifiable)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}
