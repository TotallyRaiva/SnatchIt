//
//  AuthService.swift
//  SnatchIt
//
//  Created by Reiwa on 08.06.2025.
//
import Foundation
import FirebaseAuth

class AuthService: ObservableObject{
    @Published var user: User?
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("🔥 Firebase sign-up error:", error.localizedDescription)
                completion(.failure(error))
            } else {
                self.user = result?.user
                completion(.success(()))
            }
        }
    }
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth() .signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.user = result?.user
                completion(.success(()))
            }
        }
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("❌ Sign out failed:", error.localizedDescription)
        }
    }
}
