//
//  HowItWorkViewC.swift
//  Frinck
//
//  Created by Meenkashi on 9/5/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class HowItWorkViewC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    var arr = [[String : String]]()
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arr = [["viewHead" : "Pop in to a Store", "viewDesc" : "Just check-in to any partner store and start earning Frincks right when you enter. So the deal is that you don't necessarily have to make a purchase to get Frincks. Just perform a few simple tasks and keep earning.", "image" :"howitwork"], ["viewHead" : "Play Around Taking Photos or Videos", "viewDesc" : "While you are in the store, you can also upload photos, videos or stories and share them with the Frinck's community. Yes, and that will fetch you more Frincks to add to your balance.","image" :"howitwork2"], ["viewHead" : "Try Out Online", "viewDesc" : "You can earn Frincks by simply visiting our partner online stores and browsing products. Well, that's not all you'll get more Frincks for watching a video or making a purchase!","image" :"howitwork3"]]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HowItWorkViewC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellWork", for: indexPath) as! CellHowItWorks
        cell.configureCell(dict: arr[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
    }
}
