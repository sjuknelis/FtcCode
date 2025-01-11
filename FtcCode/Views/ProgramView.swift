//
//  ProgramView.swift
//  FtcCode
//
//  Created by Simas Juknelis on 6/21/24.
//

import SwiftUI

struct ProgramView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var program = Program()
    @StateObject var context = UserContext()
    
    @State private var showSidebar = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                ProgramControlsView(program: program, context: context)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        Color.gray
                            .opacity(showSidebar ? 0.5 : 0)
                            .animation(.easeInOut, value: showSidebar)
                            .edgesIgnoringSafeArea(.vertical)
                            .allowsHitTesting(showSidebar)
                    )
                
                ConnectSidebarView(program: program, closeSidebar: {
                    withAnimation {
                        showSidebar = false
                    }
                })
                    .frame(width: 300)
                    .offset(x: showSidebar ? 0 : 300)
                    .animation(.easeInOut, value: showSidebar)
            }
        }
        .navigationTitle("My Program")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                }
            }
            
            if !showSidebar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showSidebar.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct ProgramControlsView: View {
    @ObservedObject var program: Program
    @ObservedObject var context: UserContext
    
    var body: some View {
        ZStack {
            GridBackgroundView()
            
            HStack {
                BlockBankView(program: program, context: context)
                    .frame(maxWidth: 400)
                ProgramAreaView(program: program, context: context)
                    .frame(maxWidth: .infinity)
            }
            
            HStack {
                Spacer()
                VStack {
                    PlayButtonView(program: program)
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 15))
                    
                    Spacer()
                    
                    TrashButtonView(context: context)
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 15))
                }
            }
        }
        .navigationTitle("My Program")
    }
}

#Preview {
    ProgramView()
}
