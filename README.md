# WLKit

Simple utilities for getting things done.

## SLE
Simple Layout Engine

A simplistic layout engine. Think what if `CGRectDivide()` went all the way.

### Usage:
```swift
let layout = Layout(parentFrame: frame, direction: .column)
try layout.add(item: .flexible)
try layout.add(item: .height(200))

let topFrame = try layout.frame(at: 0)
let bottomFrame = try layout.frame(at: 1)

addSubview(SLECreateView(topFrame, .red))
addSubview(SLECreateView(bottomFrame, .blue))
```

### Read More
- [Introducing Simple Layout Engine](https://whackylabs.com/swift/layout/2022/11/27/intro-simple-layout-engine/)

## VFL
Visual Formatting Language

Simple wrapper around Apple's ascii based constraints. But also stateful.

### Usage:
```swift
VFL(self)
  .add(subview: MyView(), name: "view")
  .appendConstraints(formats: ["H:|[view(320)]|", "V:|[view(480)]|"])
```

But unlike other wrappers, VFL is meant to be used as a supplement and not a replacement. So you can also add constraints created using system API.
Here's an example that creates a view of size 320x480 and aligns it to the center of parent

```swift
let view = VFLColorView()

VFL(self)
  .add(subview: view, name: "view")
  .appendConstraints(formats: [
    "H:[view(320)]", "V:[view(480)]",]
  )
  .appendConstraints([
    NSLayoutConstraint(
      item: view, attribute: .centerX,
      relatedBy: .equal,
      toItem: self, attribute: .centerX,
      multiplier: 1, constant: 0
    ),
    NSLayoutConstraint(
      item: view, attribute: .centerY,
      relatedBy: .equal,
      toItem: self, attribute: .centerY,
      multiplier: 1, constant: 0
    )
  ])
```

### Read More
1. [Introducing VFL](https://whackylabs.com/swift/uikit/layout/2023/07/01/introducing-vfl/)
1. [Autolayout and aligning subviews](https://whackylabs.com/swift/uikit/layout/vfl/2023/07/22/autolayout-align/)

## FLIC
Feedback Loop is Cool

Best way to build GUI apps!

### Usage
```swift
enum AsyncViewModel {
  case loading
  case success(UIView)
  case error(AppError)
}

class AsyncView: View<AsyncViewModel>, ContentViewBindable {
  var contentView: UIView { self }
  
  override func setUp() {
    super.setUp()
    backgroundColor = .white
  }
  
  override func viewModelDidUpdate() {
    super.viewModelDidUpdate()
    switch viewModel {
    case .loading:
      self.view = LoadingView(true)
    case .success(let view):
      self.view = view
    case .error(let error):
      self.view = ErrorView(error)      
    }
  }
}
```

### Read More
- [FLIC - The holy grail of all GUI architectures](https://whackylabs.com/swift/uikit/architecture/2023/08/03/flic-uikit/)
