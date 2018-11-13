//
//  FRInfoViewC.swift
//  Frinck
//
//  Created by meenakshi on 5/29/18.
//  Copyright © 2018 sirez-ios. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SJSegmentedScrollView

class FRInfoViewC: UIViewController {

    @IBOutlet weak var tblInfoViewC: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    
    let GenderArray = ["Male","Female", "Other"]
    var isEdit = false
    var arrProfileInfo = [InfoStruct]()
    internal var viewModel : InfoViewModelling?
    internal var userId: Int? = nil
    var dictInfo = [String : AnyObject]()
    
    //MARK: - View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Private Methods
    private func recheckVM() {
        if self.viewModel == nil {
            self.viewModel = InfoViewModel()
        }
    }
    
    private func setUpView() {
        recheckVM()
        arrProfileInfo = (viewModel?.prepareInfo(dictInfo: dictInfo))!
        btnEdit.isHidden = (userId == nil) ? false : true
        tblInfoViewC.register(UINib(nibName: "CellInfo", bundle: nil), forCellReuseIdentifier: "CellInfo")
        tblInfoViewC.register(UINib(nibName: "CellGender", bundle: nil), forCellReuseIdentifier: "CellGender")
    }

    //MARK: - IBAction Methods
    @IBAction func tapEdit(_ sender: UIButton) {
        if isEdit {
            isEdit = false
            self.viewModel?.validateFields(dataStore: arrProfileInfo, validHandler: { (dictParam, strMsg, isSucess) in
                if isSucess {
                    self.viewModel?.callApiEditProfile(param: dictParam, editProfileHandler: { (success, msg, isOtp, mobileNumber) in
                        if success {
                            if isOtp {
                                self.btnEdit.setTitle("Edit", for: .normal)
                                self.btnEdit.setImage(#imageLiteral(resourceName: "Edit-1") , for: .normal)
                                self.tblInfoViewC.reloadData() 
                                let sb = UIStoryboard(name: "Main", bundle: nil)
                                let otpViewC = sb.instantiateViewController(withIdentifier: "FROTPViewController") as? FROTPViewController
                                otpViewC?.incommingType = "EditProfile"
                                otpViewC?.mobileNumberString = mobileNumber
                               self.navigationController?.hidesBottomBarWhenPushed = true
                                self.navigationController?.pushViewController(otpViewC!, animated: true)
                            } else {
                                alertController(controller: self, title: "", message: msg, okButtonTitle: "Ok", completionHandler: { (value) in
                                    self.btnEdit.setTitle("Edit", for: .normal)
                                    self.btnEdit.setImage(#imageLiteral(resourceName: "Edit-1") , for: .normal)
                                    self.tblInfoViewC.reloadData()
                                })
                            }
                        } else {
                            alertController(controller: self, title: "", message: msg, okButtonTitle: "Ok", completionHandler: { (value) in
                            })
                        }
                    })
                } else {
                    alertController(controller: self, title: "", message: strMsg, okButtonTitle: "Ok", completionHandler: { (value) in
                    })
                }
            })
        } else {
            isEdit = true
            btnEdit.setTitle("Done", for: .normal)
            btnEdit.setImage(UIImage(named: ""), for: .normal)
            self.tblInfoViewC.reloadData()
        }
    }
    
    func tapGender(indexPath: IndexPath) {
        var dict = arrProfileInfo[(indexPath.row)]
        if dict.type == ProfileType.gender {
            ActionSheetStringPicker.show(withTitle: "Select Gender", rows: GenderArray, initialSelection: 0, doneBlock: {
                    picker, value, index in
                dict.value = self.GenderArray[value]
                self.arrProfileInfo[(indexPath.row)] = dict
                self.tblInfoViewC.reloadRows(at: [IndexPath(row: (indexPath.row), section: 0)], with: .none)
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: self.parent?.view)
        }
    }
  
    func selectDob(indexPath: IndexPath) {
        var dict = arrProfileInfo[indexPath.row]
        var selectedDate = Date() as Date?
        var dateFormatter = DateFormatter()
       
        if let info = dict.value, info != ""{
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let date = dateFormatter.date(from:info)
            selectedDate = date
        } else {
            selectedDate = Date()
        }
        let datePicker = ActionSheetDatePicker(title: "Date", datePickerMode: UIDatePickerMode.date, selectedDate: selectedDate, doneBlock: {
            picker, value, index in
            
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
            let date = dateFormatter.date(from: String(describing: value!))
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dict.value = dateFormatter.string(from: date!)
            self.arrProfileInfo[indexPath.row] = dict
            self.tblInfoViewC.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
            return
        }, cancel: {
            ActionStringCancelBlock in return }, origin: self.parent?.view)
        let secondsInWeek: TimeInterval = 365 * 70 * 24 * 60 * 60;
        
        datePicker?.minimumDate = Date(timeInterval: -secondsInWeek, since: Date())
        datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -0, to: Date())
        datePicker?.show()
    }
    
    func getIndexPathFor(view: UIView, tableView: UITableView) -> IndexPath? {
        let point = tableView.convert(view.bounds.origin, from: view)
        let indexPath = tableView.indexPathForRow(at: point)
        return indexPath
    }
}

extension FRInfoViewC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProfileInfo.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dict = arrProfileInfo[indexPath.row]
//        if let type = dict.type, type != ProfileType.gender {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellInfo") as? CellInfo
            cell?.configureInfoCell(dict: dict, isEdit: isEdit)
            cell?.txtInfo.delegate = self
            return cell!
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CellGender") as? CellGender
//            cell?.configureGenderCell(dict: dict, isEdit: isEdit)
//            cell?.btnGender.addTarget(self, action: #selector(tapGender(_:)), for: .touchUpInside)
//            return cell!
//        }
    }
}

extension FRInfoViewC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let point = tblInfoViewC.convert(textField.bounds.origin, from: textField)
        let index = tblInfoViewC.indexPathForRow(at: point)
        
        let dict = arrProfileInfo[(index?.row)!]
        if let type = dict.type, type == ProfileType.dob {
            selectDob(indexPath: index!)
            return false
        } else if let gender = dict.type, gender == ProfileType.gender {
            tapGender(indexPath: index!)
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let point = tblInfoViewC.convert(textField.bounds.origin, from: textField)
        let index = tblInfoViewC.indexPathForRow(at: point)
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        arrProfileInfo[(index?.row)!].value = str
        return true
    }
}

extension FRInfoViewC: SJSegmentedViewControllerViewSource {
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return tblInfoViewC
    }
}
