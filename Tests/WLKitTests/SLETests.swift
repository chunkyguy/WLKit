import XCTest
@testable import WLKit

final class SLETests: XCTestCase {

  func testOneItem() {
    let layout = Layout(parentFrame: CGRect(origin: .zero, size: CGSize(width: 414, height: 896)), direction: .column, alignment: .leading)
    do {
      try layout.add(item: .flexible)
      XCTAssertEqual(try layout.frame(at: 0), CGRect(origin: .zero, size: CGSize(width: 414, height: 896)))
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testTwoRowLayout() {
    let layout = Layout(parentFrame: CGRect(origin: .zero, size: CGSize(width: 414, height: 896)), direction: .column, alignment: .leading)
    do {
      try layout.add(item: .flexible)
      try layout.add(item: .height(200))
      XCTAssertEqual(try layout.frame(at: 0), CGRect(origin: .zero, size: CGSize(width: 414, height: 696)))
      XCTAssertEqual(try layout.frame(at: 1), CGRect(origin: CGPoint(x: 0, y: 696), size: CGSize(width: 414, height: 200)))
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testComplexLayout() {
    let mainLayout = Layout(parentFrame: CGRect(origin: .zero, size: CGSize(width: 414, height: 896)), direction: .column, alignment: .leading)
    do {
      try mainLayout.add(item: .flexible)
      try mainLayout.add(item: .height(44))
      try mainLayout.add(item: .height(200))

      let previewFrame = try mainLayout.frame(at: 0)
      XCTAssertEqual(previewFrame, CGRect(x: 0, y: 0, width: 414, height: 652))

      let toolbarFrame = try mainLayout.frame(at: 1)
      XCTAssertEqual(toolbarFrame, CGRect(x: 0, y: 652, width: 414, height: 44))

      let imageFrame = try mainLayout.frame(at: 2)
      XCTAssertEqual(imageFrame, CGRect(x: 0, y: 696, width: 414, height: 200))

      let imageLayout = Layout(parentFrame: CGRect(origin: .zero, size: imageFrame.size), direction: .row, alignment: .leading)
      try imageLayout.add(item: .flexible)
      try imageLayout.add(item: .width(200))
      try imageLayout.add(item: .flexible)
      try imageLayout.add(item: .width(200))
      try imageLayout.add(item: .flexible)

      let thumbFrameLeft = try imageLayout.frame(at: 1)
      XCTAssertEqual(thumbFrameLeft.origin.x, 4.6, accuracy: 0.1)
      XCTAssertEqual(thumbFrameLeft.origin.y, 0, accuracy: 0.1)
      XCTAssertEqual(thumbFrameLeft.size.width, 200, accuracy: 0.1)
      XCTAssertEqual(thumbFrameLeft.size.height, 200, accuracy: 0.1)

      let thumbFrameRight = try imageLayout.frame(at: 3)
      XCTAssertEqual(thumbFrameRight.origin.x, 209.3, accuracy: 0.1)
      XCTAssertEqual(thumbFrameRight.origin.y, 0, accuracy: 0.1)
      XCTAssertEqual(thumbFrameRight.size.width, 200, accuracy: 0.1)
      XCTAssertEqual(thumbFrameRight.size.height, 200, accuracy: 0.1)

    } catch let error {
      XCTFail("\(error)")
    }
  }

  static var allTests = [
    ("testOneItem", testOneItem),
    ("testTwoRowLayout", testTwoRowLayout),
    ("testComplexLayout", testComplexLayout),
  ]
}
