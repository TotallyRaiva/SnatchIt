//
//  DashboardView.swift
//  SnatchIt
//
//  Created by Reiwa on 09.06.2025.
//
import SwiftUI


struct DashboardView: View {
    @StateObject private var firestoreService = FirestoreService()
    @ObservedObject var authService: AuthService
    
    var body: some View {
        VStack {
            Text("🏠 My Expenses")
                .font(.largeTitle)
                .bold()
                .padding()
            
            List(firestoreService.expenses) { expense in
                VStack(alignment: .leading) {
                    Text(expense.category)
                        .font(.headline)
                    Text(expense.comment ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Text("$\(expense.amount, specifier: "%.2f")")
                        Spacer()
                        Text(expense.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }  
                
                Spacer()
            }
        .onAppear {
            if let userId = authService.user?.uid {
                firestoreService.fetchExpenses(forUser: userId)
        }
        }
        }
        }
    
    #Preview {
        DashboardView(authService: AuthService())
    }
