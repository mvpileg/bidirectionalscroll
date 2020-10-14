//
//  ViewController.swift
//  BidirectionalScroll
//
//  Created by Matthew Pileggi on 9/23/20.
//  Copyright © 2020 Matthew Pileggi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var isPerformingUpdate = false

    private var min = 0 {
        didSet {
            displayNumbers = Array(min...max)
        }
    }
    private var max = 100 {
        didSet {
            displayNumbers = Array(min...max)
        }
    }
    
    private lazy var displayNumbers = Array(min...max)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.scrollToItem(at: IndexPath(row: max / 2, section: 0), at: .centeredVertically, animated: false)
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        //tests out heights of 10, 20, 30, 40 that are dictated by cell CONTENT
        let height = 10 * (abs(displayNumbers[indexPath.row]) % 4 + 1)
        
        return CGSize(width: width, height: CGFloat(height))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Will display cell: \(indexPath.row)")
        cell.contentView.backgroundColor = UIColor.clear
        
        if indexPath.row == displayNumbers.count - 1 {
            cell.contentView.backgroundColor = UIColor.blue
            let oldRowMax = displayNumbers.count - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.max += 3
                
                let items = [IndexPath(row: oldRowMax + 1, section: 0), IndexPath(row: oldRowMax + 2, section: 0), IndexPath(row: oldRowMax + 3, section: 0)]
                collectionView.insertItems(at: items)
            }
        }
        
        //is performing update avoids multiple collectionViewWillDisplay calls
        if indexPath.row == 0 && !isPerformingUpdate {
            cell.contentView.backgroundColor = UIColor.blue
            
            self.isPerformingUpdate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.min -= 3
                
                UIView.performWithoutAnimation {
                    let items = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)]
                    collectionView.insertItems(at: items)
                    collectionView.scrollToItem(at: IndexPath(row: 3, section: 0), at: .top, animated: false)
                    self.isPerformingUpdate = false
                }
            }
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayNumbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "test", for: indexPath) as? TestCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.row.text = "\(displayNumbers[indexPath.row])"
        return cell
    }
    
    
}
