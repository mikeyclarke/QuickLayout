/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import UIKit

public struct FlowElement: Layout {

  private let children: [Element]
  private let itemSpacing: CGFloat
  private let lineSpacing: CGFloat
  private let mainAxis: Axis
  private let itemAlignmentID: AnyAlignmentID
  private let lineAlignmentID: AnyAlignmentID

  public init(children: [Element], mainAxis: Axis, itemSpacing: CGFloat, lineSpacing: CGFloat, itemAlignmentID: AnyAlignmentID, lineAlignmentID: AnyAlignmentID) {
    self.itemSpacing = sanitizeSpacing(itemSpacing)
    self.lineSpacing = sanitizeSpacing(lineSpacing)
    self.children = children.filter { !$0.quickInternal_isSpacer() }
    self.mainAxis = mainAxis
    self.itemAlignmentID = itemAlignmentID
    self.lineAlignmentID = lineAlignmentID
  }

  public func quick_layoutThatFits(_ proposedSize: CGSize) -> LayoutNode {
    LayoutContext.$latestMainAxis.withValue(mainAxis) {
      computeFlowLayout(
        proposedSize: proposedSize,
        children: children,
        itemSpacing: itemSpacing,
        lineSpacing: lineSpacing,
        mainAxis: mainAxis,
        itemAlignment: itemAlignmentID,
        lineAlignment: lineAlignmentID
      )
    }
  }

  public func quick_flexibility(for axis: Axis) -> Flexibility {
    if children.isEmpty {
      return .fixedSize
    }

    var result = Flexibility.fixedSize
    LayoutContext.$latestMainAxis.withValue(mainAxis) {
      for child in children {
        let flexibility = child.quick_flexibility(for: axis)
        if flexibility.rawValue > result.rawValue {
          result = flexibility
        }
        if result == .fullyFlexible {
          break
        }
      }
    }

    return result
  }

  public func quick_layoutPriority() -> CGFloat {
    0
  }

  public func quick_extractViewsIntoArray(_ views: inout [UIView]) {
    children.forEach { child in
      child.quick_extractViewsIntoArray(&views)
    }
  }
}

private func sanitizeSpacing(_ spacing: CGFloat) -> CGFloat {
  spacing.isFinite ? spacing : 0
}
