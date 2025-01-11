//
//  ConnectSidebarView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/16/24.
//

import SwiftUI

struct ConnectSidebarView: View {
    @StateObject var program: Program
    
    var closeSidebar: () -> Void
    
    let portFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ""
        return formatter
    }()
    
    @State private var isValueAlertShown = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                
                Text("Connection Settings")
                    .font(.custom("Press Start 2P", size: 18))
                    .multilineTextAlignment(.center)
                    .padding()
                
                ConnectSettingItemView(
                    title: "Host",
                    value: program.robotHost,
                    validate: { value in
                        let parts = value.split(separator: ".")
                        
                        if parts.count != 4 {
                            return false
                        }
                        
                        for part in parts {
                            if let intPart = Int(part) {
                                if intPart < 0 || intPart > 255 {
                                    return false
                                }
                            } else {
                                return false
                            }
                        }
                        
                        return true
                    },
                    submit: { value in
                        program.robotHost = value
                    }
                )
                .padding()
                
                ConnectSettingItemView(
                    title: "Port",
                    value: String(program.robotPort),
                    validate: { value in
                        if let intValue = Int(value) {
                            if intValue < 1024 || intValue > 65535 {
                                return false
                            }
                        } else {
                            return false
                        }
                        
                        return true
                    },
                    submit: { value in
                        program.robotPort = Int(value)!
                    }
                )
                .padding()
                
                Button(action: {
                    closeSidebar()
                }) {
                    Text("Close")
                        .frame(maxWidth: 150, minHeight: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.blue, lineWidth: 5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding()
                
                Spacer()
            }
            
            Spacer()
        }
        .background(.white)
        .edgesIgnoringSafeArea(.vertical)
        .frame(maxWidth: 300, maxHeight: .infinity)
        .overlay(
            Rectangle()
                .frame(width: 1, height: nil, alignment: .leading)
                .foregroundColor(.black)
                .edgesIgnoringSafeArea(.vertical),
            alignment: .leading
        )
    }
}

struct ConnectSettingItemView: View {
    @State private var isAlertShown = false
    @State private var alertValue = ""
    @State private var isInvalidAlertShown = false
    
    let title: String
    var value: String
    let validate: (String) -> Bool
    let submit: (String) -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                alertValue = value
                isAlertShown = true
            }) {
                Text("Set " + title)
                    .frame(maxWidth: 120, minHeight: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.blue, lineWidth: 5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .alert("Set " + title, isPresented: $isAlertShown) {
                TextField(title, text: $alertValue)
                    .multilineTextAlignment(.center)
                Button("OK") {
                    if validate(alertValue) {
                        submit(alertValue)
                    } else {
                        isInvalidAlertShown = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert(isPresented: $isInvalidAlertShown) {
                Alert(title: Text("Invalid " + title))
            }
            
            Text(value)
            
            Spacer()
        }
    }
}

#Preview {
    ConnectSidebarView(program: Program(), closeSidebar: {})
}
