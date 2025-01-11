//
//  PlayButtonView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/15/24.
//

import SwiftUI

struct PlayButtonView: View {
    @ObservedObject var program: Program
    
    var body: some View {
        Button(action: {
            program.toggleRunning()
        }) {
            let showPlay = !program.running
            
            ZStack {
                Circle()
                    .fill(showPlay ? .green : .red)
                    .frame(width: 110, height: 110)
                
                Image(systemName: showPlay ? "play.fill" : "stop.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: showPlay ? 60 : 50, height: showPlay ? 60 : 50)
                    .offset(x: showPlay ? 5 : 2)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .alert(item: $program.errorMessage) { errorMessage in
            switch errorMessage.type {
            case .incomplete:
                Alert(title: Text("Incomplete program"), message: Text("Don't forget to fill in all the blanks in your program before running it!"))
                
            case .socket:
                Alert(title: Text("Connection error"), message: Text("There was a problem communicating with the robot."))
                
            case .other:
                Alert(title: Text("Error"), message: Text("An unexpected error occurred: " + errorMessage.data!))
            }
        }
    }
}

#Preview {
    PlayButtonView(program: Program())
}
