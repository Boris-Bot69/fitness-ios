//
//  TrainingsRatingsGraph.swift
//  DoctorsApp
//
//  Created by Patrick Witzigmann on 12.06.21.
//

import SwiftUI

///This Graph shown the number of trainings rated as being bad, medium and good
struct TrainingsRatingsGraph: View {
    let widthOfViewInPixels: Double = 70
    
    let badRatings: Double
    let mediumRatings: Double
    let goodRatings: Double
    var numberOfTotalRatings: Double {
        badRatings + mediumRatings + goodRatings
    }
    
    init (badRatings: Int, mediumRatings: Int, goodRatings: Int) {
        self.badRatings = Double(badRatings)
        self.mediumRatings = Double(mediumRatings)
        self.goodRatings = Double(goodRatings)
    }
    
    var body: some View {
        if badRatings + mediumRatings + goodRatings == 0 {
            Text("none")
        } else {
            HStack {
                VStack {
                    EmptyView()
                }
                .frame(width: CGFloat(badRatings / numberOfTotalRatings * widthOfViewInPixels), height: 38, alignment: .center)
                .background(Color.RangeGraphRed)
                
                VStack {
                    EmptyView()
                }
                .frame(width: CGFloat(mediumRatings / numberOfTotalRatings * widthOfViewInPixels), height: 38, alignment: .center)
                .background(Color.RangeGraphOrange)
                
                VStack {
                    EmptyView()
                }
                .frame(width: CGFloat(goodRatings / numberOfTotalRatings * widthOfViewInPixels), height: 38, alignment: .center)
                .background(Color.RangeGraphGreen)
            }.cornerRadius(5)
        }
    }
}
