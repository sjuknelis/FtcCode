//
//  Program.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/24/24.
//

import Foundation

class Program: ObservableObject, BlockParent {
    @Published var blocks: [Block] = []
    
    @Published var running = false
    @Published var errorMessage: ProgramErrorMessage?
    
    @Published var robotHost = "127.0.0.1"
    @Published var robotPort = 7123
    
    var interrupt = false
    var socket: RobotSocket?
    var variableValues: [Double] = []
    
    init() {}
    
    init(blocks: [Block]) {
        for block in blocks {
            block.parent = self
        }
        
        self.blocks = blocks
    }
    
    func toggleRunning() {
        if !running {
            run()
        } else {
            interrupt = true
        }
    }
    
    private func run() {
        if running {
            return
        }
        running = true
        
        if !isComplete() {
            errorMessage = ProgramErrorMessage(type: .incomplete)
            running = false
            interrupt = false
            return
        }
        
        for index in 0..<variableValues.count {
            variableValues[index] = 0
        }
        
        DispatchQueue.global().async { [self] in
            do {
                socket = try RobotSocket(host: robotHost, port: robotPort)
                
                for block in blocks {
                    do {
                        _ = try runBlock(block)
                    } catch InterruptError.interrupt {
                        break
                    }
                }
            } catch RobotSocketError.socket {
                DispatchQueue.main.async { [self] in
                    errorMessage = ProgramErrorMessage(type: .socket)
                }
            } catch {
                DispatchQueue.main.async { [self] in
                    errorMessage = ProgramErrorMessage(type: .other, data: error.localizedDescription)
                }
            }
            
            socket?.close()
            
            DispatchQueue.main.async { [self] in
                running = false
                interrupt = false
            }
        }
    }
    
    private func runBlock(_ block: Block) throws -> BlockData? {
        var arguments = try getArgumentData(block: block)
        
        var rval: BlockData?
        if block.props.type == .Bracket {
            if case .BracketState(let shouldEnter, _) = try block.props.evaluate(arguments: arguments, program: self) {
                if shouldEnter {
                    while true {
                        for bracketBlock in block.bracketBlocks! {
                            _ = try runBlock(bracketBlock)
                        }
                        
                        arguments = try getArgumentData(block: block)
                        if case .BracketState(_, let shouldRepeat) = try block.props.evaluate(arguments: arguments, program: self) {
                            if !shouldRepeat {
                                break
                            }
                        }
                    }
                }
            }
        } else {
            rval = try block.props.evaluate(arguments: arguments, program: self)
        }
        
        if interrupt {
            throw InterruptError.interrupt
        }
        return rval
    }
    
    private func getArgumentData(block: Block) throws -> [BlockData] {
        var arguments: [BlockData] = []
        
        for index in 0..<block.argumentBlocks.count {
            if block.argumentBlocks[index] != nil {
                arguments.append(try runBlock(block.argumentBlocks[index]!)!)
            } else {
                arguments.append(.Number(Double(block.argumentRawValues[index])))
            }
        }
        
        return arguments
    }
    
    private func isComplete() -> Bool {
        if blocks.count == 0 {
            return false
        }
        
        for block in blocks {
            if !block.isComplete(variablesExist: variableValues.count != 0) {
                return false
            }
        }
        
        return true
    }
    
    func deleteChild(_ child: Block) {
        for index in 0..<blocks.count {
            if blocks[index].uuid == child.uuid {
                blocks.remove(at: index)
                return
            }
        }
    }
}

enum InterruptError: Error {
    case interrupt
}

struct ProgramErrorMessage: Identifiable {
    let id: UUID
    let type: ProgramErrorMessageType
    let data: String?
    
    init(type: ProgramErrorMessageType) {
        id = UUID()
        self.type = type
        data = nil
    }
    
    init(type: ProgramErrorMessageType, data: String) {
        id = UUID()
        self.type = type
        self.data = data
    }
}

enum ProgramErrorMessageType {
    case incomplete
    case socket
    case other
}
