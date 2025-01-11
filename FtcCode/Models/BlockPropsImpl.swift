//
//  BlockPropsImpl.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/24/24.
//

import Foundation
import SwiftUI

struct CommandBlockProps: BlockProps {
    var display: [DisplayItem]
    let colorPair = blockColors.command
    let type = BlockType.Action
    
    let commandFormat: String
    
    init(display: [DisplayItem], commandFormat: String) {
        self.display = display
        self.commandFormat = commandFormat
    }
    
    func evaluate(arguments: [BlockData], program: Program) throws -> BlockData? {
        var argumentValues: [Int] = []
        for argument in arguments {
            if case .Number(let value) = argument {
                argumentValues.append(Int(value))
            }
        }
        
        try program.socket?.write(String(format: commandFormat, arguments: argumentValues))
        
        return nil
    }
}

struct RequestBlockProps: BlockProps {
    var display: [DisplayItem]
    let colorPair = blockColors.request
    let type = BlockType.Number
    
    let requestFormat: String
    
    init(display: [DisplayItem], requestFormat: String) {
        self.display = display
        self.requestFormat = requestFormat
    }
    
    func evaluate(arguments: [BlockData], program: Program) throws -> BlockData? {
        var argumentValues: [Int] = []
        for argument in arguments {
            if case .Number(let value) = argument {
                argumentValues.append(Int(value))
            }
        }
        
        try program.socket?.write(String(format: requestFormat, arguments: argumentValues))
        
        return .Number(Double(try program.socket!.read()))
    }
}

struct ArithmeticBlockProps: BlockProps {
    let display: [DisplayItem]
    let colorPair = blockColors.operation
    let type = BlockType.Number
    
    let expression: (Double, Double) -> Double
    
    init(symbol: String, expression: @escaping (Double, Double) -> Double) {
        display = [.NumberArgument(0), .Text(symbol), .NumberArgument(1)]
        self.expression = expression
    }
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Number(let v1) = arguments[0], case .Number(let v2) = arguments[1] {
            return .Number(expression(v1, v2))
        }
        return .Number(0)
    }
}

struct ComparisonBlockProps: BlockProps {
    let display: [DisplayItem]
    let colorPair = blockColors.operation
    let type = BlockType.Boolean
    
    let expression: (Double, Double) -> Bool
    
    init(symbol: String, expression: @escaping (Double, Double) -> Bool) {
        display = [.NumberArgument(0), .Text(symbol), .NumberArgument(1)]
        self.expression = expression
    }
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Number(let v1) = arguments[0], case .Number(let v2) = arguments[1] {
            return .Boolean(expression(v1, v2))
        }
        return .Boolean(false)
    }
}

struct BiLogicBlockProps: BlockProps {
    let display: [DisplayItem]
    let colorPair = blockColors.operation
    let type = BlockType.Boolean
    
    let expression: (Bool, Bool) -> Bool
    
    init(symbol: String, expression: @escaping (Bool, Bool) -> Bool) {
        display = [.BooleanArgument(0), .Text(symbol), .BooleanArgument(1)]
        self.expression = expression
    }
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Boolean(let v1) = arguments[0], case .Boolean(let v2) = arguments[1] {
            return .Boolean(expression(v1, v2))
        }
        return .Boolean(false)
    }
}

struct NotBlockProps: BlockProps {
    let display: [DisplayItem] = [.Text("not"), .BooleanArgument(0)]
    let colorPair = blockColors.operation
    let type = BlockType.Boolean
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Boolean(let value) = arguments[0] {
            return .Boolean(!value)
        }
        return .Boolean(false)
    }
}

struct BracketBlockProps: BlockProps {
    let display: [DisplayItem]
    let colorPair = blockColors.control
    let type = BlockType.Bracket
    
    let expression: (Bool) -> BlockData
    
    init(symbol: String, expression: @escaping (Bool) -> BlockData) {
        display = [.Text(symbol), .BooleanArgument(0)]
        self.expression = expression
    }
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Boolean(let value) = arguments[0] {
            return expression(value)
        }
        return .BracketState(shouldEnter: false, shouldRepeat: false)
    }
}

struct WaitBlockProps: BlockProps {
    let display: [DisplayItem] = [.Text("wait"), .NumberArgument(0), .Text("seconds")]
    let colorPair = blockColors.control
    let type = BlockType.Action
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Number(let waitSeconds) = arguments[0] {
            let startTime = getUnixTime()
            
            while true {
                if getUnixTime() - startTime >= waitSeconds || program.interrupt {
                    break
                }
                
                Thread.sleep(forTimeInterval: 0.01)
            }
        }
        
        return nil
    }
}

func getUnixTime() -> Double {
    return Date().timeIntervalSince1970
}

struct VariableValueBlockProps: BlockProps {
    let display: [DisplayItem] = [.Text("value of"), .VariableArgument(0)]
    let colorPair = blockColors.variable
    let type = BlockType.Number
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Number(let index) = arguments[0] {
            return .Number(program.variableValues[Int(index)])
        }
        
        return nil
    }
}

struct VariableUpdateBlockProps: BlockProps {
    let display: [DisplayItem]
    let colorPair = blockColors.variable
    let type = BlockType.Action
    
    let expression: (Double, Double) -> Double
    
    init(display: [DisplayItem], expression: @escaping (Double, Double) -> Double) {
        self.display = display
        self.expression = expression
    }
    
    func evaluate(arguments: [BlockData], program: Program) -> BlockData? {
        if case .Number(let index) = arguments[0], case .Number(let value) = arguments[1] {
            program.variableValues[Int(index)] = expression(program.variableValues[Int(index)], value)
        }
        
        return nil
    }
}

let bankBlockProps: [BlockProps] = [
    CommandBlockProps(display: [.Text("set motor"), .SelectableNumberArgument(0, ["0", "1", "2", "3"]), .Text("% to"), .NumberArgument(1)], commandFormat: "mw %d %d"),
    CommandBlockProps(display: [.Text("set servo"), .SelectableNumberArgument(0, ["0", "1", "2", "3", "4", "5"]), .Text("rotation % to"), .NumberArgument(1)], commandFormat: "sw %d %d"),
    
    RequestBlockProps(display: [.Text("inches measured by sensor"), .SelectableNumberArgument(0, ["0", "1", "2", "3"])], requestFormat: "dr %d"),
    RequestBlockProps(display: [.Text("inches driven by motor"), .SelectableNumberArgument(0, ["0", "1", "2", "3"])], requestFormat: "mr %d"),
    RequestBlockProps(display: [.Text("position of servo"), .SelectableNumberArgument(0, ["0", "1", "2", "3", "4", "5"])], requestFormat: "sr %d"),
    RequestBlockProps(display: [.Text("robot angle")], requestFormat: "ir"),
    
    ArithmeticBlockProps(symbol: "+", expression: { v1, v2 in v1 + v2 }),
    ArithmeticBlockProps(symbol: "-", expression: { v1, v2 in v1 - v2 }),
    ArithmeticBlockProps(symbol: "*", expression: { v1, v2 in v1 * v2 }),
    ArithmeticBlockProps(symbol: "/", expression: { v1, v2 in v2 != 0 ? v1 / v2 : 0 }),
    
    ComparisonBlockProps(symbol: "=", expression: { v1, v2 in v1 == v2 }),
    ComparisonBlockProps(symbol: "<", expression: { v1, v2 in v1 < v2 }),
    ComparisonBlockProps(symbol: ">", expression: { v1, v2 in v1 > v2 }),
    
    BiLogicBlockProps(symbol: "and", expression: { v1, v2 in v1 && v2 }),
    BiLogicBlockProps(symbol: "or", expression: { v1, v2 in v1 || v2 }),
    NotBlockProps(),
    
    BracketBlockProps(symbol: "if", expression: { v in .BracketState(shouldEnter: v, shouldRepeat: false) }),
    BracketBlockProps(symbol: "while", expression: { v in .BracketState(shouldEnter: v, shouldRepeat: v) }),
    BracketBlockProps(symbol: "repeat until", expression: { v in .BracketState(shouldEnter: !v, shouldRepeat: !v) }),
    WaitBlockProps(),
    
    VariableValueBlockProps(),
    VariableUpdateBlockProps(display: [.Text("set"), .VariableArgument(0), .Text("to"), .NumberArgument(1)], expression: { stored, value in value }),
    VariableUpdateBlockProps(display: [.Text("change"), .VariableArgument(0), .Text("by"), .NumberArgument(1)], expression: { stored, value in stored + value })
]
