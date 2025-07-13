//
//  GangDetailsView.swift
//  SnatchIt
//
//  Created by Reiwa on 24.06.2025.
//
import SwiftUI
import FirebaseFirestore
import Combine

/// Model representing a crew member's profile for display.
struct CrewMemberProfile: Identifiable {
    let id: String
    let nickname: String
    let avatar: String?
    let isBoss: Bool
}

/// View displaying detailed information about a gang, including crew members, loot, and management options.
struct GangDetailsView: View {
    let gang: SharedGroup
    let isBoss: Bool // True if user is boss
    @StateObject private var viewModel: GangDetailsViewModel

    // State array holding crew member profiles
    @State private var crew: [CrewMemberProfile] = []
    // State holding the boss profile separately for display
    @State private var bossProfile: CrewMemberProfile? = nil
    // Controls display of the recruit crew sheet
    @State private var showRecruitSheet = false
    
    init(gang: SharedGroup, isBoss: Bool, viewModel: GangDetailsViewModel) {
        self.gang = gang
        self.isBoss = isBoss
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Section displaying boss information and gang metadata
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
                
                // Section listing all crew members with indication of boss
                Section {
                    if crew.isEmpty {
                        Text("No crew members")
                    } else {
                        ForEach(crew) { member in
                            HStack {
                                Image(systemName: member.avatar ?? "person.fill")
                                Text(member.nickname)
                                if member.isBoss {
                                    Text("Boss")
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                } else if isBoss {
                                    Spacer()
                                    Button(action: {
                                        viewModel.confirmKickMember = member
                                    }) {
                                        Image(systemName: "person.crop.circle.badge.xmark")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                } header: {
                    Text("Crew")
                }
                .alert(item: $viewModel.confirmKickMember) { member in
                    Alert(
                        title: Text("Kick \(member.nickname)?"),
                        message: Text("Are you sure you want to remove this member from the gang?"),
                        primaryButton: .destructive(Text("Kick")) {
                            viewModel.kickCrew(memberId: member.id) { success in
                                if success {
                                    crew.removeAll { $0.id == member.id }
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                // Section for displaying loot or group expenses (currently placeholder)
                Section {
                    // Show group expenses here!
                    Text("No loot yet!") // Placeholder
                } header: {
                    Text("Loot Log")
                }
                
                // Section with management actions available only to the boss
                if isBoss {
                    Section {
                        VStack(alignment: .leading) {
                            Text("Invite by Email or UID").font(.caption)
                            TextField("example@email.com or UID", text: Binding(
                                get: { viewModel.inviteInput },
                                set: { viewModel.inviteInput = $0 }
                            ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Send Invite") {
                                viewModel.recruitCrew(invitee: viewModel.inviteInput) { success in
                                    viewModel.inviteInput = ""
                                }
                            }
                        }
                        .padding(.vertical, 4)

                        Button("Rename Gang") { /* Edit flow */ }
                        Button("Bust Up Gang") { /* Delete gang */ }
                            .foregroundColor(.red)
                    } header: {
                        Text("Recruit or Kick Crew")
                    }
                }
                
                // Section for leaving the gang, available to all members
                Section {
                    Button("Drop Out") { /* Leave gang flow */ }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Gang: \(gang.name)")
            // Alert to show error or success messages from ViewModel
            .alert(isPresented: Binding<Bool>(
                get: {
                    viewModel.errorMessage != nil || viewModel.successMessage != nil
                },
                set: { newValue in
                    if !newValue {
                        viewModel.errorMessage = nil
                        viewModel.successMessage = nil
                    }
                }
            )) {
                Alert(title: Text(viewModel.errorMessage ?? viewModel.successMessage ?? ""))
            }
            // Fetch crew and boss profiles when view appears
            .onAppear {
                let db = Firestore.firestore()
                var fetchedCrew: [CrewMemberProfile] = []
                let bossId = gang.bosses.first
                
                // Fetch bosses (Boss is first)
                for bossId in gang.bosses {
                    db.collection("users").document(bossId).getDocument { snapshot, error in
                        // Ensure document data exists and no error occurred
                        guard let data = snapshot?.data(), error == nil else { return }
                        let nickname = data["nickname"] as? String ?? "Unknown"
                        let avatar = data["avatar"] as? String
                        let profile = CrewMemberProfile(id: bossId, nickname: nickname, avatar: avatar, isBoss: true)
                        DispatchQueue.main.async {
                            // Update bossProfile state with fetched boss data
                            bossProfile = profile
                            // Append to crew list if not already included
                            if !fetchedCrew.contains(where: { $0.id == profile.id }) {
                                fetchedCrew.append(profile)
                                crew = fetchedCrew
                            }
                        }
                    }
                }
                
                // Fetch regular crew members
                for memberId in gang.members {
                    db.collection("users").document(memberId).getDocument { snapshot, error in
                        // Ensure document data exists and no error occurred
                        guard let data = snapshot?.data(), error == nil else { return }
                        let nickname = data["nickname"] as? String ?? "Unknown"
                        let avatar = data["avatar"] as? String
                        // Determine if this member is also a boss
                        let isBoss = memberId == bossId
                        let profile = CrewMemberProfile(id: memberId, nickname: nickname, avatar: avatar, isBoss: isBoss)
                        DispatchQueue.main.async {
                            // Update bossProfile if this member is boss
                            if isBoss {
                                bossProfile = profile
                            }
                            // Append to crew list if not already included
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
    let gang = SharedGroup(
        id: "dummyGang",
        name: "Snatchers",
        members: ["uid1", "uid2"],
        bosses: ["uid1"],
        inviteCode: nil,
        createdAt: Date()
    )
    let viewModel = GangDetailsViewModel(gang: gang)
    GangDetailsView(
        gang: gang,
        isBoss: true,
        viewModel: viewModel
    )
}
