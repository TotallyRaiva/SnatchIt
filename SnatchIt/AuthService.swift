//
//  AuthService.swift
//  SnatchIt
//
//  Created by Reiwa on 08.06.2025.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService: ObservableObject{
    @Published var user: User?
    
    init() {
        if let authUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(authUser.uid).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let user = User(
                        id: authUser.uid,
                        email: data["email"] as? String ?? authUser.email ?? "",
                        nickname: data["nickname"] as? String ?? "",
                        avatar: data["avatar"] as? String
                    )
                    DispatchQueue.main.async {
                        self.user = user
                    }
                } else {
                    DispatchQueue.main.async {
                        self.user = nil
                    }
                }
            }
        } else {
            self.user = nil
        }
    }
    
    func signUp(email: String, password: String, nickname: String = "", avatar: String = "person.circle.fill", completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("🔥 Firebase sign-up error:", error.localizedDescription)
                completion(.failure(error))
            } else if let authUser = result?.user {
                // Save profile to Firestore
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "email": email,
                    "nickname": nickname,
                    "avatar": avatar
                ]
                db.collection("users").document(authUser.uid).setData(userData) { error in
                    if let error = error {
                        print("Error saving user profile:", error.localizedDescription)
                    }
                    // Fetch profile after saving
                    db.collection("users").document(authUser.uid).getDocument { snapshot, error in
                        if let data = snapshot?.data() {
                            let user = User(
                                id: authUser.uid,
                                email: data["email"] as? String ?? email,
                                nickname: data["nickname"] as? String ?? "",
                                avatar: data["avatar"] as? String
                            )
                            DispatchQueue.main.async {
                                self.user = user
                                completion(.success(()))
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.user = nil
                                completion(.failure(error ?? NSError(domain: "", code: -1)))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let authUser = result?.user {
                // Fetch user profile from Firestore
                let db = Firestore.firestore()
                db.collection("users").document(authUser.uid).getDocument { snapshot, error in
                    if let data = snapshot?.data() {
                        let user = User(
                            id: authUser.uid,
                            email: data["email"] as? String ?? email,
                            nickname: data["nickname"] as? String ?? "",
                            avatar: data["avatar"] as? String
                        )
                        DispatchQueue.main.async {
                            self.user = user
                            completion(.success(()))
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.user = nil
                            completion(.failure(error ?? NSError(domain: "", code: -1)))
                        }
                    }
                }
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
