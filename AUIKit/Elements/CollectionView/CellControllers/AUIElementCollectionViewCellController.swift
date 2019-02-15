//
//  AUIElementCollectionViewCellController.swift
//  PocketDoc
//
//  Created by branderstudio on 11/14/18.
//  Copyright © 2018 BRANDER. All rights reserved.
//

import UIKit

open class AUIElementCollectionViewCellController: AUICollectionViewCellController {
  
  open weak var didSelectDelegate: AUICollectionViewCellControllerDelegate?
  
  open var view: UIView?
  
  public let controller: AUIViewController
  public let cellCreateBlock: (UICollectionView, IndexPath) -> UICollectionViewCell?
  
  // MARK: - Initializer
  
  public init(controller: AUIViewController,
       cellCreateBlock: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell?) {
    self.controller = controller
    self.cellCreateBlock = cellCreateBlock
  }
  
  // MARK: - Public
  
  open func cellForRowAtIndexPath(_ indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
    let cell = cellCreateBlock(collectionView, indexPath) ?? UICollectionViewCell()
    let containerCell = cell as? AUIViewContainer
    view = containerCell?.view
    if let view = view { controller.view = view }
    return cell
  }
  
  open func willDisplayCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
    if let view = view { controller.view = view }
  }
  
  open func didEndDisplayCell() {
    if view != nil { controller.view = nil }
  }
  
  
  open func didSelectCell() {
    didSelectDelegate?.didSelectCollectionViewCellController(self)
  }
  
}
