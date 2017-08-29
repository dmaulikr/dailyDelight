//
//  MainViewController.swift
//  dailyDelight
//
//  Created by Samuel Shearing on 20/8/17.
//  Copyright © 2017 MayonCreative. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

class MainViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    var expectedAge: Int = 80
    
    let bgImageView: UIImageView = {
        let image = UIImage(named: "background")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let tombstoneImageView: UIImageView = {
        let image = UIImage(named: "TombStone")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let dashedLineImageView: UIImageView = {
        let image = UIImage(named: "dashedLine")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let expectedAgeTextField: UITextField = {
        let textField = UITextField()
        textField.text = "80"
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.borderStyle = .none
        let font = UIFont.systemFont(ofSize: 24)
        textField.font = font
        textField.alpha = 0.3
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Age"
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.borderStyle = .none
        let font = UIFont.systemFont(ofSize: 36)
        textField.font = font
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let keyboardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    
    let doneButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        return barButtonItem
    }()
    
    let toolbarFlexibleSpace: UIBarButtonItem = {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        return flexSpace
    }()
    
    let daysLivedLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.alpha = 0
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let daysRemainingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.alpha = 0
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tombstoneParentView: UIView = {
        // contains the tombstone image view along with text fields and labels to animate as a whole
        let view = UIView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        if let savedAge = userDefaults.string(forKey: "age") {
            ageTextField.text = savedAge
            
        }
        if let savedExpectedAge = userDefaults.string(forKey: "expectedAge"), let age = Int(savedExpectedAge) {
            expectedAgeTextField.text = savedExpectedAge
            expectedAge = age
        }
        evaluateAgeInput()
    }

    override func loadView() {
        super.loadView()
        
        view.addSubview(bgImageView)
        view.addSubview(dashedLineImageView)
        view.addSubview(expectedAgeTextField)
        view.addSubview(tombstoneParentView)
        view.addSubview(daysRemainingLabel)
        tombstoneParentView.addSubview(tombstoneImageView)
        tombstoneParentView.addSubview(ageTextField)
        tombstoneParentView.addSubview(daysLivedLabel)
        
        ageTextField.delegate = self
        expectedAgeTextField.delegate = self
        
        arrangeViews()
    }
    
    func arrangeViews() {
        
        bgImageView.frame = view.bounds
        tombstoneParentView.frame = CGRect(x: (view.frame.width / 2) - (tombstoneImageView.frame.width / 2), y: view.frame.height  / 4 * 3, width: tombstoneImageView.frame.width, height: tombstoneImageView.frame.height)
        
        dashedLineImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dashedLineImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
        
        // x,y,w,h
        expectedAgeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        expectedAgeTextField.bottomAnchor.constraint(equalTo: dashedLineImageView.topAnchor).isActive = true
        expectedAgeTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        expectedAgeTextField.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        daysRemainingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        daysRemainingLabel.bottomAnchor.constraint(equalTo: dashedLineImageView.topAnchor, constant: -5).isActive = true
        
        tombstoneImageView.topAnchor.constraint(equalTo: tombstoneParentView.topAnchor).isActive = true
        tombstoneImageView.centerXAnchor.constraint(equalTo: tombstoneParentView.centerXAnchor).isActive = true
        
        ageTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        ageTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        ageTextField.topAnchor.constraint(equalTo: tombstoneParentView.topAnchor, constant: 40).isActive = true
        ageTextField.centerXAnchor.constraint(equalTo: tombstoneParentView.centerXAnchor).isActive = true
        
        keyboardToolbar.items = [toolbarFlexibleSpace,doneButton]
        ageTextField.inputAccessoryView = keyboardToolbar
        expectedAgeTextField.inputAccessoryView = keyboardToolbar
    
        daysLivedLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 10).isActive = true
        daysLivedLabel.centerXAnchor.constraint(equalTo: ageTextField.centerXAnchor).isActive = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ageTextField.resignFirstResponder()
        expectedAgeTextField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentCharactersInTextField = textField.text?.characters.count else { return true }
        
        if textField == ageTextField {
            // restrict age < 100
            if currentCharactersInTextField + string.characters.count > 2 {
                return false
            }
        } else {
            // restrict age < 999
            if currentCharactersInTextField + string.characters.count > 3 {
                return false
            }
        }
        return true
    }
    
    func doneButtonTapped(sender: UIBarButtonItem){
        
        if ageTextField.isFirstResponder {
            ageTextField.resignFirstResponder()
            
            // animated and create notifications for age input
            evaluateAgeInput()
            saveUserInputAge()

        } else if expectedAgeTextField.isFirstResponder {
            expectedAgeTextField.resignFirstResponder()
            
            // animate tombstone for changed expected age
            if let inputExpectedAge = expectedAgeTextField.text, let age = Int(inputExpectedAge) {
                expectedAge = Int(age)
                evaluateAgeInput()
            } else {
                // empty expectedAgeTextField
                expectedAge = 80
                expectedAgeTextField.text = "80"
                evaluateAgeInput()
            }
            saveUserInputAge()
        }
    }
    
    func calculateDaysLived(for years: Int) -> String {
        return String(years * 365)
    }
    
    func calculateDaysRemaining(for years: Int) -> String {
        return String((expectedAge - years) * 365)
    }
    
    func saveUserInputAge() {
        // save for both textfields
        if let ageInput = ageTextField.text, let expectedAgeInput = expectedAgeTextField.text {
            let userDefaults = UserDefaults.standard
            userDefaults.set(ageInput, forKey: "age")
            userDefaults.set(expectedAgeInput, forKey: "expectedAge")
        }
    }
    
    func evaluateAgeInput() {
        if let ageInput = ageTextField.text, let age = Int(ageInput) {
            if age > expectedAge {
                // pop up alert view controller
                print("Age is over expected age of \(String(expectedAge))!")
                let ac = UIAlertController(title: "Wow great job!", message: "It seems you've outlived your expectancy and kudos to you. If this is a mistake you can adjust your life expectancy at the top right.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Thanks", style: .default))
                self.present(ac, animated: true)
            } else {
                // calculate new tomb position
                updateTombstone(with: age)
                
                checkNotificationsPermissions { [unowned self] (authorized) in
                    if authorized {
                        self.createNotifications()
                    }
                }
            }
        } else {
            // reset the tomb to original position
            resetTombstone()
        }
    }
    
    func resetTombstone() {
        daysRemainingLabel.text = ""
        daysLivedLabel.text = ""
        
        UIView.animate(withDuration: 3, delay: 0, options: [], animations: { [unowned self] in
            self.daysLivedLabel.alpha = 0
            self.daysRemainingLabel.alpha = 0
        })
        UIView.animate(withDuration: 5, animations: { [unowned self] in
            self.tombstoneParentView.frame = CGRect(x: (self.view.frame.width / 2) - (self.tombstoneImageView.frame.width / 2), y: self.view.frame.height  / 4 * 3, width: self.tombstoneImageView.frame.width, height: self.tombstoneImageView.frame.height)
        })
    }
    
    func updateTombstone(with age: Int) {

        daysLivedLabel.text = "\(calculateDaysLived(for: age)) days passed."
        daysRemainingLabel.text = "\(calculateDaysRemaining(for: age)) days remaining."
        UIView.animate(withDuration: 3, delay: 0, options: [], animations: { [unowned self] in
            self.daysLivedLabel.alpha = 1
            self.daysRemainingLabel.alpha = 1
        })
        
        //calculate how far the tombstone moves up in the space between the top of the tombstone image and 90 points from the top
        
        let baseTombstonePosition = Double(view.frame.height / 4 * 3)
        
        let spaceBetweenTextFieldAndTombstone = Double(baseTombstonePosition - 90)
        
        // convert to Double to receive fraction
        let differenceInAge = Double(age) / Double(expectedAge)
        
        let newTombstonePosition = baseTombstonePosition - spaceBetweenTextFieldAndTombstone * differenceInAge
        
        UIView.animate(withDuration: 5, delay: 0, options: [], animations: { [unowned self] in
            self.tombstoneParentView.frame = CGRect(x: (self.view.frame.width / 2) - (self.tombstoneParentView.frame.width / 2), y: CGFloat(newTombstonePosition), width: self.tombstoneParentView.frame.width, height: self.tombstoneParentView.frame.height)
            self.tombstoneParentView.shake()
            }, completion: { _ in
                self.tombstoneParentView.layer.removeAllAnimations()
        })
    }
    
    func createNotifications() {
        print("create notifs")
        
        let days: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "You have this many days to live!"
        notificationContent.body = "test of body section"
        notificationContent.sound = UNNotificationSound.default()

        for day in 1...days.count {
            var notificationTimeComponents = DateComponents()
            notificationTimeComponents.timeZone = TimeZone.current
            notificationTimeComponents.hour = 6
            notificationTimeComponents.minute = 00
            notificationTimeComponents.weekday = day
            
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationTimeComponents, repeats: true)
            let notificationRequest = UNNotificationRequest(identifier: days[day - 1], content: notificationContent, trigger: notificationTrigger)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(notificationRequest) { (error: Error?) in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }

    func checkNotificationsPermissions(completion: @escaping (Bool) -> ()){
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { [unowned self] (settings) in
            if settings.authorizationStatus == .authorized {
                completion(true)
                
            } else if settings.authorizationStatus == .notDetermined {
                // request permission for notifications
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if !granted {
                        self.notificationRequiredAlert()
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
                UNUserNotificationCenter.current().delegate = self
                
            } else if settings.authorizationStatus == .denied {
                self.notificationRequiredAlert()
                completion(false)
            }
        }
    }
    
    func notificationRequiredAlert() {
        let ac = UIAlertController(title: "We know it's grim.", message: "For you to receive reminders that your life is ticking away. However, we need access to notifications. Please enable in Settings.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
}

extension UIView {
    func shake() {
        self.transform = CGAffineTransform(translationX: 1, y: 0)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0.5, options: [.repeat, .curveEaseIn], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}






















