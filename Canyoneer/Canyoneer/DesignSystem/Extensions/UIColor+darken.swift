//  Created by Brice Pollock for Canyoneer on 3/25/24

import Foundation
import UIKit

extension UIColor {

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: max(min(red + percentage/100, 1.0), 0),
                           green: max(min(green + percentage/100, 1.0), 0),
                           blue: max(min(blue + percentage/100, 1.0), 0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
