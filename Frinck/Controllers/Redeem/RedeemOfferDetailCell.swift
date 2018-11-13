

import UIKit
import SDWebImage

class RedeemOfferDetailCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var requiredPointsLabel: UILabel!
    @IBOutlet weak var minButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var quantituTextField: UITextField!
    @IBOutlet weak var pointsTextField: UITextField!
    @IBOutlet weak var userPointsTextField: UITextField!
    @IBOutlet weak var cashPayableTexField: UITextField!
    
    var requirePoints : Float = 0
    var totalPoints : Float = 0
    var isUserPointChange = false
    var newString : String = ""
    
    var offerDetailModel : RedeemOfferDetailModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        quantituTextField.layer.borderWidth = 1.0
        quantituTextField.layer.borderColor = UIColor.lightGray.cgColor
        quantituTextField.layer.cornerRadius = 5.0
        quantituTextField.layer.masksToBounds = true
        
        pointsTextField.layer.borderWidth = 1.0
        pointsTextField.layer.borderColor = UIColor.lightGray.cgColor
        pointsTextField.layer.cornerRadius = 5.0
        pointsTextField.layer.masksToBounds = true
        
        userPointsTextField.layer.borderWidth = 1.0
        userPointsTextField.layer.borderColor = UIColor.lightGray.cgColor
        userPointsTextField.layer.cornerRadius = 5.0
        userPointsTextField.layer.masksToBounds = true
        
        cashPayableTexField.layer.borderWidth = 1.0
        cashPayableTexField.layer.cornerRadius = 5.0
        cashPayableTexField.layer.borderColor = UIColor.lightGray.cgColor
        cashPayableTexField.layer.masksToBounds = true
        
        userPointsTextField.delegate = self
        
        userPointsTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
    }

    @IBAction func minButtonAction(_ sender: Any) {
        
        var selectedQuantity : Float = Float(quantituTextField.text!)!
        var pointRequired : Float = Float(pointsTextField.text!)!
        
        if selectedQuantity > 1 {
            pointRequired  =  pointRequired - (pointRequired/selectedQuantity)
            selectedQuantity = selectedQuantity - 1
        }
        quantituTextField.text = String(Int(selectedQuantity))
        getPoinstUser(totalPoints: totalPoints, requiredPoints: pointRequired)

        
    }
    @IBAction func pluseButtonAction(_ sender: Any) {
        var selectedQuantity : Float = Float(quantituTextField.text!)!
          var pointRequired : Float = Float(pointsTextField.text!)!
        
        selectedQuantity = selectedQuantity + 1
        pointRequired  = requirePoints * selectedQuantity
        quantituTextField.text = String(Int(selectedQuantity))

        getPoinstUser(totalPoints: totalPoints, requiredPoints: pointRequired)

    }
    
    func setData(dict : RedeemOfferListModel){
        
        requirePoints = Float(dict.requiredPoint)
        totalPoints = Float(dict.customerTotalPoint)
        
        self.priceLabel.text = "Price : INR \(dict.price ?? "")"
        self.requiredPointsLabel.text = "Points Required : \(String(dict.requiredPoint))"
      
        getPoinstUser(totalPoints: totalPoints, requiredPoints: requirePoints)
        self.brandNameLabel.text = dict.brandName
        // set image
        let urlString = dict.brandLogo
        let urlStrings = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStrings!)
        storeImage.sd_setImage(with:url , placeholderImage: UIImage(named : "placeHolder"), options:SDWebImageOptions.cacheMemoryOnly, completed: nil)
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK Points calculation
    func getPoinstUser(totalPoints : Float, requiredPoints : Float) {
        
        var total : Float = 0

        if isUserPointChange == true {
            total =  Float(self.userPointsTextField.text!)!
            isUserPointChange = false
        }
        else {
            if requiredPoints  >  totalPoints {
                total = totalPoints
            }else {
                total = requiredPoints
            }
        }
        print(total)
       
        self.pointsTextField.text = String(Int(requiredPoints))
        self.userPointsTextField.text = String(Int(total))
        self.cashPayableTexField.text = String((requiredPoints - total) * offerDetailModel.pointPirceValue)
    }
    
    @objc func doneButtonClicked(_ sender: Any) {
        isUserPointChange = true
        getPoinstUser(totalPoints: totalPoints, requiredPoints: Float(self.pointsTextField.text!)!)

    }
 
    @IBAction func editButtonAction(_ sender: Any) {
        self.userPointsTextField.becomeFirstResponder()
    }
}
