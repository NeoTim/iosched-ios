//
//  Copyright (c) 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

extension UILabel {

  func setLineHeightMultiple(_ lineHeightMultiple: CGFloat) {
    if let text = text {
      let attributedString = NSMutableAttributedString(string: text)
      let style = NSMutableParagraphStyle()
      style.lineHeightMultiple = lineHeightMultiple

      attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                    value: style,
                                    range: NSRange(location: 0, length: text.count))
      self.attributedText = attributedString
    }
  }

  func enableAdjustFontForContentSizeCategory() {
    if #available(iOS 10, *) {
      adjustsFontForContentSizeCategory = true
    }
  }

}
