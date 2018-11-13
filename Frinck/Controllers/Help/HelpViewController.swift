//
//  HelpViewController.swift
//  Frinck
//
//  Created by vineet patidar on 28/06/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit

enum Help : Int {
    case  FAQ = 0
    case  ContactUs
}
class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Help"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HelpViewController : UITableViewDelegate,UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont(name: kFontTextRegular, size: 14)
        
        if indexPath.row == Help.FAQ.rawValue {
            cell.textLabel?.text = "FAQs"
        }
        else  if indexPath.row == Help.ContactUs.rawValue {
            cell.textLabel?.text = "Contact US"
        }
       return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.row == Help.ContactUs.rawValue {
            let contactUs = sb.instantiateViewController(withIdentifier: "ContactUsViewController") as? ContactUsViewController
            self.navigationController?.pushViewController(contactUs!, animated: true)
        } else if indexPath.row == Help.FAQ.rawValue {
            let faqViewC = sb.instantiateViewController(withIdentifier: "FAQViewC") as? FAQViewC
            faqViewC?.strHeader = "FAQs"
            self.navigationController?.pushViewController(faqViewC!, animated: true)
        }
    }
    
}
