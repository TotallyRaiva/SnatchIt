//
//  GangsView.swift
//  SnatchIt
//
//  Created by Reiwa on 22.06.2025.
//

import SwiftUI

struct Gang: Identifiable {
    let id = UUID()
    let name: String
}

class GangsViewModel: ObservableObject {
    @Published var userGangs: [Gang] = [
        Gang(name: "The Swift Coders"),
        Gang(name: "Night Owls"),
        Gang(name: "Pixel Pirates")
    ]
    
    @Published var showingCreateGang = false
    @Published var showingJoinGang = false
}

struct GangsView: View {
    @StateObject private var viewModel = GangsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                List(viewModel.userGangs) { gang in
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                        Text(gang.name)
                    }
                }
                .listStyle(PlainListStyle())
                
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.showingCreateGang = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Gang")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $viewModel.showingCreateGang) {
                        Text("Create Gang Modal")
                            .font(.largeTitle)
                    }
                    
                    Button(action: {
                        viewModel.showingJoinGang = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Join Gang")
                        }
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $viewModel.showingJoinGang) {
                        Text("Join Gang Modal")
                            .font(.largeTitle)
                    }
                }
                .padding()
            }
            .navigationTitle("Gangs")
        }
    }
}

struct GangsView_Previews: PreviewProvider {
    static var previews: some View {
        GangsView()
    }
}
