//
//  ViewController.swift
//  Example
//
//  Created by Wojtek on 14/07/2015.
//  Copyright © 2015 NSHint. All rights reserved.
//

import UIKit

enum Example: String {
    case CollectionViewController
    case CollectionView
    case CollectionViewWithCustomLayout
    
    func segueIdentifier() -> String {
        switch(self) {
        case .CollectionViewController:
            return "FirstSegueIdentifier"
        case .CollectionView:
            return "SecondSegueIdentifier"
        case .CollectionViewWithCustomLayout:
            return "ThirdSegueIdentifier"
        }
    }
    
}

class MainViewController: UIViewController {
    var examples: [Example] = [.CollectionViewController, .CollectionView, .CollectionViewWithCustomLayout]
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = examples[indexPath.item].rawValue
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(examples[indexPath.item].segueIdentifier(), sender: self)
    }
}
