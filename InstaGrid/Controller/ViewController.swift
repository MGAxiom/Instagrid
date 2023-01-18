//
//  ViewController.swift
//  InstaGrid
//
//  Created by Maxime Girard on 28/12/2022.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var presetButtons: [UIButton]!
    @IBOutlet weak var gridView: UIView!
    @IBOutlet var presetViews: [UIView]!
    @IBOutlet var gridButtons: [UIButton]!
    @IBOutlet weak var labelSwipe: UILabel!
    
    var swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    var isLandscape = false
    var isPortrait = false
    var currentGridButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeGesture.addTarget(self, action: #selector(swipePresetView(_:)))
        gridView.addGestureRecognizer(swipeGesture)
    
    }
    
    @IBAction func didTapPresetButton(_ sender: UIButton) {
        switch sender.tag {
        case 5:
            resetButtonStates()
            sender.isSelected = true
            changeGridPreset(sender)
        case 6:
            resetButtonStates()
            sender.isSelected = true
            changeGridPreset(sender)
        case 7:
            resetButtonStates()
            sender.isSelected = true
            changeGridPreset(sender)
        default:
            break
        }
    }
    
    private func resetButtonStates() {
        for sender in presetButtons {
            sender.isSelected = false
        }
    }
    
    private func changeGridPreset(_ sender: UIButton) {
        let presetOne = [view.viewWithTag(103), view.viewWithTag(104), view.viewWithTag(201)]
        let presetTwo = [view.viewWithTag(101), view.viewWithTag(102), view.viewWithTag(202)]
        let presetThree = [view.viewWithTag(101), view.viewWithTag(102), view.viewWithTag(103), view.viewWithTag(104)]
        if sender.tag == 5 {
            resetViews()
            presetOne.forEach { view in
                view?.isHidden = false
            }
        } else if sender.tag == 6 {
            resetViews()
            presetTwo.forEach { view in
                view?.isHidden = false
            }
        } else if sender.tag == 7 {
            resetViews()
            presetThree.forEach { view in
                view?.isHidden = false
            }
        }
    }
    
    func resetViews() {
        for view in presetViews {
            view.isHidden = true
        }
    }
    
    
    @IBAction func didTapGridButton(_ sender: UIButton) {
        currentGridButton = sender
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    //Checks orientation at start
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineMyDeviceOrientation()
        
        gridButtons.forEach { button in
            if button.state == .normal {
                button.imageView?.layer.transform = CATransform3DMakeScale(3.0, 3.0, 3.0)
            }
        }
    }
    
    
    
    func determineMyDeviceOrientation() {
        if UIDevice.current.orientation == .unknown {
            if let orientation = self.view.window?.windowScene?.interfaceOrientation {
                isLandscape = orientation.isLandscape
                isPortrait = orientation.isPortrait
            }
        } else {
            isPortrait = UIDevice.current.orientation.isPortrait
            isLandscape = UIDevice.current.orientation.isLandscape
        }
        
        
        if (isPortrait) {
            swipeGesture.direction = .up
            labelSwipe.text = "Swipe up to share"
        } else if (isLandscape) {
            swipeGesture.direction = .left
            labelSwipe.text = "Swipe left to share"
        }
    }
    
    //Checks orientation on rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        determineMyDeviceOrientation()
    }
    
    //Functions to swipe in the right direction and back when action is completed
    @objc private func swipePresetView(_ sender: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.4, delay: 0.2, animations: {
            var swipeTransform = CGAffineTransform(translationX: 0, y: -self.gridView.frame.maxY)
            if self.isLandscape {
                swipeTransform = CGAffineTransform(translationX: -self.gridView.frame.maxX, y: 0)
            }
            self.gridView.transform = swipeTransform
        }) { (success) in
            openActivityController()
        }

        
        
        func swipeBack() {
            UIView.animate(withDuration: 0.2, delay: 0,options: [.curveLinear], animations: {
                self.gridView.transform = .identity
            })
        }
        
        func openActivityController() {
            let grid = makeGridViewSnapshot()
            let gridToShare = [grid]
            let activityViewController = UIActivityViewController(activityItems: gridToShare as [Any], applicationActivities: nil)
            self.present(activityViewController, animated: true) {
            }
            activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
                                                                    Bool, arrayReturnedItems: [Any]?, error: Error?) in
                if let shareError = error {
                    print("error while sharing: \(shareError.localizedDescription)")
                    swipeBack()
                } else {
                    swipeBack()
                }
            }
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let button = currentGridButton else {
            return
        }
        
        let imagePicked = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as! UIImage
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(imagePicked, for: .selected)
        button.setImage(imagePicked, for: .normal)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        
        picker.dismiss(animated: true, completion: {
            button.isSelected = true
        })
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func makeGridViewSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.gridView.bounds.size, self.gridView.isOpaque, 0.0)
        self.gridView.drawHierarchy(in: self.gridView.bounds, afterScreenUpdates: false)
        let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImageFromMyView
        
    }
}

