//
//  ViewController.swift
//  WalkLine
//
//  Created by Mac on 24.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import FirebaseAuth

class EntranceController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        phoneField.delegate = self
        
        
        
    }
    
    @IBAction func sendPhoneVerify(_ sender: Any) {
        
        myPhone = phoneField.text
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneField.text!) { (verificationID, error) in
            if let error = error {
                //self.showMessagePrompt(error.localizedDescription)
                print(error.localizedDescription)
                return
            }
            else{
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.performSegue(withIdentifier: "verify", sender: self)
                
            }
            
            
            }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user{
                self.performSegue(withIdentifier: "autoLogedIn", sender: self)
             }
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

