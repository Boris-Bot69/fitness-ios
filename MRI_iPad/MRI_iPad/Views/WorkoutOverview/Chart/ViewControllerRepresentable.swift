//
//  ViewControllerRepresentable.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 21.05.21.
//

import Foundation
import Charts
import SwiftUI
import Shared

/// SwiftUI representable of a UIKit ChartView
struct HealthChartView: UIViewControllerRepresentable {
    @EnvironmentObject var model: Model
    @ObservedObject var viewModel: ChartViewModel
    
    init(workout: GetWorkoutMediator) {
        viewModel = ChartViewModel(workout: workout)
    }
    
    /// Initialize a new ViewControllerRepresentable
    /// Create a SwiftUI representable of UIKit Storyboard and its UIViewController and assign a coordinator
    func makeUIViewController(context: UIViewControllerRepresentableContext<HealthChartView>) -> HealthViewController {
        //reading the storyboard file
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: "HealthViewController") as HealthViewController
        //set the coordinator as the ViewController's delegate
        viewController.delegate = context.coordinator
        return viewController
    }
    
    /// Specify how to update the view if the state objects published in ChartViewModel is changed
    /// Behavior on update:
    ///     - Set the right valueFormatter for xAxis
    ///     - Update the chart views with new datasets and notify them
    ///     - Animate the new datasets
    func updateUIViewController(_ uiViewController: HealthViewController, context: Context) {
        //set ChartXAxisFormatter according to the xAxis unit
        if viewModel.heartRateDataSet[0].label == AxisType.time.description {
            uiViewController.heartRateChartView.xAxis.valueFormatter = ChartXAxisFormatter()
            uiViewController.speedChartView.xAxis.valueFormatter = ChartXAxisFormatter()
            uiViewController.altitudeChartView.xAxis.valueFormatter = ChartXAxisFormatter()
            uiViewController.heartRateChartView.xAxis.avoidFirstLastClippingEnabled = true
            uiViewController.speedChartView.xAxis.avoidFirstLastClippingEnabled = true
            uiViewController.altitudeChartView.xAxis.avoidFirstLastClippingEnabled = true
        } else {
            uiViewController.heartRateChartView.xAxis.valueFormatter = ChartKilometerFormatter()
            uiViewController.speedChartView.xAxis.valueFormatter = ChartKilometerFormatter()
            uiViewController.altitudeChartView.xAxis.valueFormatter = ChartKilometerFormatter()
        }
        //pushing the dataset from the viewmodel to the view
        uiViewController.heartRateChartView.data = LineChartData(dataSets: viewModel.heartRateDataSet)
        uiViewController.speedChartView.data = LineChartData(dataSets: viewModel.speedDataSet)
        uiViewController.altitudeChartView.data = LineChartData(dataSets: viewModel.altitudeDataSet)
        //add padding to the line chart
        configureLeftAxisPadding(uiViewController.heartRateChartView)
        configureLeftAxisPadding(uiViewController.speedChartView)
        configureLeftAxisPadding(uiViewController.altitudeChartView)
        //notify the three graphs view that dataset is changed
        uiViewController.heartRateChartView.notifyDataSetChanged()
        uiViewController.speedChartView.notifyDataSetChanged()
        uiViewController.altitudeChartView.notifyDataSetChanged()
        //remove previous highlighted value
        uiViewController.heartRateChartView.highlightValues(nil)
        uiViewController.speedChartView.highlightValues(nil)
        uiViewController.altitudeChartView.highlightValues(nil)
        //ask the views to animate the new data set
        uiViewController.heartRateChartView.animate(xAxisDuration: 1.0)
        uiViewController.speedChartView.animate(xAxisDuration: 1.0)
        uiViewController.altitudeChartView.animate(xAxisDuration: 1.0)
        uiViewController.switchXAxisButton.setTitle(viewModel.xAxisType.description, for: .normal)
        
        if viewModel.speedSamples.reduce(0, { $0 + Int($1.value) }) == 0 {
            uiViewController.speedLabel.isHidden = true
            uiViewController.speedChartView.isHidden = true
        }
        
        if viewModel.altitudeSamples.reduce(0, { $0 + Int($1.value) }) == 0 {
            uiViewController.altitudeLabel.isHidden = true
            uiViewController.altitudeChartView.isHidden = true
        }
    }
    
    func configureLeftAxisPadding(_ uiView: LineChartView) {
        uiView.leftAxis.xOffset = 17
        if Int(uiView.lineData?.dataSet(at: 0)?.yMax ?? 0) / 10 > 0 {
            uiView.leftAxis.xOffset = 15
        }
        if Int((uiView.lineData?.dataSet(at: 0)?.yMax) ?? 0) / 100 > 0 {
            uiView.leftAxis.xOffset = 10
        }
        if Int((uiView.lineData?.dataSet(at: 0)?.yMax) ?? 0) / 1000 > 0 {
            uiView.leftAxis.xOffset = 5
        }
        if uiView.lineData?.dataSet(at: 0)?.yMin == 0.0 && uiView.lineData?.dataSet(at: 0)?.yMax == 0.0 {
            uiView.leftAxis.xOffset = 15
        }
    }
    
    /// Set a coordinator to the ViewControllerRepresentable
    func makeCoordinator() -> Coordinator {
        return(Coordinator(parent: self))
    }
}

/// Act as a bridge between SwiftUI View-ViewModel-Model architecture and UIKit MVC
/// Conform to UIKit ViewControllerDelegate protocol and extends NSObject (conforming to swiftui Coordinator guideline)
/// Events detected in UIKit will change the SwiftUI ViewModel through this Coordinator
/// Any change on the SwiftUI ViewModel will automatically call updateUIViewController method in UIViewControllerRepresentable
class Coordinator: NSObject, ViewControllerDelegate {
    var parent: HealthChartView
    
    init(parent: HealthChartView) {
        self.parent = parent
    }
    
    func initialize(_ viewController: HealthViewController) {
    }
    
    /// Call switchAxis method in view model
    func switchXAxis(_ viewController: HealthViewController) {
        parent.viewModel.switchXAxis()
    }
    
    /// Set the viewModel rollingAverage based on input in text field and calls renderRollingAverage method
    func rollingAverage(_ viewController: HealthViewController) {
        let sampleRate = 10
        if let text = viewController.rollingAverage.text {
            if var newValue = Int(text) {
                newValue /= sampleRate
                if newValue < 1 {
                    newValue = 1
                    viewController.rollingAverage.text = String(newValue)
                }
                if newValue >= (parent.viewModel.heartRateSamples.count * 3 / 5) {
                    newValue = parent.viewModel.heartRateSamples.count * 3 / 5 - 1
                    viewController.rollingAverage.text = String(newValue)
                }
                parent.viewModel.rollingAverage = newValue
                print("rolling average initiated")
                parent.viewModel.renderRollingAverage()
            }
        }
    }
}

/// Encapsulate time and distance xAxis unit
public enum AxisType: String, CustomStringConvertible {
    public var description: String {
        self.rawValue
    }
    
    case distance = "-> min"
    case time = "-> km"
}
