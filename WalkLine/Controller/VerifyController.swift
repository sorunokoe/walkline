//
//  VerifyController.swift
//  WalkLine
//
//  Created by Mac on 24.09.17.
//  Copyright © 2017 salgara. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class VerifyController: UIViewController {

    @IBOutlet weak var codeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func verifyCode(_ sender: Any) {
        
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: codeField.text!)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                
            }else{
                
                if let userUid = user?.uid{
                    Database.database().reference().ref.child("users").child(userUid).child("info").setValue(["phone": myPhone, "uid": userUid])
                }
                
                self.performSegue(withIdentifier: "enter", sender: self)
            }
        }
        
        
    }
}
