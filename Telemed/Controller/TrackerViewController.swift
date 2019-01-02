//
//  TrackerViewController.swift
//  Telemed
//
//  Created by Macbook on 12/26/18.
//  Copyright © 2018 drsocgr14. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift
import SCLAlertView

class TrackerViewController: UIViewController {
    
    @IBOutlet weak var trackerCollectionView: UICollectionView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate let rows: CGFloat = 3
    
    let realm = try! Realm()
    
    var trackers : Results<Trackers>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadCategories()
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        trackerCollectionView.register(UINib(nibName: "TrackerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "trackerCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TrackerInfoViewController
        
        if let indexPath = trackerCollectionView.indexPathsForSelectedItems {
            

            destinationVC.titleText = trackers?[indexPath[0].row].name ?? "No tracker"
            destinationVC.infoFieldText = trackers?[indexPath[0].row].name ?? "No tracker"
            
            destinationVC.selectedTracker = trackers?[indexPath[0].row]
        }
    }
    
    func loadCategories() {
        
        trackers = realm.objects(Trackers.self)
    }
}

extension TrackerViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (trackers != nil) {
            
            performSegue(withIdentifier: "goToTrackerInfo", sender: self)
        }
        else {
            
            SCLAlertView().showError("No trackers", subTitle: "Please add trackers first")
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as! TrackerCollectionViewCell

        if let name = trackers?[indexPath.row].name {
            
            print(name)
            let string = String(name.map { $0 == " " ? "\n" : $0 })
            cell.title.text =  string
            
        }
        else {
            
            cell.title.text = "No\ntrackers"
            
        }
        
        
        cell.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.leftToRight, withFrame: cell.layer.frame, andColors: [UIColor.flatSkyBlue(), UIColor.flatSkyBlueColorDark(), UIColor.flatBlue()])
        cell.layer.cornerRadius = 10
        
        return cell
        
    }
    
}

extension TrackerViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let horizontalPaddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = trackerCollectionView.frame.width - horizontalPaddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        let verticalPaddingSpace = sectionInsets.top * (rows + 1)
        let availableHeight = trackerCollectionView.frame.height - verticalPaddingSpace
        let heightPerItem = availableHeight / rows
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
