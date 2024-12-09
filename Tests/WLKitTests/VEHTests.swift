import XCTest
@testable import WLKit

private class RootView: WLView, ViewEventHandler {
  func handle(event: ViewEvent, sender: WLView?) {}
}

private class RootViewController: WLViewController, ViewEventHandler {
  func handle(event: ViewEvent, sender: WLView?) {}
}

final class VEHTests: XCTestCase {
  func testViewHierarchy() {
    let rootVw = RootView()
    let sonVw = View("Son")
    let daughterVw = View("Daughter")
    let grandsonVw = View("Grandson")
    let granddaughterVw = View("Granddaughter")
    let neighborVw = View("Neighbor")
    rootVw.addSubview(sonVw)
    rootVw.addSubview(daughterVw)
    sonVw.addSubview(grandsonVw)
    daughterVw.addSubview(granddaughterVw)
    
    XCTAssert(granddaughterVw.eventHandler === rootVw)
    XCTAssert(grandsonVw.eventHandler === rootVw)
    XCTAssert(daughterVw.eventHandler === rootVw)
    XCTAssert(sonVw.eventHandler === rootVw)
    XCTAssert(rootVw.eventHandler === rootVw)
    XCTAssert(neighborVw.eventHandler == nil)
  }
  
  func testViewControllerHierarchy() {
    let rootVwCtrl = RootViewController()
    let sonVw = View("Son")
    let daughterVw = View("Daughter")
    let grandsonVw = View("Grandson")
    let granddaughterVw = View("Granddaughter")
    let neighborVw = View("Neighbor")
    rootVwCtrl.view.addSubview(sonVw)
    rootVwCtrl.view.addSubview(daughterVw)
    sonVw.addSubview(grandsonVw)
    daughterVw.addSubview(granddaughterVw)
    
    XCTAssert(granddaughterVw.eventHandler === rootVwCtrl)
    XCTAssert(grandsonVw.eventHandler === rootVwCtrl)
    XCTAssert(daughterVw.eventHandler === rootVwCtrl)
    XCTAssert(sonVw.eventHandler === rootVwCtrl)
    XCTAssert(rootVwCtrl.eventHandler === rootVwCtrl)
    XCTAssert(neighborVw.eventHandler == nil)
  }
}
