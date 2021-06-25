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
}

class SpectrumView: UIView {
    
    var barWidth: CGFloat = 3.0
    var space: CGFloat = 1.0
    var barCapStyle: SpectraBarCapStyle = .round
    
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
                for (i, amplitude) in spectra[0].enumerated() {
                    let x = CGFloat(i) * (barWidth + space) + space
                    let y = translateAmplitudeToYPosition(amplitude: amplitude)
                    let radius = barCapStyle == .round ? barWidth / 2 : 0
                    let height = bounds.height - bottomSpace - y + radius
                    let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height), cornerRadius: radius)
                    leftPath.append(bar)
                }
                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                animation.toValue = leftPath.cgPath
                leftMaskLayer.add(animation, forKey: nil)
                
                leftMaskLayer.path = leftPath.cgPath
                leftGradientLayer.frame = CGRect(x: 0, y: topSpace, width: bounds.width, height: bounds.height - topSpace - bottomSpace)
                
                // right channel
                if spectra.count >= 2 {
                    let rightPath = UIBezierPath()
                    for (i, amplitude) in spectra[1].enumerated() {
                        let x = CGFloat(spectra[1].count - 1 - i) * (barWidth + space) + space
                        let y = translateAmplitudeToYPosition(amplitude: amplitude)
                        let radius = barCapStyle == .round ? barWidth / 2 : 0
                        let height = bounds.height - bottomSpace - y + radius
                        let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height), cornerRadius: radius)
                        rightPath.append(bar)
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
        rightGradientLayer.colors = [UIColor.init(red: 52/255, green: 232/255, blue: 158/255, alpha: 1.0).cgColor,
                                     UIColor.init(red: 15/255, green: 52/255, blue: 67/255, alpha: 1.0).cgColor]
        rightGradientLayer.locations = [0.6, 1.0]
        rightGradientLayer.mask = rightMaskLayer
        self.layer.addSublayer(rightGradientLayer)
        
        leftGradientLayer.colors = [UIColor.init(red: 194/255, green: 21/255, blue: 0/255, alpha: 1.0).cgColor,
                                    UIColor.init(red: 255/255, green: 197/255, blue: 0/255, alpha: 1.0).cgColor]
        leftGradientLayer.locations = [0.6, 1.0]
        leftGradientLayer.mask = leftMaskLayer
        self.layer.addSublayer(leftGradientLayer)
    }
    
    private func translateAmplitudeToYPosition(amplitude: Float) -> CGFloat {
        let barHeight: CGFloat = CGFloat(amplitude) * (bounds.height - bottomSpace - topSpace)
        return bounds.height - bottomSpace - barHeight
    }
}
