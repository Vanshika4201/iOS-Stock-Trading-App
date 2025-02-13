//
//  SplashScreenView.swift
//  PortfolioApp
//
//  Created by Avi Aswal on 5/1/24.
//

import SwiftUI

struct SplashScreenView: View {

    @State private var isActive = false
    @State private var isShowingLoadingScreen: Bool = false

    var body: some View {
        
        VStack {
                    if isActive {
                        if isShowingLoadingScreen {
                            // Show the loading screen
                            LoadingView()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation {
                                            self.isShowingLoadingScreen = false
                                        }
                                    }
                                }
                        } else {
                            // Move to the ContentView after the loading screen
                            ContentView()
                        }
                    } else {
                        // Show the splash image initially
                        Image("splash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation {
                                        self.isActive = true
                                        self.isShowingLoadingScreen = true
                                    }
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        
//        if isActive {
//            ContentView()
//        } else {
//            VStack {
//                VStack{
//                    Image("splash")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 300, height: 300)
//                }
//            }
//            .onAppear() {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    self.isActive = true
//                }
//            }
//        }
 
    }
}

#Preview {
    SplashScreenView()
}
