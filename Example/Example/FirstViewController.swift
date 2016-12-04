//
//  FirstViewController.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit


class FirstViewController: UICollectionViewController {

    var numbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0...100 {
            numbers.append(i)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TextCollectionViewCell
        cell.textLabel.text = "\(numbers[indexPath.item])"
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = numbers.remove(at: sourceIndexPath.item)
        numbers.insert(temp, at: destinationIndexPath.item)
    }
}

