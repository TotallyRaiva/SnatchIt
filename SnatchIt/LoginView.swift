//
//  LoginView.swift
//  SnatchIt
//
//  Created by Reiwa on 08.06.2025.
//
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authService: AuthService
    
    @State private var  errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔐Login to SnatchIt")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding( )
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action:{ authService.signIn(email: email, password: password){ result in
                    switch result {
                        case .success(()):
                            print("Login succesful")
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            print("Login failed")
                    }
                }
                }) {
                    Text("Login")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                NavigationLink("Don't have an account? Sign up!",destination: SignUpView(authService: authService))
                   .padding(.top)
            }
            .padding()
        }
    }
    
}
#Preview {
    LoginView(authService: AuthService())
}
