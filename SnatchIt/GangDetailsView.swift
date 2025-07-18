//
//  GangDetailsView.swift
//  SnatchIt
//
//  Created by Reiwa on 24.06.2025.
//
import SwiftUI
import FirebaseFirestore
import Combine

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
    
    init(gang: SharedGroup, isBoss: Bool) {
        self.gang = gang
        self.isBoss = isBoss
        self._viewModel = StateObject(wrappedValue: GangDetailsViewModel(gang: gang))
    }
    
    // Temporary initializer for backward compatibility
    init(gang: SharedGroup, isBoss: Bool, currentUserId: String) {
        self.gang = gang
        self.isBoss = isBoss
        self._viewModel = StateObject(wrappedValue: GangDetailsViewModel(gang: gang))
        // currentUserId is ignored for now
    }
    
    var body: some View {
        NavigationView {
            List {
                bossSection
                crewSection
                lootSection
                managementSection
                leaveSection
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
                fetchCrewMembers()
            }
        }
    }
    
    /// Fetch crew members from Firestore and update the UI
    private func fetchCrewMembers() {
        let db = Firestore.firestore()
        let bossIds = Set(gang.bosses)
        
        // Combine all member IDs (bosses and regular members)
        let allMemberIds = Set(gang.bosses + gang.members)
        
        // Fetch all members at once
        for memberId in allMemberIds {
            db.collection("users").document(memberId).getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else { return }
                
                let nickname = data["nickname"] as? String ?? "Unknown"
                let avatar = data["avatar"] as? String
                let isBoss = bossIds.contains(memberId)
                
                let profile = CrewMemberProfile(
                    id: memberId,
                    nickname: nickname,
                    avatar: avatar,
                    isBoss: isBoss
                )
                
                DispatchQueue.main.async {
                    // Update boss profile if this is a boss
                    if isBoss && bossProfile == nil {
                        bossProfile = profile
                    }
                    
                    // Add to crew list if not already present
                    if !crew.contains(where: { $0.id == profile.id }) {
                        crew.append(profile)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var bossSection: some View {
        Section {
            HStack {
                Text("Gang Boss:")
                Text(bossProfile?.nickname ?? "Unknown")
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
    }
    
    @ViewBuilder
    private var crewSection: some View {
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
        .alert(item: Binding<CrewMemberProfile?>(
            get: { viewModel.confirmKickMember },
            set: { viewModel.confirmKickMember = $0 }
        )) { member in
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
    }
    
    @ViewBuilder
    private var lootSection: some View {
        Section {
            Text("No loot yet!") // Placeholder
        } header: {
            Text("Loot Log")
        }
    }
    
    @ViewBuilder
    private var managementSection: some View {
        if isBoss {
            Section {
                VStack(alignment: .leading) {
                    Text("Invite by Email or UID").font(.caption)
                    TextField("example@email.com or UID", text: $viewModel.inviteInput)
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
    }
    
    @ViewBuilder
    private var leaveSection: some View {
        Section {
            Button("Drop Out") { /* Leave gang flow */ }
                .foregroundColor(.red)
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
    GangDetailsView(
        gang: gang,
        isBoss: true
    )
}
