//
//  CHTCollectionViewWaterfallLayout.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol CHTCollectionViewDelegateWaterfallLayout: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForHeaderInSection section: NSInteger) -> CGFloat
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForFooterInSection section: NSInteger) -> CGFloat
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat
}

enum CHTCollectionViewWaterfallLayoutItemRenderDirection : NSInteger{
    case chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
    case chtCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight
    case chtCollectionViewWaterfallLayoutItemRenderDirectionRightToLeft
}

class CHTCollectionViewWaterfallLayout : UICollectionViewLayout{
    let CHTCollectionElementKindSectionHeader = "CHTCollectionElementKindSectionHeader"
    let CHTCollectionElementKindSectionFooter = "CHTCollectionElementKindSectionFooter"
    
    var columnCount : NSInteger{
        didSet{
            invalidateLayout()
        }}
    
    var minimumColumnSpacing : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var minimumInteritemSpacing : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var headerHeight : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var footerHeight : CGFloat{
        didSet{
            invalidateLayout()
        }}
    
    var sectionInset : UIEdgeInsets{
        didSet{
            invalidateLayout()
        }}
    
    
    var itemRenderDirection : CHTCollectionViewWaterfallLayoutItemRenderDirection{
        didSet{
            invalidateLayout()
        }}
    
    
    //    private property and method above.
    weak var delegate : CHTCollectionViewDelegateWaterfallLayout?{
        get{
            return self.collectionView!.delegate as? CHTCollectionViewDelegateWaterfallLayout
        }
    }
    var columnHeights = [CGFloat]()
    var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    var allItemAttributes = [UICollectionViewLayoutAttributes]()
    var headersAttributes : NSMutableDictionary
    var footersAttributes : NSMutableDictionary
    var unionRects : NSMutableArray
    let unionSize = 20
    
    override init(){
        self.headerHeight = 0.0
        self.footerHeight = 0.0
        self.columnCount = 2
        self.minimumInteritemSpacing = 10
        self.minimumColumnSpacing = 10
        self.sectionInset = UIEdgeInsets.zero
        self.itemRenderDirection =
            CHTCollectionViewWaterfallLayoutItemRenderDirection.chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
        
        headersAttributes = NSMutableDictionary()
        footersAttributes = NSMutableDictionary()
        unionRects = NSMutableArray()

        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.headerHeight = 0.0
        self.footerHeight = 0.0
        self.columnCount = 2
        self.minimumInteritemSpacing = 10
        self.minimumColumnSpacing = 10
        self.sectionInset = UIEdgeInsets.zero
        self.itemRenderDirection =
            CHTCollectionViewWaterfallLayoutItemRenderDirection.chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
        
        headersAttributes = NSMutableDictionary()
        footersAttributes = NSMutableDictionary()
        unionRects = NSMutableArray()

        super.init(coder: aDecoder)
    }
    
    func itemWidthInSectionAtIndex (_ section : NSInteger) -> CGFloat {
        let width:CGFloat = self.collectionView!.bounds.size.width - sectionInset.left-sectionInset.right
        let spaceColumCount:CGFloat = CGFloat(self.columnCount-1)
        return floor((width - (spaceColumCount*self.minimumColumnSpacing)) / CGFloat(self.columnCount))
    }
    
    override func prepare(){
        super.prepare()
        
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        self.headersAttributes.removeAllObjects()
        self.footersAttributes.removeAllObjects()
        self.unionRects.removeAllObjects()
        self.allItemAttributes.removeAll()
        self.sectionItemAttributes.removeAll()

        var top : CGFloat = 0.0
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0 ..< numberOfSections {
            /*
            * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
            */
            var minimumInteritemSpacing : CGFloat
            if let miniumSpaceing = self.delegate?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: section){
                minimumInteritemSpacing = miniumSpaceing
            }else{
                minimumInteritemSpacing = self.minimumColumnSpacing
            }
            
            let width = self.collectionView!.bounds.size.width - sectionInset.left - sectionInset.right
            let spaceColumCount = CGFloat(self.columnCount-1)
            let itemWidth = floor((width - (spaceColumCount*self.minimumColumnSpacing)) / CGFloat(self.columnCount))
            
            /*
            * 2. Section header
            */
            var heightHeader : CGFloat
            if let height = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForHeaderInSection: section){
                heightHeader = height
            }else{
                heightHeader = self.headerHeight
            }
            
            if heightHeader > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, with: IndexPath(row: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: self.collectionView!.bounds.size.width, height: heightHeader)
                self.headersAttributes.setObject(attributes, forKey: (section as NSCopying))
                self.allItemAttributes.append(attributes)
                
                top = attributes.frame.maxY
            }
            top += sectionInset.top

            self.columnHeights = [CGFloat](repeating: top, count: self.columnCount)
            
            /*
            * 3. Section items
            */
            let itemCount = self.collectionView!.numberOfItems(inSection: section)
            var itemAttributes = [UICollectionViewLayoutAttributes]()
            itemAttributes.reserveCapacity(itemCount)
            
            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                
                let columnIndex = self.nextColumnIndexForItem(idx)
                let xOffset = sectionInset.left + (itemWidth + self.minimumColumnSpacing) * CGFloat(columnIndex)
                let yOffset = self.columnHeights[columnIndex]
                let itemSize = self.delegate?.collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight : CGFloat = 0.0
                if itemSize?.height > 0 && itemSize?.width > 0 {
                    itemHeight = floor(itemSize!.height*itemWidth/itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: CGFloat(yOffset), width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                self.allItemAttributes.append(attributes)
                self.columnHeights[columnIndex]=attributes.frame.maxY + minimumInteritemSpacing;
            }
            self.sectionItemAttributes.append(itemAttributes)
            
            /*
            * 4. Section footer
            */
            var footerHeight : CGFloat = 0.0
            let columnIndex  = self.longestColumnIndex()
            top = self.columnHeights[columnIndex] - minimumInteritemSpacing + sectionInset.bottom
            
            if let height = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForFooterInSection: section){
                footerHeight = height
            }else{
                footerHeight = self.footerHeight
            }
            
            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: self.collectionView!.bounds.size.width, height: footerHeight)
                self.footersAttributes.setObject(attributes, forKey: section as NSCopying)
                self.allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            self.columnHeights = [CGFloat](repeating:top, count: self.columnCount)
        }
        var idx = 0;
        let itemCounts = self.allItemAttributes.count
        while(idx < itemCounts){
            let rect1 = self.allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = self.allItemAttributes[idx].frame
            self.unionRects.add(NSValue(cgRect:rect1.union(rect2)))
            idx += 1
        }
    }
    
    override var collectionViewContentSize : CGSize{
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0{
            return CGSize.zero
        }
        
        var contentSize = self.collectionView!.bounds.size as CGSize
        contentSize.height = self.columnHeights[0]
        return  contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= self.sectionItemAttributes.count{
            return nil
        }
        if indexPath.item >= self.sectionItemAttributes[indexPath.section].count {
            return nil;
        }
        let list = self.sectionItemAttributes[indexPath.section]
        return list[indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes{
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == CHTCollectionElementKindSectionHeader{
            attribute = self.headersAttributes.object(forKey: indexPath.section) as! UICollectionViewLayoutAttributes
        }else if elementKind == CHTCollectionElementKindSectionFooter{
            attribute = self.footersAttributes.object(forKey: indexPath.section) as! UICollectionViewLayoutAttributes
        }
        return attribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = self.unionRects.count
        let attrs = NSMutableArray()
        
        for i in 0 ..< end {
            if rect.intersects((self.unionRects.object(at: i) as AnyObject).cgRectValue){
                begin = i * unionSize;
                break
            }
        }
        for i in (0 ..< self.unionRects.count).reversed() {
            if rect.intersects((self.unionRects.object(at: i) as AnyObject).cgRectValue){
                end = min((i+1)*unionSize,self.allItemAttributes.count)
                break
            }
        }
        for i in begin ..< end {
            let attr = self.allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.add(attr)
            }
        }
        
        return NSArray(array: attrs) as? [UICollectionViewLayoutAttributes]
    }
    
    override func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if newBounds.width != oldBounds.width{
            return true
        }
        return false
    }
    
    
    /**
    *  Find the shortest column.
    *
    *  @return index for the shortest column
    */
    func shortestColumnIndex () -> NSInteger {
        var index = 0
        var shortestHeigth = CGFloat.greatestFiniteMagnitude

        for (idx, heigth) in self.columnHeights.enumerated() {
            if (heigth < shortestHeigth) {
                shortestHeigth = heigth
                index = idx
            }
        }
        return index
    }
    
    /**
    *  Find the longest column.
    *
    *  @return index for the longest column
    */
    
    func longestColumnIndex() -> NSInteger {
        var index = 0
        var longestHeigth:CGFloat = 0.0

        for (idx, heigth) in self.columnHeights.enumerated() {
            if (heigth > longestHeigth) {
                longestHeigth = heigth
                index = idx
            }
        }
        return index
    }
    
    /**
    *  Find the index for the next column.
    *
    *  @return index for the next column
    */
    func nextColumnIndexForItem (_ item : NSInteger) -> Int {
        var index = 0
        switch (self.itemRenderDirection){
        case .chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst :
            index = self.shortestColumnIndex()
        case .chtCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight :
            index = (item%self.columnCount)
        case .chtCollectionViewWaterfallLayoutItemRenderDirectionRightToLeft:
            index = (self.columnCount - 1) - (item % self.columnCount);
        }
        
        return index
    }
}
