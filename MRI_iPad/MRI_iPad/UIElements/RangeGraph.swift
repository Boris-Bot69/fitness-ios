//
//  RangeGraph.swift
//  DoctorsApp
//
//  Created by Denis Graipel, Patrick Witzigmann and Christopher Schütz on 12.06.21.
//
 
import SwiftUI

///This graph shows the heartrate of a patient respective to the specified heartrate ranges for the respective patient
struct RangeGraph: View {
    // whether or not a text overlay should be displayed on top of each rangregraph section
    let showPercentagesAsText: Bool
    
    // amount of Samples for each zone of the athlete
    // e.g. [10, 20, 30, 40, 20]
    // stands for 10 occurrences in zone 1, 20 occurrences in zone 2, ...
    let zoneValues: [Int]
    
    // total amount of values present in the zoneValues array
    var valuesSum: Double {
        Double(self.zoneValues.reduce(0, +))
    }
    
    init(
        zoneValues: [Int],
        showPercentagesAsText: Bool = false
    ) {
        self.zoneValues = zoneValues
        self.showPercentagesAsText = showPercentagesAsText
    }
    
    func buildRangeGraphSection(
        value: Int,
        color: Color,
        totalWidth: CGFloat,
        height: CGFloat,
        minimumWidthToShowPercentage: Double = 55
    ) -> some View {
        VStack {
            switch showPercentagesAsText {
            case true:
                if (Double(value) / valuesSum * Double(totalWidth)) > minimumWidthToShowPercentage {
                    Text("\(String(format: "%.1f", 100.0 * (Double(value) / valuesSum)))%")
                }
            case false:
                EmptyView()
            }
        }
        .frame(
            width: CGFloat(Double(value) / valuesSum * Double(totalWidth)),
            height: height,
            alignment: .center
        )
        .padding(0)
        .background(color)
    }
     
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                buildRangeGraphSection(
                    value: zoneValues[0],
                    color: Color.RangeGraphBlue,
                    totalWidth: geometry.size.width,
                    height: geometry.size.height
                )
                
                buildRangeGraphSection(
                    value: zoneValues[1],
                    color: Color.RangeGraphLightBlue,
                    totalWidth: geometry.size.width,
                    height: geometry.size.height
                )
                
                buildRangeGraphSection(
                    value: zoneValues[2],
                    color: Color.RangeGraphGreen,
                    totalWidth: geometry.size.width,
                    height: geometry.size.height
                )
                
                buildRangeGraphSection(
                    value: zoneValues[3],
                    color: Color.RangeGraphOrange,
                    totalWidth: geometry.size.width,
                    height: geometry.size.height
                )
                
                buildRangeGraphSection(
                    value: zoneValues[4],
                    color: Color.RangeGraphRed,
                    totalWidth: geometry.size.width,
                    height: geometry.size.height
                )
            }.cornerRadius(5)
        }
    }
}

struct HeartRangeGraphWithoutPercentages_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RangeGraph(
                zoneValues: [20, 30, 15, 15, 20],
                showPercentagesAsText: true
            )
        }
        .frame(
            width: 500,
            height: 38,
            alignment: .center
        )
        .previewLayout(.sizeThatFits)
    }
}
