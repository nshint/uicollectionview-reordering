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
    private var numbers: [Int] = []
    
    private var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...100 {
            let height = Int(arc4random_uniform((UInt32(100)))) + 40
            numbers.append(height)
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongGesture:")
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
        case UIGestureRecognizerState.Changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case UIGestureRecognizerState.Ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
}

extension ThirdViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: Int((view.bounds.width - 40)/3), height: numbers[indexPath.item])
    }
}

extension ThirdViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TextCollectionViewCell
        cell.textLabel.text = "\(numbers[indexPath.item])"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let temp = numbers.removeAtIndex(sourceIndexPath.item)
        numbers.insert(temp, atIndex: destinationIndexPath.item)
    }
    
}

//MARK: one little trick
extension CHTCollectionViewWaterfallLayout {
    
    internal override func invalidationContextForInteractivelyMovingItems(targetIndexPaths: [NSIndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [NSIndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContextForInteractivelyMovingItems(targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        
        self.delegate?.collectionView!(self.collectionView!, moveItemAtIndexPath: previousIndexPaths[0], toIndexPath: targetIndexPaths[0])
        
        return context
    }
}
