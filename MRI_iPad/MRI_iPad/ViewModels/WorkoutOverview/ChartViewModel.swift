//
//  ChartViewModel.swift
//  MRIChart
//
//  Created by Daniel Nugraha on 15.05.21.
//
import Foundation
import Charts
import SwiftUI
import Shared

/// ViewModel for ChartView
class ChartViewModel: ObservableObject {
    //state will change if button "-> km" is clicked
    @Published var xAxisType: AxisType = .time
    //these var represents datasets from each of the the three graphs
    @Published var heartRateDataSet: [LineChartDataSet] = []
    @Published var speedDataSet: [LineChartDataSet] = []
    @Published var altitudeDataSet: [LineChartDataSet] = []
    //state will change if new value in rolling average text field is entered
    @Published var rollingAverage: Int = 1
    //these var are the internal vars for the view model
    var heartRateSamples: [Sample] = []
    var speedSamples: [Sample] = []
    var altitudeSamples: [Sample] = []
    var heartRateZones: [Double] = []
    
    init(workout: GetWorkoutMediator) {
        //fetching the values from the model
        if let heartRate = workout.trainingZones.heartRate {
            heartRateZones = [
                Double(heartRate.zone4),
                Double(heartRate.zone3),
                Double(heartRate.zone2),
                Double(heartRate.zone1),
                Double(heartRate.zone0)
            ]
        } else {
            heartRateZones = []
        }
        workout.combinedProfiles.forEach { profile in
            heartRateSamples.append(Sample(secondsSinceStart: profile.secondsSinceStart,
                                           value: profile.heartRate ?? 0.0,
                                           distance: profile.distance ?? 0.0))
            speedSamples.append(Sample(secondsSinceStart: profile.secondsSinceStart, value: profile.speed ?? 0.0, distance: profile.distance ?? 0.0))
            altitudeSamples.append(
                Sample(
                    secondsSinceStart: profile.secondsSinceStart,
                    value: profile.altitude ?? 0.0,
                    distance: profile.distance ?? 0.0
                )
            )
        }
        //convert the sample values to its dataset
        heartRateDataSet = convertToLineChartViewDataSet(samples: heartRateSamples)
        speedDataSet = convertToLineChartViewDataSet(samples: speedSamples)
        altitudeDataSet = convertToLineChartViewDataSet(samples: altitudeSamples)
        //customize the new data sets
        customizeModelDataSets()
    }
    
    /// Switch the XAxis unit from km to time and vice versa
    func switchXAxis() {
        //switching the state var xAxisType
        switch xAxisType {
        case .distance:
            xAxisType = .time
            
        case .time:
            xAxisType = .distance
        }
        
        //perform rolling average with the new xAxis values
        heartRateDataSet = rollingAverage(samples: heartRateSamples, interval: rollingAverage, axisType: xAxisType)
        speedDataSet = rollingAverage(samples: speedSamples, interval: rollingAverage, axisType: xAxisType)
        altitudeDataSet = rollingAverage(samples: altitudeSamples, interval: rollingAverage, axisType: xAxisType)
        //customize the new data sets
        customizeModelDataSets()
    }
    
    /// Calculate rolling average for each dataset in heart rate, speed, and altitude graphs
    func renderRollingAverage() {
        heartRateDataSet = rollingAverage(samples: heartRateSamples, interval: rollingAverage, axisType: xAxisType)
        speedDataSet = rollingAverage(samples: speedSamples, interval: rollingAverage, axisType: xAxisType)
        altitudeDataSet = rollingAverage(samples: altitudeSamples, interval: rollingAverage, axisType: xAxisType)
        customizeModelDataSets()
    }
    
    /// Customize and colors  the line data set of heart rate, speed, and altitude graphs
    private func customizeModelDataSets() {
        customizeDataSet(ret: heartRateDataSet[0])
        customizeDataSet(ret: speedDataSet[0])
        customizeDataSet(ret: altitudeDataSet[0])
        coloringOtherDataSet(ret: speedDataSet[0])
        coloringOtherDataSet(ret: altitudeDataSet[0])
        coloringHeartRateDataSet(ret: heartRateDataSet[0])
    }
    
    /// Customize a line data set passed in parameter :
    ///     - Disable circle and text on each values, disable highlight dash line
    ///     - Set linewidth to 5 and highlight line width to 1
    ///     - Enable vertical highlighting and disable horizontal highlighting
    private func customizeDataSet(ret: LineChartDataSet) {
        ret.drawCirclesEnabled = false
        ret.drawValuesEnabled = false
        ret.lineWidth = 4
        ret.highlightColor = UIColor(Color.DarkBlue)
        ret.highlightLineWidth = 2.0
        ret.highlightLineDashLengths = nil
        ret.drawVerticalHighlightIndicatorEnabled = true
        ret.drawHorizontalHighlightIndicatorEnabled = false
    }
    
    /// Apply gradient color to heart rate data set
    /// Colors from 'RangeGraph' are reused here
    private func coloringHeartRateDataSet(ret: LineChartDataSet) {
        ret.isDrawLineWithGradientEnabled = true
        let profile = [220.0, 160.0, 100.0, 40.0, 0.0]
        let colors = [
            NSUIColor(Color.RangeGraphRed),
            NSUIColor(Color.RangeGraphOrange),
            NSUIColor(Color.RangeGraphGreen),
            NSUIColor(Color.RangeGraphLightBlue),
            NSUIColor(Color.RangeGraphBlue)
        ]
        //add the profile here
        let minMax = minMax(dataSet: ret, profile: profile, colors: colors)
        ret.gradientPositions = minMax.gradientPositions.map { CGFloat($0) }
        ret.colors = minMax.gradientColors
    }
    
    /// Color the data set line to blue
    private func coloringOtherDataSet(ret: LineChartDataSet) {
        let blue = #colorLiteral(red: 47.0/255.0, green: 73.0/255.0, blue: 209.0/255.0, alpha: 0.8)
        ret.colors = [blue]
    }
    
    /// Map the sample's values to data sets with time as xAxis unit as initial values to the published datasets, heart rate, speed, and altitude
    func convertToLineChartViewDataSet(samples: [Sample]) -> [LineChartDataSet] {
        var entries: [ChartDataEntry] = []
        entries = samples.map {
            ChartDataEntry(x: Double($0.secondsSinceStart), y: $0.value)
        }
        let ret = LineChartDataSet(entries: entries)
        ret.label = AxisType.time.description
        return [ret]
    }
    
    /// Determine the min max value of the calculated rolling average dataset
    /// and set the gradient positions and colors for the the dataset
    /// - Parameters:
    ///     - dataSet: the new calculated rolling average dataset
    ///     - profile: heart rate profile of the patient in descending order
    ///     - colors: reused colors from range graph
    /// - Returns:
    ///     - tuple of new profile and color array for the new calculated rolling average dataset
    func minMax(dataSet: LineChartDataSet, profile: [Double], colors: [UIColor]) -> (gradientPositions: [Double], gradientColors: [UIColor]) {
        var retProfile: [Double] = []
        var retColors: [UIColor] = []
        if let min = dataSet.entries.min(by: { $0.y < $1.y })?.y, let max = dataSet.entries.max(by: { $0.y < $1.y })?.y {
            //looping the heart rate profile, from greatest to smallest
            for index in profile.indices {
                //skipping the profile that is greater than max value
                if profile[index] > max {
                    continue
                }
                //adding the allowed profile and color to the return array
                //allowed profile x : max >= x >= min
                retProfile.append(profile[index])
                retColors.append(colors[index])
                //quit the loop if the profile is smaller then the min value
                if profile[index] < min {
                    break
                }
            }
            //set the first and last return profile array to min max values
            if !retProfile.isEmpty {
                retProfile[0] = max
                if retProfile.count > 1 {
                    retProfile[retProfile.count - 1] = min
                }
            }
        }
        return (retProfile, retColors)
    }
    
    /// Calculate the rolling average from sample array and maps it to dataset
    /// - Parameters
    ///     - samples: the sample array, can be heart rate, speed or altitude
    ///     - interval: range of datapoints that will be averaged together
    ///     - axisType: which xAxis unit are being presented right now in the view
    /// - Returns
    ///     - [LineChartDataSet]: an array consists of 1 uncustomized LineChartDataSet
    func rollingAverage(samples: [Sample], interval: Int, axisType: AxisType) -> [LineChartDataSet] {
        //checking if sample is empty or the interval given is bigger than the sample size
        precondition(samples.count > interval)
        precondition(!samples.isEmpty)
        //using compactMap to discard nil values and create a new ChartDataEntry array
        let result = (0..<samples.count).compactMap { index -> ChartDataEntry? in
            //skipping the first interval - 1 samples
            if index - interval + 1 < 0 {
                return nil
            }
            //define the index range
            let range = index - interval + 1..<index + 1
            //summing the values in the index range
            let sum = samples[range].reduce(0, { sample1, sample2 in
                sample1 + sample2.value
            })
            //dividing the summed values with the interval
            let result = Double(sum) / Double(interval)
            //instantiating a chart entry based on the current xAxis unit
            if axisType == .time {
                return ChartDataEntry(x: Double(samples[index].secondsSinceStart), y: result)
            } else {
                return ChartDataEntry(x: Double(samples[index].distance), y: result)
            }
        }
        //instantiating a new data set consists of new computed values
        let ret = LineChartDataSet(entries: result)
        ret.label = axisType.description
        return [ret]
    }
}
