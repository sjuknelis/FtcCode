//
//  Block.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/21/24.
//

import Foundation
import SwiftUI

class Block: ObservableObject, BlockParent {
    let uuid: UUID
    let props: BlockProps
    
    @Published var argumentBlocks: [Block?] = []
    @Published var argumentRawValues: [Int] = []
    @Published var bracketBlocks: [Block]?
    
    @Published var program: Program
    var parent: BlockParent?
    
    var isModifiable: Bool {
        !program.running && parent != nil
    }
    
    init(props: BlockProps, program: Program, parent: BlockParent? = nil) {
        self.uuid = UUID()
        self.props = props
        self.program = program
        self.parent = parent
        
        for item in props.display {
            switch item {
            case .BooleanArgument(_), .NumberArgument(_), .SelectableNumberArgument(_, _), .VariableArgument(_):
                argumentBlocks.append(nil)
                argumentRawValues.append(0)
                
            case .Text(_):
                break
            }
        }
        bracketBlocks = props.type == .Bracket ? [] : nil
    }
    
    private convenience init(props: BlockProps, program: Program, parent: BlockParent?, argumentBlocks: [Block?], argumentRawValues: [Int], bracketBlocks: [Block]?) {
        self.init(props: props, program: program, parent: parent)
        
        self.argumentBlocks = argumentBlocks
        self.argumentRawValues = argumentRawValues
        self.bracketBlocks = bracketBlocks
        
        for block in argumentBlocks {
            if let block = block {
                block.parent = self
            }
        }
        if let bracketBlocks = bracketBlocks {
            for block in bracketBlocks {
                block.parent = self
            }
        }
    }
    
    func clone(parent: BlockParent?) -> Block {
        return Block(
            props: props,
            program: program,
            parent: parent,
            argumentBlocks: argumentBlocks,
            argumentRawValues: argumentRawValues,
            bracketBlocks: bracketBlocks
        )
    }
    
    func deleteChild(_ child: Block) {
        for index in 0..<argumentBlocks.count {
            if argumentBlocks[index]?.uuid == child.uuid {
                argumentBlocks[index] = nil
                return
            }
        }
        if let bracketBlocks = bracketBlocks {
            for index in 0..<bracketBlocks.count {
                if bracketBlocks[index].uuid == child.uuid {
                    self.bracketBlocks!.remove(at: index)
                    return
                }
            }
        }
    }
    
    func isComplete(variablesExist: Bool) -> Bool {
        for item in props.display {
            switch item {
            case .BooleanArgument(let index):
                if argumentBlocks[index] == nil {
                    return false
                }
                
            case .VariableArgument(_):
                if !variablesExist {
                    return false
                }
                
            case .Text(_), .NumberArgument(_), .SelectableNumberArgument(_, _):
                break
            }
        }
        
        for block in argumentBlocks {
            if !(block?.isComplete(variablesExist: variablesExist) ?? true) {
                return false
            }
        }
        if let bracketBlocks = bracketBlocks {
            for block in bracketBlocks {
                if !block.isComplete(variablesExist: variablesExist) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func isAncestor(_ block: Block?) -> Bool {
        if let block = block {
            var testAncestor: BlockParent? = self
            while testAncestor is Block {
                if (testAncestor as! Block).uuid == block.uuid {
                    return true
                }
                
                testAncestor = (testAncestor as! Block).parent
            }
        }
        
        return false
    }
}

enum BlockType {
    case Bracket
    case Action
    case Boolean
    case Number
}

enum DisplayItem: Hashable, Identifiable {
    var id: Self { return self }
    
    case Text(String)
    case BooleanArgument(Int)
    case NumberArgument(Int)
    case SelectableNumberArgument(Int, [String])
    case VariableArgument(Int)
}
