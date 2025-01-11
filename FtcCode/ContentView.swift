//
//  ContentView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/16/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                GridBackgroundView()
                
                VStack {
                    Text("FTSnap")
                        .font(.custom("Press Start 2P", size: 30))
                        .padding()
                    
                    NavigationLink(destination: ProgramView()) {
                        Text("Start coding")
                            .font(.custom("Press Start 2P", size: 20))
                            .frame(maxWidth: 400, maxHeight: 75)
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
