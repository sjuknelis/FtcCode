//
//  RobotSocket.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/15/24.
//

import Foundation
import Socket

class RobotSocket {
    private var socket: Socket?
    
    init(host: String, port: Int) throws {
        do {
            socket = try Socket.create()
            try socket!.connect(to: host, port: Int32(port), timeout: 3000)
            
            let startTime = getUnixTime()
            while getUnixTime() - startTime < 3 {
                Thread.sleep(forTimeInterval: 0.01)
            }
            if socket!.isConnected {
                return
            }
        } catch {}
        
        throw RobotSocketError.socket
    }
    
    func write(_ data: String) throws {
        if let socket = socket {
            do {
                try socket.write(from: data + "\n")
                return
            } catch {}
        }
        
        throw RobotSocketError.socket
    }
    
    func read() throws -> Int {
        if let socket = socket {
            do {
                var data = Data()
                let bytesRead = try socket.read(into: &data)
                
                if bytesRead > 0, let text = String(data: data, encoding: .utf8) {
                    if let value = Int(text) {
                        return value
                    }
                }
            } catch {}
        }
        
        throw RobotSocketError.socket
    }
    
    func close() {
        if let socket = socket {
            socket.close()
        }
    }
}

enum RobotSocketError: Error {
    case socket
}
