//
//  FRWelcomeViewController.swift
//  Frinck
//
//  Created by dilip-ios on 02/04/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

class FRWelcomeViewController: UIViewController {
    @IBOutlet var btnRegister: UIButton!
    @IBOutlet var btnLogin: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        btnLogin.layer.cornerRadius = btnLogin.frame.size.height/2
//        btnLogin.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 23.0/255.0, alpha: 1.0)
//        btnLogin.setTitleColor(UIColor.white, for: .normal)
//        btnLogin.setTitle("LOGIN", for: .normal)
        
        btnRegister.layer.cornerRadius = btnRegister.frame.size.height/2
//        btnRegister.backgroundColor = UIColor.white
//        btnRegister.setTitleColor(UIColor.black, for: .normal)
//        btnRegister.setTitle("REGISTER", for: .normal)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false;
    }
}
