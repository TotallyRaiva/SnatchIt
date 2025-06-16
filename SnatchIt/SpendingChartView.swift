//
//  SpendingChartView.swift
//  SnatchIt
//
//  Created by Reiwa on 16.06.2025.
//
import SwiftUI
import Charts

struct SpendingChartView: View {
    let expenses: [Expense]

    var body: some View {
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        let chartData = grouped.map { category, items in
            (category, items.reduce(0) { $0 + $1.amount })
        }

        VStack {
            Text("Spending by Category")
                .font(.title2)
                .bold()
                .padding(.top)

            Chart {
                ForEach(chartData, id: \.0) { category, total in
                    BarMark(
                        x: .value("Category", category),
                        y: .value("Total", total)
                    )
                }
            }
            .frame(height: 280)
            .padding()
        }
    }
}

struct SpendingChartView_Previews: PreviewProvider {
    static var previews: some View {
        SpendingChartView(expenses: [])
    }
}
