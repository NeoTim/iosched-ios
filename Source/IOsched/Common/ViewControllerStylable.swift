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
import MaterialComponents

/// Used by the base view controller to style itself and its
/// subclasses.
/// - SeeAlso: BaseCollectionViewController
protocol ViewControllerStylable {
  var minHeaderHeight: CGFloat { get }
  var maxHeaderHeight: CGFloat { get }
  var headerBackgroundColor: UIColor { get }
  var headerForegroundColor: UIColor { get }
  var preferredStatusBarStyle: UIStatusBarStyle { get }
  var logoFileName: String? { get }
  var additionalBottomContentInset: CGFloat { get }
}
