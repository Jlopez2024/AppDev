//
//  ConfigViewController.swift
//  MatchEmTab
//
//  Created by Guest User on 10/21/24.
//

import Foundation
import AVFoundation
import UIKit


protocol ConfigSceneDelegate: AnyObject {
    func didUpdateTimeLimit(_ timeLimit: Int)
    func didUpdateSpeed(_ speed: Double)
    func didChangeColor(_ color: UIColor)
    func didResetScore()

}

class ConfigSceneViewController: UIViewController {

    @IBOutlet weak var timeLimitStepper: UIStepper!
    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var colorWell: UIColorWell!
    
    weak var delegate: ConfigSceneDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial label value
        timeLimitLabel.text = "Time Limit: \(Int(timeLimitStepper.value))s"
        speedLabel.text = "Speed: \(Double(speedSlider.value))"
        colorWell.addTarget(self, action: #selector(colorChanged), for: .valueChanged)

    }
    
    // Action for slider value change
    @IBAction func timeLimitStepperChanged(_ sender: UIStepper) {
        let timeLimit = Int(sender.value)
        timeLimitLabel.text = "Time Limit: \(timeLimit)s"  // Update label to show current time limit
        
        // Notify delegate of new time limit
        delegate?.didUpdateTimeLimit(timeLimit)
        print("didUpdateTimeLimit called with timeLimit: \(timeLimit)")

    }
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        let speed = Double(sender.value)
        speedLabel.text = "Speed: \(speed)s"  // Update label to show current time limit
        
        // Notify the delegate of the new time limit
        delegate?.didUpdateSpeed(speed)
        print("didUpdateSpeed called with speed: \(speed)")
    }
    
    var selectedColor: UIColor = .white // Default color
    
    @objc func colorChanged() {
        selectedColor = colorWell.selectedColor ?? .white // Fallback to black if nil
        view.backgroundColor = selectedColor
        
        delegate?.didChangeColor(selectedColor)
        print("Selected Color: \(selectedColor)")
        }
    
    
    @IBAction func scoreReset(_ sender: Any) {
        delegate?.didResetScore()
    }
    

}


