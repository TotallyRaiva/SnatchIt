//
//  LoginView.swift
//  SnatchIt
//
//  Created by Reiwa on 09.06.2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var nickname = ""
    @ObservedObject var authService: AuthService
    
    @State private var errorMessage: String?
    
    
    var body: some View {
        VStack(spacing:20) {
            Text("📝 Sign Up for SnatchIt")
                .font(.largeTitle)
                .bold()
            
            TextField("Enter nickname", text: $nickname)
                .autocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
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
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                authService.signUp(email: email, password: password) { result in
                    switch result {
                        case .success(()):
                            // Save nickname & email to Firestore
                            if let user = Auth.auth().currentUser {
                                let db = Firestore.firestore()
                                db.collection("users").document(user.uid).setData([
                                    "email": email,
                                    "nickname": nickname
                                ]) { error in
                                    if let error = error {
                                        print("Error saving user data: \(error.localizedDescription)")
                                    } else {
                                        print("User profile saved in Firestore!")
                                    }
                                }
                            }
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Sign Up")
                    .bold( )
                    .frame(maxWidth: .infinity)
                    .padding( )
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            }
        .padding( )
        }
    }

#Preview {
    SignUpView(authService: AuthService())
}
