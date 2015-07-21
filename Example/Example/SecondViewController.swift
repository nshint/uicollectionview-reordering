//
//  SecondViewController.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var numbers: [Int] = []
    
    private var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...100 {
            numbers.append(i)
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

extension SecondViewController: UICollectionViewDataSource {
    
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
