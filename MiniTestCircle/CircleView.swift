//
//  CircleView.swift
//  MiniTestCircle
//
//  Created by Le Ngoc Trung on 7/6/24.
//

import UIKit

class CircleView: UIView {
    private let circleWithNumRadius: CGFloat = 30
    private var point: CGPoint = .zero
    private var circleCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    private var radius: CGFloat {
        return min(bounds.width, bounds.height) / 2 - 20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        configView()
    }
    
    private
    func configView() {
        backgroundColor = .white
        isUserInteractionEnabled = true
        point = CGPoint(x: circleCenter.x, y: circleCenter.y - radius)
        
        /// dragging view
        let dragView = UIView(frame: CGRect(x: point.x - 15, y: point.y - 15, width: 30, height: 30))
        dragView.backgroundColor = .white
        dragView.layer.borderWidth = 5
        dragView.layer.borderColor = UIColor(hexString: "4F7EF6").cgColor
        dragView.layer.cornerRadius = 15
        dragView.clipsToBounds = true
        dragView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag)))
        dragView.isUserInteractionEnabled = true
        self.addSubview(dragView)
    }
    
    @objc
    func onDrag(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let draggedView = gesture.view
        
        let angle = getAngle(location)
        let newPoint = CGPoint(x: circleCenter.x + radius * cos(angle), y: circleCenter.y + radius * sin(angle))

        draggedView?.center = newPoint

        point = newPoint
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawBackgroundCircle(context: context)

        let percentageFilled = calculatePercentFilled()

        /// Draw blue circle scaling
        let blueCircleRadius = calculateBlueCircleRadius(percent: percentageFilled)
        context.setFillColor(UIColor(hexString: "4F7EF6").cgColor)
        context.addEllipse(in: CGRect(x: circleCenter.x - blueCircleRadius, y: circleCenter.y - blueCircleRadius, width: 2 * blueCircleRadius, height: 2 * blueCircleRadius))
        context.fillPath()
        
        /// Draw blue line
        context.setStrokeColor(UIColor(hexString: "4F7EF6").cgColor)
        context.setLineWidth(5.0)
        context.beginPath()
        context.addArc(center: circleCenter, radius: radius, startAngle: getAngle(CGPoint(x: circleCenter.x, y: circleCenter.y - radius)), endAngle: getAngle(point), clockwise: false)
        context.strokePath()
        
        /// Draw circle contain percent num in center
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: CGRect(x: circleCenter.x - CGFloat(circleWithNumRadius), y: circleCenter.y - CGFloat(circleWithNumRadius), width: CGFloat(2 * circleWithNumRadius), height: CGFloat(2 * circleWithNumRadius)))
        context.fillPath()
        
        // Draw the percentage text centered in the green circle
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor(hexString: "4F7EF6")
        ]
        let percentageText = "\(Int(percentageFilled*100))%"
        let textSize = percentageText.size(withAttributes: attributes)
        let textRect = CGRect(x: circleCenter.x - textSize.width / 2, y: circleCenter.y - textSize.height / 2, width: textSize.width, height: textSize.height)
        percentageText.draw(in: textRect, withAttributes: attributes)
    }
    
    private
    func drawBackgroundCircle(context: CGContext) {
        /// Draw circle
        context.addEllipse(in: CGRect(x: circleCenter.x - radius, y: circleCenter.y - radius, width: 2 * radius, height: 2 * radius))
        context.clip()
        
        /// Fill color
        let colors = [
            UIColor.init(hexString: "C8D6F7").cgColor,
            UIColor.init(hexString: "E5EAF7").cgColor
        ]
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: colorLocations) else {
            return
        }
        
        context.drawRadialGradient(
            gradient,
            startCenter: circleCenter,
            startRadius: 0.0,
            endCenter: circleCenter,
            endRadius: radius,
            options: .drawsAfterEndLocation
        )
        setNeedsDisplay()
    }
    
    
}

extension CircleView {
    private
    func getAngle(_ p: CGPoint) -> CGFloat {
        return atan2(p.y - circleCenter.y, p.x - circleCenter.x)
    }
    
    private func calculateBlueCircleRadius(percent: CGFloat) -> CGFloat {
        let maxBlueRadius = radius
        return (maxBlueRadius - circleWithNumRadius) * percent + circleWithNumRadius
    }
    
    private
    func calculatePercentFilled() -> CGFloat {
        let initAngle = atan2((circleCenter.y-radius) - circleCenter.y, circleCenter.x - circleCenter.x)
        let currentAngle = atan2(point.y - circleCenter.y, point.x - circleCenter.x)
        
        var angleDifference = currentAngle - initAngle
    
        if angleDifference < 0 {
            angleDifference += 2 * .pi
        }

        let blueLineLength = radius * angleDifference
        let circleLength = 2 * .pi * radius
        return blueLineLength / circleLength
    }
}


extension UIColor {

  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3:
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }

}
