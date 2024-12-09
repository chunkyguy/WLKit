#if os(iOS)
import UIKit

private let contentViewBindableTag = Int.max

/// Any view type that if provides a contentView get a view that fills the content
public protocol ContentViewBindable: AnyObject {
  var contentView: UIView { get }
}

extension ContentViewBindable {
  /// When set replaces the content
  public var inner: UIView? {
    get { contentView.viewWithTag(contentViewBindableTag) }
    
    set {
      if let oldView = contentView.viewWithTag(contentViewBindableTag) {
        oldView.removeFromSuperview()
      }
      
      if let newView = newValue {
        VFL(contentView)
          .add(subview: newView, name: "view")
          .applyConstraints(formats: ["H:|[view]|", "V:|[view]|"])
        newView.tag = contentViewBindableTag
      }
    }
  }
}

open class ContainerView: UIView, ContentViewBindable {
  public var contentView: UIView { self }
}
open class TableViewCell: UITableViewCell, ContentViewBindable {}
open class TableViewHeaderFooterView: UITableViewHeaderFooterView, ContentViewBindable {}
open class CollectionCell: UICollectionViewCell, ContentViewBindable {}
open class CollectionReusableView: UICollectionReusableView, ContentViewBindable {
  public var contentView: UIView { self }
}
#endif
