//
//  GridBackgroundView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/27/24.
//

import SwiftUI

struct GridBackgroundView: View {
    let spacing = 60
    
    let lineColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    ForEach(0..<(Int(geometry.size.width) / spacing), id: \.self) { index in
                        if index != 0 {
                            lineColor
                                .frame(maxWidth: 1)
                        }
                        
                        Color.clear
                            .frame(maxWidth: CGFloat(spacing))
                    }
                }
                
                VStack {
                    ForEach(0..<(Int(geometry.size.height) / spacing), id: \.self) { index in
                        if index != 0 {
                            lineColor
                                .frame(maxHeight: 1)
                        }
                        
                        Color.clear
                            .frame(maxHeight: CGFloat(spacing))
                    }
                }
            }
        }
    }
}

#Preview {
    GridBackgroundView()
}
