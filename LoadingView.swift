//
//  LoadingView.swift
//  PortfolioApp
//
//  Created by Avi Aswal on 5/2/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Fetching Data...")
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .scaleEffect(1.5)
                .foregroundColor(.gray)
                .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.8))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingView()
}
