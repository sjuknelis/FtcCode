//
//  CreateVariableButtonView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 7/25/24.
//

import SwiftUI

struct CreateVariableButtonView: View {
    @ObservedObject var program: Program
    @ObservedObject var context: UserContext
    
    @State private var isAlertShown = false
    @State private var variableName = ""
    
    var body: some View {
        Button(action: {
            isAlertShown = true
        }) {
            Text("Create Variable")
                .frame(maxWidth: 200, minHeight: 50)
                .foregroundColor(.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.red, lineWidth: 5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .alert("Create a variable", isPresented: $isAlertShown) {
            TextField("Variable name", text: $variableName)
            Button("OK", action: createVariable)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Give your new variable a name")
        }
    }
    
    private func createVariable() {
        context.variableNames.append(variableName)
        program.variableValues.append(0)
        variableName = ""
    }
}
