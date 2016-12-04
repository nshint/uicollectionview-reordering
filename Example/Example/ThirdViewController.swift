//
//  ThirdViewController.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var numbers: [Int] = []
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...100 {
            let height = Int(arc4random_uniform((UInt32(100)))) + 40
            numbers.append(height)
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ThirdViewController.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
}

extension ThirdViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((view.bounds.width - 40)/3), height: numbers[indexPath.item])
    }
}

extension ThirdViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TextCollectionViewCell
        cell.textLabel.text = "\(numbers[indexPath.item])"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = numbers.remove(at: sourceIndexPath.item)
        numbers.insert(temp, at: destinationIndexPath.item)
    }
    
}

//MARK: one little trick
extension CHTCollectionViewWaterfallLayout {
    
    internal override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        
        self.delegate?.collectionView!(self.collectionView!, moveItemAt: previousIndexPaths[0], to: targetIndexPaths[0])
        
        return context
    }
}
