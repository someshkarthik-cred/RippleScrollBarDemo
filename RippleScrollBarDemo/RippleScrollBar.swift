//
//  RippleScrollBar.swift
//  RippleScrollBarDemo
//
//  Created by Somesh Karthik on 23/09/22.
//

import UIKit

final class RippleScrollBar: UIView {
    private let leftInstance = RippleReplicatorInstance()
    private let rightInstance = RippleReplicatorInstance()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        addSubview(leftInstance)
        addSubview(rightInstance)
        
        leftInstance.clipsToBounds = true
        rightInstance.clipsToBounds = true
        leftInstance.tintColor = UIColor(red: 114/255, green: 41/255, blue: 217/255, alpha: 1.0)
        leftInstance.direction = .left
        leftInstance.rippleLineWidth = 4
        
        rightInstance.direction = .right
        rightInstance.rippleLineWidth = leftInstance.rippleLineWidth
        rightInstance.tintColor = leftInstance.tintColor
        
        leftInstance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftInstance.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftInstance.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            leftInstance.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftInstance.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        rightInstance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightInstance.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            rightInstance.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightInstance.bottomAnchor.constraint(equalTo: bottomAnchor),
            rightInstance.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    func setPercentage(_ percentage: CGFloat) {
        rightInstance.setOffsetPercentage(percentage)
        leftInstance.setOffsetPercentage(percentage)
    }
}

private final class RippleReplicatorInstance: UIView {
    enum Direction {
        case left
        case right
    }
    
    override class var layerClass: AnyClass {
        CAReplicatorLayer.self
    }
    
    // MARK: Private Properties
    private var replicatorLayer: CAReplicatorLayer {
        layer as! CAReplicatorLayer
    }
    
    //MARK:- View Properties
    private let rippleShape = CAShapeLayer()
    
    private let rippleTranslation: CGFloat = 50
    
    //MARK:- Size constants and Margins
    private var arcRadius: CGFloat {
        bounds.height/2
    }

    private var rippleOffset: CGFloat {
        rippleSize.width - arcRadius
    }

    private let numberOfRipples: Int = 3
    
    // MARK: Public Properties
    override var tintColor: UIColor! {
        didSet {
            updateRipple()
        }
    }
    
    var direction: Direction = .left {
        didSet {
            updateRipple()
        }
    }
    
    var rippleSize: CGSize {
        let rippleWidth = bounds.width/CGFloat(numberOfRipples)
        return CGSize(width: rippleWidth + arcRadius*0.35, height: bounds.height)
    }
    
    /// Use this property to change the linewidth of child ripples
    /// Default value is `1`
    var rippleLineWidth: CGFloat = 1 {
        didSet {
            updateRipple()
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: Public Functions
    func setup() {
        rippleShape.fillColor = nil
        replicatorLayer.addSublayer(rippleShape)
        replicatorLayer.instanceCount = numberOfRipples
    }
    
    /// It will update the spacing between each ripples by taking
    /// ``direction``, `rippleOffset`` and ``rippleOffsetPercentage`` applied to `x`
    func setOffsetPercentage(_ percentage: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        switch direction {
        case .left:
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(rippleOffset * percentage, 0, 0)
        case .right:
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(-1 * rippleOffset * (1-percentage), 0, 0)
        }
        CATransaction.commit()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path: UIBezierPath
        switch direction {
        case .left:
            path = UIBezierPath(arcCenter: CGPoint(x: arcRadius, y: rippleSize.height/2), radius: rippleSize.height/2 - rippleLineWidth/2, startAngle: 3 * .pi/2, endAngle: .pi/2, clockwise: false)

            path.addLine(to: CGPoint(x: rippleSize.width, y: bounds.height-rippleLineWidth/2))
            path.move(to: CGPoint(x: arcRadius, y: rippleLineWidth/2))
            path.addLine(to: CGPoint(x: rippleSize.width, y: rippleLineWidth/2))

        case .right:
            let arcOriginX = rect.width - arcRadius

            path = UIBezierPath(arcCenter: CGPoint(x: arcOriginX, y: rippleSize.height/2), radius: rippleSize.height/2 - rippleLineWidth/2, startAngle: 3 * .pi/2, endAngle: .pi/2, clockwise: direction == .right)

            path.addLine(to: CGPoint(x: 0, y: bounds.height-rippleLineWidth/2))
            path.move(to: CGPoint(x: arcOriginX, y: rippleLineWidth/2))
            path.addLine(to: CGPoint(x: 0, y: rippleLineWidth/2))

        }

        rippleShape.path = path.cgPath
    }

    // MARK: Private Functions
    
    /// It will update the ripple related properties and frame
    private func updateRipple() {
        rippleShape.strokeColor = tintColor.cgColor
        rippleShape.lineWidth = rippleLineWidth
        let xOrigin = direction == .left ? 0 : bounds.width - rippleSize.width
        rippleShape.frame = CGRect(x: xOrigin, y: 0, width: rippleSize.width, height: rippleSize.height)
    }
}

