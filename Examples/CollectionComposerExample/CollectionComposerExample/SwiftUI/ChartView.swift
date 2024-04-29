//
//  ChartView.swift
//  CollectionComposerExample
//
//  Created by Akira Matsuda on 2024/04/29.
//

import Charts
import SwiftUI

// MARK: - ChartData

struct ChartData: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}

// MARK: - ChartView

struct ChartView: View {
    var data: [ChartData]

    var body: some View {
        Chart {
            BarMark(
                x: .value("Shape Type", data[0].type),
                y: .value("Total Count", data[0].count)
            )
            BarMark(
                x: .value("Shape Type", data[1].type),
                y: .value("Total Count", data[1].count)
            )
            BarMark(
                x: .value("Shape Type", data[2].type),
                y: .value("Total Count", data[2].count)
            )
        }
    }
}

#Preview {
    ChartView(data: [
        .init(type: "Cube", count: 5),
        .init(type: "Sphere", count: 4),
        .init(type: "Pyramid", count: 4)
    ])
}
