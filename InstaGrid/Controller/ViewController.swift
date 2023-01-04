//
//  ViewController.swift
//  InstaGrid
//
//  Created by Maxime Girard on 28/12/2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var presetButtons: [UIButton]!
    @IBOutlet var buttonTouchedIndicator: [UIImageView]!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var gridView: GridView!
    
    
    @IBAction func didTapButton() {
        changeGridPreset()
    }
    
    private func changeGridPreset() {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        swipeGestureRecognizerUp.direction = .up
        
        gridView.addGestureRecognizer(swipeGestureRecognizerUp)
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        var frame = gridView.frame
        
        frame.origin.y -= 100.0
        
        UIView.animate(withDuration: 0.25) {
            self.gridView.frame = frame
        }
        
    }
}
