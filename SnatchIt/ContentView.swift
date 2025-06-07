//
//  ContentView.swift
//  SnatchIt
//
//  Created by Reiwa on 07.06.2025.
//

import SwiftUI

struct ContentView: View {
    // Example expense
    let exampleExpense = Expense(amount: 3.50, category: "☕️Coffee", date: Date(), comment: "Morning Latte")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(" My Expenses")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)

            HStack {
                VStack(alignment: .leading) {
                    Text(exampleExpense.category)
                        .font(.headline)
                    Text(exampleExpense.comment ?? "No Comment")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("$\(exampleExpense.amount, specifier: "%.2f")")
                    .bold()
            }
            Text("\(exampleExpense.date.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
