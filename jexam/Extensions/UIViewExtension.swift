//  MIT License
//
//  Copyright (c) 2018 Philipp Matthes
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Philipp Matthes on 01.02.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func blur(style: UIBlurEffectStyle = .extraLight, color: UIColor = .white, alpha: CGFloat = 0.5) {
        self.backgroundColor = color.withAlphaComponent(alpha)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let mainBlurEffectView = UIVisualEffectView(effect: blurEffect)
        mainBlurEffectView.layer.zPosition = -1000
        mainBlurEffectView.frame = self.bounds
        mainBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mainBlurEffectView)
    }
    
    func isBlurred() -> Bool {
        for subview in self.subviews {
            if let subview = subview as? UIVisualEffectView {
                if let _ = subview.effect as? UIBlurEffect {
                    return true
                }
            }
        }
        return false
    }
    
    func roundCorners(_ corners : UIRectCorner, withRadius radius: CGFloat) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: radius, height: radius)).cgPath        
        self.layer.mask = rectShape
    }
}

extension UIView {
    func addDashedBorder(color: CGColor = UIColor.white.cgColor) {
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 20).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
