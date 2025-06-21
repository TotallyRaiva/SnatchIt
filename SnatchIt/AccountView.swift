//
//  AccountView.swift
//  SnatchIt
//
//  Created by Reiwa on 16.06.2025.
//
import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @ObservedObject var authService: AuthService
    @StateObject private var viewModel = AccountViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: viewModel.selectedAvatar)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)

                Text("Choose your avatar:")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.avatarOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .resizable()
                                .frame(width: 48, height: 48)
                                .padding(6)
                                .background(viewModel.selectedAvatar == icon ? Color.accentColor.opacity(0.15) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture {
                                    viewModel.selectAvatar(icon)
                                }
                        }
                    }
                }

                Text("Hi, \(viewModel.nickname)!")
                    .font(.title)
                    .bold()

                Text(viewModel.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(role: .destructive) {
                    authService.signOut()
                } label: {
                    Label("Logout", systemImage: "arrow.right.circle")
                }
                .padding(.bottom, 100)
            }
            .padding()
            .onAppear {
                viewModel.fetchUserInfo()
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView(authService: AuthService())
}
