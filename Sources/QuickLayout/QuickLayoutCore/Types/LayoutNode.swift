/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import UIKit

public struct GridInfo: Sendable {
  public let alignment: Alignment?
  public let unitPoint: UnitPoint?
  public let columnAlignment: HorizontalAlignment?
}

public struct LayoutNode: Sendable {

  public static let empty = LayoutNode(view: nil, dimensions: ElementDimensions(.zero))

  public let view: UIView?
  public let dimensions: ElementDimensions
  public let gridInfo: GridInfo?
  public let children: [Child]

  public init(view: UIView?, dimensions: ElementDimensions, gridInfo: GridInfo? = nil) {
    self.view = view
    self.dimensions = dimensions
    self.gridInfo = gridInfo
    self.children = []
  }

  public init(view: UIView?, size: CGSize, children: [Child], alignmentGuides: AlignmentGuides) {
    self.view = view
    self.children = children
    self.gridInfo = nil
    self.dimensions = ElementDimensions(size, alignmentGuides: alignmentGuides)
  }
  init(view: UIView?, dimensions: ElementDimensions, gridInfo: GridInfo?, children: [Child]) {
    self.view = view
    self.dimensions = dimensions
    self.gridInfo = gridInfo
    self.children = children
  }

  public var size: CGSize {
    return CGSize(width: dimensions.width, height: dimensions.height)
  }

  public struct Child: Sendable {

    public let position: CGPoint
    public let layout: LayoutNode

    public init(position: CGPoint, layout: LayoutNode) {
      self.position = position
      self.layout = layout
    }
  }
}
