//
//  ExploreTopHalfView.swift
//  Echo
//
//  Created by Andrew Yu on 3/16/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class ExploreTopHalfView: UICollectionReusableView, UICollectionViewDataSource, UICollectionViewDelegate  {

    @IBOutlet weak var teachersGridView: UICollectionView!

    //////////////////////////////////////////////////////////////////////////////
    override init(frame: CGRect) {
        super.init(frame: frame)
        teachersGridView.delegate = self
        teachersGridView.dataSource = self
        self.myCustomInit()
    }
    
    
    //////////////////////////////////////////////////////////////////////////////
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.myCustomInit()
    }
    
    func myCustomInit() {
        print("hello there from SupView")


        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = teachersGridView.dequeueReusableCellWithReuseIdentifier("TeacherCollectionViewCell", forIndexPath: indexPath) as! TeacherCollectionViewCell
        print(cell)
        return cell
    }
}
