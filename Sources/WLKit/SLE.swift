import CoreGraphics

public enum Direction {
  case row
  case column
}

public enum Alignment {
  case leading
  case center
  case trailing
}

private extension Alignment {
  func align(parent: CGFloat, item: CGFloat) -> CGFloat {
    switch self {
    case .leading: return 0
    case .trailing: return (parent - item)
    case .center: return (parent - item) / 2.0
    }
  }
}

public enum LayoutError: Error {
  case itemOutOfBounds
  case itemIncomplete
  case outOfSpace
}

private extension CGPoint {
  func appendingX(_ value: CGFloat) -> CGPoint {
    return CGPoint(x: x + value, y: y)
  }

  func appendingY(_ value: CGFloat) -> CGPoint {
    return CGPoint(x: x, y: y + value)
  }
}

private class Rect {
  internal private(set) var width: CGFloat?
  internal private(set) var height: CGFloat?
  private var x: CGFloat?
  private var y: CGFloat?

  func frame() throws -> CGRect {
    guard let originX = x, let originY = y, let width = width, let height = height else {
      throw LayoutError.itemIncomplete
    }
    return CGRect(x: originX, y: originY, width: width, height: height)
  }

  func set(origin: CGPoint) {
    x = origin.x
    y = origin.y

    assert(x != nil)
    assert(y != nil)
  }

  func set(size: CGSize) {
    width = size.width
    height = size.height

    assert(width != nil)
    assert(height != nil)
  }
}

public class Item {
  public static var flexible: Item {
    return Item(width: nil, height: nil)
  }

  public static func width(_ value: CGFloat) -> Item {
    return Item(width: value, height: nil)
  }

  public static func height(_ value: CGFloat) -> Item {
    return Item(width: nil, height: value)
  }

  public static func dynamic(_ direction: Direction, _ value: CGFloat) -> Item {
    switch direction {
    case .column: return .height(value)
    case .row: return .width(value)
    }
  }

  public static func size(_ value: CGSize) -> Item {
    return Item(width: value.width, height: value.height)
  }

  public func frame() throws -> CGRect {
    return try rect.frame()
  }

  internal let originalWidth: CGFloat?
  internal let originalHeight: CGFloat?
  private let rect = Rect()

  private init(width: CGFloat?, height: CGFloat?) {
    originalWidth = width
    originalHeight = height
  }
}

private extension Item {
  func value(in direction: Direction) -> CGFloat? {
    switch direction {
    case .row: return originalWidth
    case .column: return originalHeight
    }
  }

  func updateSize(value: CGFloat, in direction: Direction, parentSize: CGSize) {
    switch direction {
    case .row:
      rect.set(size: CGSize(width: originalWidth ?? value, height: originalHeight ?? parentSize.height))

    case .column:
      rect.set(size: CGSize(width: originalWidth ?? parentSize.width, height: originalHeight ?? value))
    }
  }

  func updateOrigin(itemOrigin: CGPoint, in direction: Direction, alignment: Alignment, parentFrame: CGRect) -> CGPoint {
    switch direction {
    case .row:
      rect.set(origin: CGPoint(x: itemOrigin.x, y: parentFrame.origin.y + alignment.align(parent: parentFrame.height, item: rect.height ?? 0)))
      return itemOrigin.appendingX(rect.width ?? 0)
    case .column:
      rect.set(origin: CGPoint(x: parentFrame.origin.x + alignment.align(parent: parentFrame.width, item: rect.width ?? 0), y: itemOrigin.y))
      return itemOrigin.appendingY(rect.height ?? 0)
    }
  }
}

public class Layout {

  private let parentFrame: CGRect
  private let direction: Direction
  private let alignment: Alignment
  private var items: [Item] = []

  // Usually the layout system calculates coordinates for UIKit like systems
  // Where left: -x right: +x top -y bottom: +y
  // But in certain situtions it might not be ideal
  // Example 1: coordinate systems with y increasing upwards, like mac or SpriteKit
  // Example 2: right-to-left languages
  // Then `isFlipped` can be set to `true`
  var isFlipped = false

  public init(parentFrame: CGRect, direction: Direction, alignment: Alignment) {
    self.parentFrame = parentFrame
    self.direction = direction
    self.alignment = alignment
  }

  var totalItems: Int {
    return items.count
  }

  @discardableResult
  public func add(items: [Item]) throws -> [Item] {
    if isFlipped {
      self.items.append(contentsOf: items.reversed())
    } else {
      self.items.append(contentsOf: items)
    }
    try updateFrames()
    return items
  }

  @discardableResult
  public func add(item: Item) throws -> Item {
    if isFlipped {
      items.insert(item, at: 0)
    } else {
      items.append(item)
    }
    try updateFrames()
    return item
  }

  public func frame(at index: Int) throws -> CGRect {
    guard index < totalItems else {
      throw LayoutError.itemOutOfBounds
    }
    return try items[index].frame()
  }
}

private extension Layout {
  func updateFrames() throws {
    var totalFlexSpace: CGFloat = {
      switch direction {
      case .row: return parentFrame.width
      case .column: return parentFrame.height
      }
    }()

    var flexItems = 0
    for item in items {
      switch item.value(in: direction) {
      case .some(let space): totalFlexSpace -= space
      case .none: flexItems += 1
      }
    }

    let itemSpace = totalFlexSpace/CGFloat(max(flexItems, 1))
    guard itemSpace >= 0 else {
      throw LayoutError.outOfSpace
    }

    var itemOrigin = parentFrame.origin
    for item in items {
      item.updateSize(value: itemSpace, in: direction, parentSize: parentFrame.size)
      itemOrigin = item.updateOrigin(itemOrigin: itemOrigin, in: direction, alignment: alignment, parentFrame: parentFrame)
    }
  }
}
