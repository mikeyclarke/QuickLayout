/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

/**
 Specifies alignment behavior along an element's horizontal axis.
 Horizontal alignment can be created with a custom AlignmentID
 for full control over alignment behavior.
 */
public struct HorizontalAlignment: Sendable {
  public let alignmentID: AnyAlignmentID
  public init(_ alignmentID: AlignmentID.Type) {
    self.alignmentID = AnyAlignmentID(alignmentID, axis: .horizontal)
  }
}

/**
 Specifies alignment behavior along an element's vertical axis.
 Vertical alignment can be created with a custom AlignmentID
 for full control over alignment behavior.
 */
public struct VerticalAlignment: Sendable {
  public let alignmentID: AnyAlignmentID
  public init(_ alignmentID: AlignmentID.Type) {
    self.alignmentID = AnyAlignmentID(alignmentID, axis: .vertical)
  }
}

/**
 Specifies alignment behavior in both horizontal and vertical directions.
 Pass in any combination of horizontal and vertical alignment to achieve
 the desired 2D alignment.
 */
public struct Alignment: Sendable {
  public let horizontal: HorizontalAlignment
  public let vertical: VerticalAlignment

  public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
    self.horizontal = horizontal
    self.vertical = vertical
  }

  public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
  public static let top = Alignment(horizontal: .center, vertical: .top)
  public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
  public static let leading = Alignment(horizontal: .leading, vertical: .center)
  public static let center = Alignment(horizontal: .center, vertical: .center)
  public static let trailing = Alignment(horizontal: .trailing, vertical: .center)
  public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
  public static let bottom = Alignment(horizontal: .center, vertical: .bottom)
  public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}
