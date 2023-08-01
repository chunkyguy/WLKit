//
// Created by Sidharth Juyal on 10/04/2022.
// Copyright © 2022 whackylabs. All rights reserved.
// 

#if os(iOS)
import Foundation
import UIKit

open class SLEViewController: UIViewController {

  private var isSetup = false

  private var rootView: UIView? {
    didSet {
      oldValue?.removeFromSuperview()
      if let newValue = rootView {
        view.addSubview(newValue)
      }
    }
  }

  open override func viewDidLayoutSubviews() {
    // the view.safeAreaInsets is not available at viewDidLoad
    if !isSetup {
      layout(frame: view.bounds, update: addViews)
      isSetup = true
    }
    updateViews(frame: view.bounds)
  }

  private func layout(frame: CGRect, update: (CGRect) -> Void) {
    let direction = frame.size.direction
    let layout = Layout(parentFrame: frame, direction: direction, alignment: .leading)
    do {
      let leading: CGFloat
      let trailing: CGFloat
      switch direction {
      case .column:
        leading = view.safeAreaInsets.top
        trailing = view.safeAreaInsets.bottom
      case .row:
        leading = view.safeAreaInsets.left
        trailing = view.safeAreaInsets.right
      }
      let items = try layout.add(items: [.dynamic(direction, leading), .flexible, .dynamic(direction, trailing)])
      update(try items[1].frame())
    } catch let error {
      assertionFailure(error.localizedDescription)
    }
  }

  open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    layout(frame: CGRect(origin: .zero, size: size), update: updateViews)
  }

  // - Need to be subclassed -
  open func addViews(frame: CGRect) {}
  open func updateViews(frame: CGRect) {}
}

private extension CGSize {
  init(value: CGFloat) {
    self.init(width: value, height: value)
  }

  var minEdge: CGFloat {
    return min(width, height)
  }

  var direction: Direction {
    if width > height {
      return .row
    } else {
      return .column
    }
  }
}

#endif
