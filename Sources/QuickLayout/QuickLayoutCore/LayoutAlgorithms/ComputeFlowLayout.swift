/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

private func layoutLine(children: [LayoutNode], itemSpacing: CGFloat, mainAxis: Axis, itemAlignment: AnyAlignmentID, reverseItems: Bool) -> LayoutNode {
  let childrenCount = children.count
  var maxAlignmentGuideLength: CGFloat = 0
  for layout in children {
    maxAlignmentGuideLength = max(maxAlignmentGuideLength, itemAlignment.defaultValue(in: layout.dimensions))
  }
  // Calculate positions with alignment
  var offset: CGFloat = 0
  let range = reverseItems ? stride(from: childrenCount - 1, through: 0, by: -1) : stride(from: 0, through: childrenCount - 1, by: 1)
  var positionedChildren = range.map { index in
    let layout = children[index]
    let alignmentGuideLength = itemAlignment.defaultValue(in: layout.dimensions)
    let crossAxisOffset = maxAlignmentGuideLength - alignmentGuideLength
    let position = CGPoint(main: offset, cross: crossAxisOffset, mainAxis: mainAxis)
    offset += layout.size.main(for: mainAxis) + itemSpacing
    return LayoutNode.Child(position: roundToPixelGrid(position), layout: layout)
  }
  // Makes final frame by taking union of calculated positions
  var resultFrame: CGRect = .zero
  positionedChildren.forEach { child in
    let frame = CGRect(origin: child.position, size: child.layout.size)
    resultFrame = resultFrame.union(frame)
  }
  if reverseItems {
    positionedChildren.reverse()
  }
  let lineSize = CGSize(width: roundSizeToPixelGrid(resultFrame.width), height: roundSizeToPixelGrid(resultFrame.height))
  return LayoutNode(view: nil, size: lineSize, children: positionedChildren, alignmentGuides: AlignmentGuidesResolver.extract(for: positionedChildren))
}
private func splitNodesIntoLines(main: CGFloat, children: [LayoutNode], itemSpacing: CGFloat, mainAxis: Axis) -> [[LayoutNode]] {
  var lines: [[LayoutNode]] = []
  var currentLine: [LayoutNode] = []
  let fitTolerance: CGFloat = 0.001
  let maxMainSize = main
  var totalMainSize: CGFloat = 0
  for child in children {
    let childMainSize = child.size.main(for: mainAxis)
    let remainingMain = maxMainSize - totalMainSize + fitTolerance
    if currentLine.isEmpty || remainingMain >= childMainSize {
      // Add child to current line
      currentLine.append(child)
      totalMainSize += childMainSize + itemSpacing
    } else {
      // Start a new line
      lines.append(currentLine)
      currentLine = [child]
      totalMainSize = childMainSize + itemSpacing
    }
  }
  // Appends final line
  lines.append(currentLine)
  return lines
}
func computeFlowLayout(proposedSize: CGSize, children: [Element], itemSpacing: CGFloat, lineSpacing: CGFloat, mainAxis: Axis, itemAlignment: AnyAlignmentID, lineAlignment: AnyAlignmentID) -> LayoutNode {
  let isRTL = LayoutContext.layoutDirection == .rightToLeft
  let reverseItems = isRTL && mainAxis == .horizontal
  let reverseLines = isRTL && mainAxis == .vertical
  if children.isEmpty {
    return LayoutNode.empty
  }
  if children.count == 1 {
    let childLayout = children[0].quick_layoutThatFits(proposedSize)
    let childNode = LayoutNode.Child(position: .zero, layout: childLayout)
    return LayoutNode(view: nil, size: childLayout.size, children: [childNode], alignmentGuides: AlignmentGuidesResolver.extract(childNode))
  }
  let childrenLayout = children.map { child in
    return child.quick_layoutThatFits(proposedSize)
  }
  let main = proposedSize.main(for: mainAxis)
  let lines = splitNodesIntoLines(main: main, children: childrenLayout, itemSpacing: itemSpacing, mainAxis: mainAxis)
  let lineNodes = lines.map { line in
    layoutLine(children: line, itemSpacing: itemSpacing, mainAxis: mainAxis, itemAlignment: itemAlignment, reverseItems: reverseItems)
  }
  // Calculate max alignment for lines
  var maxAlignmentGuideLength: CGFloat = 0
  for layout in lineNodes {
    maxAlignmentGuideLength = max(maxAlignmentGuideLength, lineAlignment.defaultValue(in: layout.dimensions))
  }
  // Calculate positions with alignment
  var lineOffset: CGFloat = 0
  let linesCount = lineNodes.count
  let range = reverseLines ? stride(from: linesCount - 1, through: 0, by: -1) : stride(from: 0, through: linesCount - 1, by: 1)
  var positionedLines = range.map { index in
    let layout = lineNodes[index]
    let alignmentGuideLength = lineAlignment.defaultValue(in: layout.dimensions)
    let mainAxisOffset = maxAlignmentGuideLength - alignmentGuideLength
    let position = CGPoint(main: mainAxisOffset, cross: lineOffset, mainAxis: mainAxis)
    lineOffset += layout.size.cross(for: mainAxis) + lineSpacing
    return LayoutNode.Child(position: roundToPixelGrid(position), layout: layout)
  }
  if reverseLines {
    positionedLines.reverse()
  }
  // Finding container size
  var resultFrame: CGRect = .zero
  positionedLines.forEach { child in
    let frame = CGRect(origin: child.position, size: child.layout.size)
    resultFrame = resultFrame.union(frame)
  }
  // Returns the layout
  let finalLayout = LayoutNode(view: nil, size: resultFrame.size, children: positionedLines, alignmentGuides: AlignmentGuidesResolver.extract(for: positionedLines))
  return finalLayout
}
