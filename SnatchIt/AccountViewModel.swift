//
//  AccountViewModel.swift
//  SnatchIt
//
//  Created by Reiwa on 21.06.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore



class AccountViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var email: String = ""

    let avatarOptions = ["person.circle.fill", "person.crop.circle", "person.fill.turn.down", "person.2.circle", "flame.circle", "star.circle", "pawprint.circle"]
    @Published var selectedAvatar: String = "person.circle.fill"
    func fetchUserInfo() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.nickname = data["nickname"] as? String ?? ""
                self.email = data["email"] as? String ?? user.email ?? ""
                self.selectedAvatar = data["avatar"] as? String ?? "person.circle.fill"
            }
        }
    }
    
    func selectAvatar(_ icon: String) {
        self.selectedAvatar = icon
        saveAvatar()
    }

    private func saveAvatar() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "avatar": selectedAvatar
        ]) { error in
            if let error = error {
                print("Error saving avatar: \(error.localizedDescription)")
            }
        }
    }
}
