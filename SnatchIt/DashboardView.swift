//
//  DashboardView.swift
//  SnatchIt
//
//  Created by Reiwa on 09.06.2025.
//
import SwiftUI


struct DashboardView: View {
    var body: some View {
        VStack {
            Text("🏠 Welcome to SnatchIt!")
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Here’s where your expenses will show up.")
                .foregroundColor(.gray)

            Spacer()
        }
    }
}

#Preview {
    DashboardView()
}
