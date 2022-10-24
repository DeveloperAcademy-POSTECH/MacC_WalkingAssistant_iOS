//
//  MainViewController.swift
//  Oculo
//
//  Created by Kim, Raymond on 2022/10/07.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .dark

        self.view.addSubview(self.controlSwitch)
        self.view.addSubview(self.label)

        self.view.addSubview(self.createNavigateButton)
        self.view.addSubview(self.createEnvironmentReaderButton)
        self.view.addSubview(self.createTextReadingButton)
    }

    lazy var createNavigateButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(
            x: 0,
            y: self.view.frame.height * 0.1,
            width: self.view.frame.width,
            height: self.view.frame.height * 0.25
        )
        button.backgroundColor = UIColor.clear
        button.setTitle("Navigation", for: .normal)
        button.layer.cornerRadius = 10.0
        button.tag = 1
        button.addTarget(self, action: #selector(onTouchButton), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.red.cgColor

        self.view.addSubview(button)

        return button
    }()

    lazy var createEnvironmentReaderButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(
            x: 0,
            y: self.view.frame.height * 0.35 + 20,
            width: self.view.frame.width,
            height: self.view.frame.height * 0.25
        )
        button.backgroundColor = UIColor.clear
        button.setTitle("Environment Reader", for: .normal)
        button.layer.cornerRadius = 10.0
        button.tag = 2
        button.addTarget(self, action: #selector(onTouchButton), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.yellow.cgColor

        self.view.addSubview(button)

        return button
    }()

    lazy var createTextReadingButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(
            x: 0,
            y: self.view.frame.height * 0.6 + 40,
            width: self.view.frame.width,
            height: self.view.frame.height * 0.25
        )
        button.backgroundColor = UIColor.clear
        button.setTitle("Text Reader", for: .normal)
        button.layer.cornerRadius = 10.0
        button.tag = 3
        button.addTarget(self, action: #selector(onTouchButton), for: .touchUpInside)
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.blue.cgColor

        self.view.addSubview(button)

        return button
    }()

    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height/17
        ))
        label.backgroundColor = UIColor.black
        label.layer.masksToBounds = true
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.layer.position = CGPoint(
            x: self.view.bounds.width/2,
            y: self.view.bounds.height/14
        )
        label.text = "Button UI"

        return label
    }()

    lazy var controlSwitch: UISwitch = {
        // Create a Switch.
        let swicth: UISwitch = UISwitch()
        swicth.layer.position = CGPoint(
            x: self.view.frame.width/2,
            y: self.view.frame.height/1.07
        )

        // Display the border of Swicth.
        swicth.tintColor = UIColor.orange

        // Set Switch to On.
        swicth.isOn = false

        // Set the event to be called when switching On / Off of Switch.
        swicth.addTarget(self,
                         action: #selector(onClickSwitch(sender:)),
                         for: UIControl.Event.valueChanged)

        return swicth
    }()

    @objc func onClickSwitch(sender: UISwitch) {
        var text: String!

        if sender.isOn {
            text = "Swipe UI"
            createNavigateButton.removeFromSuperview()
            createTextReadingButton.removeFromSuperview()
            createEnvironmentReaderButton.removeFromSuperview()
        } else {
            text = "Button UI"
            self.view.addSubview(self.createNavigateButton)
            self.view.addSubview(self.createTextReadingButton)
            self.view.addSubview(self.createEnvironmentReaderButton)
        }

        self.label.text = text
    }
    
    @objc func onTouchButton(_ sender: UIButton) {
        self.selected = sender.tag
        if(selected == 1) {
            self.createNavigateButton.backgroundColor = .red
            self.createEnvironmentReaderButton.backgroundColor = .clear
            self.createTextReadingButton.backgroundColor = .clear
        } else if (self.selected == 2) {
            self.createNavigateButton.backgroundColor = .clear
            self.createEnvironmentReaderButton.backgroundColor = .yellow
            self.createTextReadingButton.backgroundColor = .clear
        } else if (self.selected == 3) {
            self.createNavigateButton.backgroundColor = .clear
            self.createEnvironmentReaderButton.backgroundColor = .clear
            self.createTextReadingButton.backgroundColor = .blue
        }
    }
}

