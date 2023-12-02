//
//  GridMenuViewController.swift
//  Ignited
//
//  Created by Riley Testut on 12/21/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import UIKit
import Roxas

class GridMenuViewController: UICollectionViewController, UIGestureRecognizerDelegate
{
    var items: [MenuItem] {
        get { return self.dataSource.items }
        set { self.dataSource.items = newValue; self.updateItems() }
    }
    
    var isVibrancyEnabled = true
    
    override var preferredContentSize: CGSize {
        set { }
        get { return self.collectionView?.contentSize ?? CGSize.zero }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.collectionView.reloadData()
    }
    
    private let dataSource = RSTArrayCollectionViewDataSource<MenuItem>(items: [])
    
    private var prototypeCell = GridCollectionViewCell()
    private var previousIndexPath: IndexPath? = nil
    
    private var registeredKVOObservers = Set<NSKeyValueObservation>()
    
    init()
    {
        let collectionViewLayout = GridCollectionViewLayout()
        collectionViewLayout.itemSize = CGSize(width: 60, height: 80)
        collectionViewLayout.minimumLineSpacing = 20
        collectionViewLayout.minimumInteritemSpacing = 10
        
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        // Crashes on iOS 10 if not explicitly invalidated.
        self.registeredKVOObservers.forEach { $0.invalidate() }
    }
}

extension GridMenuViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.collectionView?.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: RSTCellContentGenericCellIdentifier)
        
        self.dataSource.cellConfigurationHandler = { [unowned self] (cell, item, indexPath) in
            self.configure(cell as! GridCollectionViewCell, for: indexPath)
        }
        self.collectionView?.dataSource = self.dataSource
                
        let collectionViewLayout = self.collectionViewLayout as! GridCollectionViewLayout
        collectionViewLayout.itemWidth = 80
        collectionViewLayout.usesEqualHorizontalSpacingDistributionForSingleRow = true
        
        // Manually update prototype cell properties
        self.prototypeCell.contentView.widthAnchor.constraint(equalToConstant: collectionViewLayout.itemWidth).isActive = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer:)))
        longPressGesture.delegate = self
        longPressGesture.delaysTouchesBegan = true
        
        self.collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if let indexPath = self.previousIndexPath
        {
            UIView.animate(withDuration: 0.2) {
                let item = self.items[indexPath.item]
                item.isSelected = !item.isSelected
            }
        }
    }
}

private extension GridMenuViewController
{
    func configure(_ cell: GridCollectionViewCell, for indexPath: IndexPath)
    {
        let pauseItem = self.items[indexPath.item]
        
        cell.maximumImageSize = CGSize(width: 60, height: 60)
        
        cell.imageView.image = pauseItem.image
        cell.imageView.contentMode = .center
        cell.imageView.layer.cornerRadius = 10
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.borderColor = UIColor.themeColor.cgColor
        cell.imageView.tintColor = UIColor.themeColor
        cell.imageView.backgroundColor = UIColor.clear
        
        cell.textLabel.text = pauseItem.text
        cell.textLabel.textColor = self.view.tintColor
        
        if pauseItem.isSelected
        {
            cell.isImageViewVibrancyEnabled = false
        }
        else
        {
            cell.isImageViewVibrancyEnabled = true
        }
        
        cell.isTextLabelVibrancyEnabled = true
    }
    
    func updateItems()
    {
        self.registeredKVOObservers.removeAll()
        
        for (index, item) in self.items.enumerated()
        {
            let observer = item.observe(\.isSelected, changeHandler: { [unowned self] (item, change) in
                let indexPath = IndexPath(item: index, section: 0)
                
                if let cell = self.collectionView?.cellForItem(at: indexPath) as? GridCollectionViewCell
                {
                    self.configure(cell, for: indexPath)
                }
            })
            
            self.registeredKVOObservers.insert(observer)
        }
    }
}

extension GridMenuViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        self.configure(self.prototypeCell, for: indexPath)
        
        let size = self.prototypeCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size
    }
}

extension GridMenuViewController
{
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        let item = self.items[indexPath.item]
        item.isSelected = !item.isSelected
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
    {
        let item = self.items[indexPath.item]
        item.isSelected = !item.isSelected
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.previousIndexPath = indexPath
        
        let item = self.items[indexPath.item]
        item.isSelected = !item.isSelected
        item.action(item)
    }
}

extension GridMenuViewController
{
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
    {
        guard let item = self.items[indexPath.item] as? MenuItem,
              let menu = item.menu else { return nil }
        
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            return menu
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    {
        guard let indexPath = configuration.identifier as? NSIndexPath,
              let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? GridCollectionViewCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let preview = UITargetedPreview(view: cell.contentView, parameters: parameters)
        return preview
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer)
    {
        guard gestureRecognizer.state == .began else { return }

        let pressedItem = gestureRecognizer.location(in: collectionView)

        guard let indexPath = collectionView?.indexPathForItem(at: pressedItem),
              let item = self.items[indexPath.item] as? MenuItem else { return }
        
        self.previousIndexPath = indexPath
        
        if let holdAction = item.holdAction {
            holdAction(item)
        } else {
            item.isSelected = !item.isSelected
            item.action(item)
        }
    }
}

