//
// AudioSpectrum02
// A demo project for blog: https://juejin.im/post/5c1bbec66fb9a049cb18b64c
// Created by: potato04 on 2019/1/30
//

import UIKit

extension SpectrumView {
    enum SpectraBarCapStyle: Int {
        case butt, round
    }
    enum Style: Int {
        case linear, circle
    }
}

class SpectrumView: UIView {
    
    var barCapStyle: SpectraBarCapStyle = .round {
        didSet {
            leftMaskLayer.lineCap = barCapStyle == .round ? .round : .butt
            rightMaskLayer.lineCap = leftMaskLayer.lineCap
        }
    }
    var style: Style = .circle
    
    private let bottomSpace: CGFloat = 0.0
    private let topSpace: CGFloat = 0.0
    
    var leftGradientLayer = CAGradientLayer()
    var rightGradientLayer = CAGradientLayer()
    private let leftMaskLayer = CAShapeLayer()
    private let rightMaskLayer = CAShapeLayer()
    
    var spectra:[[Float]]? {
        didSet {
            if let spectra = spectra {
                // left channel
                let leftPath = UIBezierPath()
                switch style {
                case .linear:
                    let space = bounds.width / CGFloat(spectra[0].count * 3 - 1)
                    let barWidth = space * 2
                    leftMaskLayer.lineWidth = 0
                    for (i, amplitude) in spectra[0].enumerated() {
                        let x = CGFloat(i) * (barWidth + space) + space
                        let y = translateAmplitudeToYPosition(amplitude: amplitude)
                        let radius = barCapStyle == .round ? barWidth / 2 : 0
                        let height = bounds.height - bottomSpace - y + radius
                        let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height), cornerRadius: radius)
                        leftPath.append(bar)
                    }
                case .circle:
                    let centerX = bounds.width / 2
                    let centerY = (bounds.height - topSpace - bottomSpace) / 2
                    let radius = (bounds.height - topSpace - bottomSpace) / 2
                    let space = 2 * Float.pi * Float(radius) / Float(spectra[0].count * 2)
                    let barWidth = space * 0.5
                    let spaceDegree = 2 * Float.pi / Float(spectra[0].count * 2)
                    leftMaskLayer.lineWidth = CGFloat(barWidth)
                    for (i, amplitude) in spectra[0].enumerated() {
                        let currentRadius = translateAmplitudeToRadius(amplitude: amplitude)
                        let currentDegree = CGFloat(i) * 2 * CGFloat(spaceDegree) + CGFloat(spaceDegree)
                        let bar = UIBezierPath()
                        bar.move(to: .init(x: centerX + cos(currentDegree) * radius / 2, y: centerY + sin(currentDegree) * radius / 2))
                        bar.addLine(to: .init(x: centerX + cos(currentDegree) *  (radius / 2 + currentRadius), y: centerY + sin(currentDegree) * ( radius / 2 + currentRadius)))
                        leftPath.append(bar)
                    }
                }
                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                animation.toValue = leftPath.cgPath
                leftMaskLayer.add(animation, forKey: nil)
                
                leftMaskLayer.path = leftPath.cgPath
                leftGradientLayer.frame = CGRect(x: 0, y: topSpace, width: bounds.width, height: bounds.height - topSpace - bottomSpace)
                
                // right channel
                if spectra.count >= 2 {
                    let rightPath = UIBezierPath()
                    switch style {
                    case .linear:
                        let space = bounds.width / CGFloat(spectra[0].count * 3 - 1)
                        let barWidth = space * 2
                        rightMaskLayer.lineWidth = 0
                        for (i, amplitude) in spectra[1].enumerated() {
                            let x = CGFloat(spectra[1].count - 1 - i) * (barWidth + space) + space
                            let y = translateAmplitudeToYPosition(amplitude: amplitude)
                            let radius = barCapStyle == .round ? barWidth / 2 : 0
                            let height = bounds.height - bottomSpace - y + radius
                            let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height), cornerRadius: radius)
                            rightPath.append(bar)
                        }
                    case .circle:
                        let centerX = bounds.width / 2
                        let centerY = (bounds.height - topSpace - bottomSpace) / 2
                        let radius = (bounds.height - topSpace - bottomSpace) / 2
                        let space = 2 * Float.pi * Float(radius) / Float(spectra[0].count * 2)
                        let barWidth = space * 0.5
                        let spaceDegree = 2 * Float.pi / Float(spectra[0].count * 2)
                        rightMaskLayer.lineWidth = CGFloat(barWidth)
                        for (i, amplitude) in spectra[1].enumerated() {
                            let currentRadius = translateAmplitudeToRadius(amplitude: amplitude)
                            let currentDegree = CGFloat(spectra[1].count - 1 - i) * 2 * CGFloat(spaceDegree) + CGFloat(spaceDegree)
                            let bar = UIBezierPath()
                            bar.move(to: .init(x: centerX + cos(currentDegree) * radius / 2, y: centerY + sin(currentDegree) * radius / 2))
                            bar.addLine(to: .init(x: centerX + cos(currentDegree) *  (radius / 2 + currentRadius), y: centerY + sin(currentDegree) * ( radius / 2 + currentRadius)))
                            rightPath.append(bar)
                        }
                    }
                    
                    let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                    animation.toValue = rightPath.cgPath
                    rightMaskLayer.add(animation, forKey: nil)
                    
                    rightMaskLayer.path = rightPath.cgPath
                    rightGradientLayer.frame = CGRect(x: 0, y: topSpace, width: bounds.width, height: bounds.height - topSpace - bottomSpace)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        isUserInteractionEnabled = false
        rightGradientLayer.colors = [UIColor.init(red: 52/255, green: 232/255, blue: 158/255, alpha: 1.0).cgColor,
                                     UIColor.init(red: 15/255, green: 52/255, blue: 67/255, alpha: 1.0).cgColor]
        rightGradientLayer.locations = [0.6, 1.0]
        rightGradientLayer.mask = rightMaskLayer
        rightMaskLayer.strokeColor = UIColor.black.cgColor
        rightMaskLayer.lineCap = .round
        self.layer.addSublayer(rightGradientLayer)
        
        leftGradientLayer.colors = [UIColor.init(red: 194/255, green: 21/255, blue: 0/255, alpha: 1.0).cgColor,
                                    UIColor.init(red: 255/255, green: 197/255, blue: 0/255, alpha: 1.0).cgColor]
        leftGradientLayer.locations = [0.6, 1.0]
        leftGradientLayer.mask = leftMaskLayer
        leftMaskLayer.strokeColor = UIColor.black.cgColor
        leftMaskLayer.lineCap = .round
        self.layer.addSublayer(leftGradientLayer)
    }
    
    private func translateAmplitudeToYPosition(amplitude: Float) -> CGFloat {
        let barHeight: CGFloat = CGFloat(amplitude) * (bounds.height - bottomSpace - topSpace)
        return bounds.height - bottomSpace - barHeight
    }
    
    private func translateAmplitudeToRadius(amplitude: Float) -> CGFloat {
        let radius: CGFloat = CGFloat(amplitude) * ((bounds.height - topSpace - bottomSpace) / 2)
        return radius
    }
}
