//
//  CarouselView.swift
//  carousel_view
//
//  Created by Isis Anchalee on 3/26/16.
//  Copyright © 2016 Isis Anchalee. All rights reserved.
//

import UIKit

class CarouselView: UIView {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsZero
        let view =  UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.pagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    let pageControl: UIPageControl = {
        let view = UIPageControl()
        return view
    }()
    
    var views: Array<UIView> = [] {
        didSet {
            updatePages()
        }
    }
    
    var currentPage: Int {
        get {
            guard collectionView.frame.width > 0 else {
                return 0
            }
            let offset = collectionView.contentOffset.x / collectionView.frame.width
            return Int(floor(offset))
        }
    }
    
    private func updatePages() {
        collectionView.reloadData()
        pageControl.numberOfPages = views.count
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(collectionView)
        let views = ["colView" : collectionView]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[colView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[colView]|", options: [], metrics: nil, views: views))
        
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: 10).active = true
        pageControl.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(CarouselCell.self, forCellWithReuseIdentifier: CarouselView.cellId)
    }
}

extension CarouselView: UICollectionViewDataSource {
    @nonobjc static let cellId = "cell"
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return views.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CarouselView.cellId, forIndexPath: indexPath) as! CarouselCell
        cell.containedView = views[indexPath.row]
        return cell
    }
}

extension CarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
}

private class CarouselCell: UICollectionViewCell {
    var containedView: UIView? {
        willSet {
            if let oldView = containedView {
                oldView.removeConstraints(oldView.constraints)
                oldView.removeFromSuperview()
            }
        }
        didSet {
            if let newView = containedView {
                addSubview(newView)
                let views = ["view" : newView]
                newView.translatesAutoresizingMaskIntoConstraints = false
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: views))
                addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views))
            }
        }
    }
}