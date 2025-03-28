//
//  ViewController.swift
//  ChartView
//
//  Created by Daniel Nugraha on 19.05.21.
//

import UIKit
import Charts
import SwiftUI

//swiftlint:disable class_delegate_protocol private_outlet weak_delegate private_action

/// Protocol for the delegate of HealthViewController
/// Specify and handle the behavior from an event of the HealthViewController
/// Bridge swiftui and uikit, Coordinator from swiftui implements this protocol
protocol ViewControllerDelegate {
    func initialize(_ viewController: HealthViewController)
    func switchXAxis(_ viewController: HealthViewController)
    func rollingAverage(_ viewController: HealthViewController)
}

/// Controller for ChartsView, contain heart rate, speed and altitude graphs, rollingAverage text field and switchXAxis button
/// Conform to ChartViewDelegate, sync marker on a highlighted value on three graphs
public class HealthViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var heartRateChartView: LineChartView!
    @IBOutlet weak var speedChartView: LineChartView!
    @IBOutlet weak var altitudeChartView: LineChartView!
    @IBOutlet weak var rollingAverage: UITextField!
    @IBOutlet weak var switchXAxisButton: UIButton!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    var delegate: ViewControllerDelegate?
    
    /// Specify the behavior of the view when the view is loaded
    /// Apply to heart rate, speed, and altitude graphs :
    ///     - Assign delegate and marker
    ///     - Customize the x- and y- axis
    ///     - Enable highlight on drag gesture
    override public func viewDidLoad() {
        super.viewDidLoad()
        if delegate != nil {
            delegate?.initialize(self)
        }
        switchXAxisButton.layer.cornerRadius = 8
        switchXAxisButton.clipsToBounds = true
        rollingAverage.layer.cornerRadius = 8
        rollingAverage.layer.borderWidth = 1.0
        rollingAverage.layer.borderColor = Color.DarkBlue.cgColor
        rollingAverage.textAlignment = .center
        //assign delegate to each chart
        heartRateChartView.delegate = self
        speedChartView.delegate = self
        altitudeChartView.delegate = self
        //customize chart axis
        configureAxises(heartRateChartView)
        configureAxises(speedChartView)
        configureAxises(altitudeChartView)
        //enable dragging
        heartRateChartView.highlightPerDragEnabled = true
        speedChartView.highlightPerDragEnabled = true
        altitudeChartView.highlightPerDragEnabled = true
        
        heartRateChartView.scaleXEnabled = false
        heartRateChartView.scaleYEnabled = false
        speedChartView.scaleYEnabled = false
        speedChartView.scaleYEnabled = false
        altitudeChartView.scaleXEnabled = false
        altitudeChartView.scaleYEnabled = false
        
        heartRateChartView.doubleTapToZoomEnabled = false
        speedChartView.doubleTapToZoomEnabled = false
        altitudeChartView.doubleTapToZoomEnabled = false
        
        //instantiating marker for each graph
        let heartRateMarker = RectMarker(
            color: UIColor(Color.DarkBlue),
            font: UIFont.systemFont(ofSize: 16),
            insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 4.0, right: 4.0)
        )
        let speedMarker = RectMarker(
            color: UIColor(Color.DarkBlue),
            font: UIFont.systemFont(ofSize: 16),
            insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 4.0, right: 4.0)
        )
        let altitudeMarker = RectMarker(
            color: UIColor(Color.DarkBlue),
            font: UIFont.systemFont(ofSize: 16),
            insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 4.0, right: 4.0)
        )
        
        heartRateMarker.minimumSize = CGSize(width: 60, height: 30)
        speedMarker.minimumSize = CGSize(width: 60, height: 30)
        altitudeMarker.minimumSize = CGSize(width: 60, height: 30)
        
        heartRateChartView.marker = heartRateMarker
        speedChartView.marker = speedMarker
        altitudeChartView.marker = altitudeMarker
        
        heartRateMarker.chartView = heartRateChartView
        speedMarker.chartView = speedChartView
        altitudeMarker.chartView = altitudeChartView
        
        //set listener on text field and switchXAxis button
        self.rollingAverage.addTarget(self, action: #selector(onReturn), for: .editingDidEndOnExit)
        self.switchXAxisButton.addTarget(self, action: #selector(switchXAxis), for: .touchUpInside)
    }
    
    /// Specify the behavior of the view on new rolling average text field input
    @IBAction func onReturn() {
        self.rollingAverage.resignFirstResponder()
        if delegate != nil {
            delegate?.rollingAverage(self)
        }
    }
    
    /// Specify the behavior of the view after the switch x axis button is clicked
    @IBAction func switchXAxis() {
        if delegate != nil {
            delegate?.switchXAxis(self)
        }
    }
    
    /// Delegate function of ChartView will be called if a value on one of the three graphs is highlighted
    /// Highlights the value on other graphs without calling the delegate again to prevent endless loop
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        heartRateChartView.highlightValue(highlight)
        speedChartView.highlightValue(highlight)
        altitudeChartView.highlightValue(highlight)
    }
    
    /// Customize the x- and y-axis :
    ///     - Disable the right x-axis and legend
    ///     - Set the label count and font
    ///     - Set line width and gridline dash length
    private func configureAxises(_ uiView: LineChartView) {
        uiView.rightAxis.enabled = false
        uiView.legend.enabled = false
        uiView.leftAxis.setLabelCount(5, force: false)
        uiView.xAxis.setLabelCount(9, force: false)
        uiView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        uiView.xAxis.labelFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        uiView.xAxis.yOffset = 10
        uiView.leftAxis.labelFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        uiView.leftAxis.axisLineWidth = 3.0
        uiView.leftAxis.gridLineDashLengths = [3.0]
        uiView.xAxis.gridLineDashLengths = [3.0]
        uiView.xAxis.axisLineWidth = 3.0
        uiView.xAxis.granularityEnabled = true
        uiView.leftAxis.granularityEnabled = true
        uiView.leftAxis.axisLineColor = UIColor(Color.DarkBlue)
        uiView.xAxis.axisLineColor = UIColor(Color.DarkBlue)
        uiView.xAxis.labelTextColor = UIColor(Color.FontPrimary)
        uiView.leftAxis.labelTextColor = UIColor(Color.FontPrimary)
    }
}
