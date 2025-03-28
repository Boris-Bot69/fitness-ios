//
//  RectMarker.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 08.07.21.
//  Adapted from : https://github.com/danielgindi/Charts/issues/3620#:~:text=RectMarker.swift.zip
//

import Foundation
import Charts
import SwiftUI

open class RectMarker: MarkerImage {
    open var color: NSUIColor?
    open var font: NSUIFont?
    open var insets = UIEdgeInsets()
    
    open var minimumSize = CGSize()
    
    fileprivate var label: NSMutableAttributedString?
    fileprivate var _labelSize = CGSize()
    
    public init(color: NSUIColor, font: NSUIFont, insets: UIEdgeInsets) {
        super.init()
        self.color = color
        self.font = font
        self.insets = insets
    }
    
    override open func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        var offset = CGPoint(x: 8, y: 0) //CGPoint(x: 10.0, y:10.0)
        let chart = self.chartView
        var size = self.size
        
        if size.width == 0.0 && image != nil {
            size.width = image?.size.width ?? 0.0
        }
        if size.height == 0.0 && image != nil {
            size.height = image?.size.height ?? 0.0
        }
        
        let width = size.width
        let height = size.height
        let origin = point
        
        if origin.x + offset.x < 0.0 {
            offset.x = -origin.x
        } else if let chart = chart, origin.x + width + offset.x > chart.viewPortHandler.contentRect.maxX {
            offset.x =  -width - 8
        }
        
        if origin.y + offset.y < 0 {
            offset.y = height
        } else if let chart = chart, origin.y + height + offset.y > chart.viewPortHandler.contentRect.maxY {
            offset.y =  -height
        }
        return offset
    }
    
    override open func draw(context: CGContext, point: CGPoint) {
        guard let label = label else {
            return
        }
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        let rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        
        context.saveGState()
        if let color = color {
            //            context.setFillColor(color.cgColor)
            context.beginPath()
            drawRoundedRect(rect: rect, inContext: context, radius: 10.0, borderColor: UIColor.black.cgColor, fillColor: color.cgColor)
            //            context.addRect(rect)
            context.fillPath()
        }
        let labelStartingPointX = (rect.maxX - rect.minX) / 2 + rect.minX - (label.size().width / 2)
        let labelStartingPointY = (rect.maxY - rect.minY) / 2 + rect.minY - (label.size().height / 2)
        label.draw(at: CGPoint(x: labelStartingPointX, y: labelStartingPointY))
        context.restoreGState()
    }
    
    func drawRoundedRect(rect: CGRect,
                         inContext context: CGContext?,
                         radius: CGFloat,
                         borderColor: CGColor,
                         fillColor: CGColor) {
        // 1
        let path = CGMutablePath()
        
        // 2
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
                    radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY ),
                    tangent2End: CGPoint(x: rect.minX, y: rect.maxY),
                    radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY ),
                    tangent2End: CGPoint(x: rect.minX, y: rect.minY),
                    radius: radius)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY ),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY),
                    radius: radius)
        path.closeSubpath()
        
        // 3
        context?.setLineWidth(1.0)
        context?.setFillColor(fillColor)
        context?.setStrokeColor(borderColor)
        
        // 4
        context?.addPath(path)
        context?.drawPath(using: .fillStroke)
    }
    
    
    override open func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        var str = ""
        let mutableString = NSMutableAttributedString( string: str )
        str = String(entry.y.rounded(toPlaces: 1))
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16.0),
            .foregroundColor: NSUIColor.white
        ]
        
        let addedString = NSAttributedString(string: str, attributes: labelAttributes)
        mutableString.append(addedString)
        setLabel(mutableString)
    }
    
    open func setLabel(_ newlabel: NSMutableAttributedString) {
        label = newlabel
        _labelSize = label?.size() ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
