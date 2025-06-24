//
//  GangDetailsView.swift
//  SnatchIt
//
//  Created by Reiwa on 24.06.2025.
//
import SwiftUI
import FirebaseFirestore

struct CrewMemberProfile: Identifiable {
    let id: String
    let nickname: String
    let avatar: String?
    let isBoss: Bool
}

struct GangDetailsView: View {
    let gang: SharedGroup
    let isBoss: Bool // True if user is boss
    // Add your own view model for member management, loot, etc.
    
    @State private var crew: [CrewMemberProfile] = [] // State array for crew profiles
    @State private var bossProfile: CrewMemberProfile? = nil // State for boss profile
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Gang Boss:")
                        Text(bossProfile?.nickname ?? "Unknown") // Use bossProfile nickname or Unknown
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Gang Name:")
                        Text(gang.name)
                    }
                    HStack {
                        Text("Description:")
                        Text("-")
                    }
                } header: {
                    Text("Boss Panel")
                }
                Section {
                    if crew.isEmpty {
                        Text("No crew members")
                    } else {
                        ForEach(crew) { member in
                            HStack {
                                Image(systemName: member.avatar ?? "person.fill")
                                Text(member.nickname)
                                if member.isBoss {
                                    Text("Boss").font(.caption).foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Crew")
                }
                Section {
                    // Show group expenses here!
                    Text("No loot yet!") // Placeholder
                } header: {
                    Text("Loot Log")
                }
                if isBoss {
                    Section {
                        Button("Recruit Crew") { /* Invite flow */ }
                        Button("Kick from Gang") { /* Kick flow */ }
                        Button("Rename Gang") { /* Edit flow */ }
                        Button("Bust Up Gang") { /* Delete gang */ }
                            .foregroundColor(.red)
                    } header: {
                        Text("Recruit or Kick Crew")
                    }
                }
                Section {
                    Button("Drop Out") { /* Leave gang flow */ }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Gang: \(gang.name)")
            .onAppear {
                let db = Firestore.firestore()
                var fetchedCrew: [CrewMemberProfile] = []
                let bossId = gang.bosses.first
                
                // Fetch bosses (Boss is first)
                for bossId in gang.bosses {
                    db.collection("users").document(bossId).getDocument { snapshot, error in
                        guard let data = snapshot?.data(), error == nil else { return }
                        let nickname = data["nickname"] as? String ?? "Unknown"
                        let avatar = data["avatar"] as? String
                        let profile = CrewMemberProfile(id: bossId, nickname: nickname, avatar: avatar, isBoss: true)
                        DispatchQueue.main.async {
                            bossProfile = profile
                            if !fetchedCrew.contains(where: { $0.id == profile.id }) {
                                fetchedCrew.append(profile)
                                crew = fetchedCrew
                            }
                        }
                    }
                }
                
                // Fetch members
                for memberId in gang.members {
                    db.collection("users").document(memberId).getDocument { snapshot, error in
                        guard let data = snapshot?.data(), error == nil else { return }
                        let nickname = data["nickname"] as? String ?? "Unknown"
                        let avatar = data["avatar"] as? String
                        let isBoss = memberId == bossId
                        let profile = CrewMemberProfile(id: memberId, nickname: nickname, avatar: avatar, isBoss: isBoss)
                        DispatchQueue.main.async {
                            if isBoss {
                                bossProfile = profile
                            }
                            if !fetchedCrew.contains(where: { $0.id == profile.id }) {
                                fetchedCrew.append(profile)
                                crew = fetchedCrew
                            }
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    GangDetailsView(
        gang: SharedGroup(
            id: "dummyGang",
            name: "Snatchers",
            members: ["uid1", "uid2"],
            bosses: ["uid1"],
            inviteCode: nil,
            createdAt: Date()
        ),
        isBoss: true
    )
}
