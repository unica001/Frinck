
import UIKit
import DZNEmptyDataSet

class FRRedeemViewController: UIViewController,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    internal var viewModel: RedeemOfferModelling?
    @IBOutlet var rangeSlider: UISlider!
    @IBOutlet weak var maxRangeLabel: UILabel!
    @IBOutlet weak var minRangeLabel: UILabel!
    
    var sliderLabel: UILabel?
    var offerType : NSString = ""
    var fromViewController : String = ""
    var offerFilterArray = [RedeemOfferListModel]()
    var offerArray = [RedeemOfferListModel]()
    var offerDetailModel : RedeemOfferDetailModel!

    var loginInfoDictionary :NSMutableDictionary!
    var showHude : Bool = false
    var  bannerImageView: UIImageView!
    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.emptyDataSetDelegate = self
        self.collectionView.emptyDataSetSource = self
        
        showHude = true
        self.view.backgroundColor = kLightGrayColor
        loginInfoDictionary = NSKeyedUnarchiver.unarchiveObject(with: kUserDefault.value(forKey: kloginInfo) as! Data) as! NSMutableDictionary

        if viewModel == nil {
            viewModel = RedeemOfferModule()
        }
        
        getRedeemOfferList()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let handleView = rangeSlider.subviews.last as? UIImageView {
            if self.sliderLabel == nil {
            let label = UILabel(frame: handleView.bounds)
            label.backgroundColor = .clear
            label.textColor = .red
            label.textAlignment = .center
            label.font = UIFont(name: kFontTextRegular, size: 9)
            handleView.addSubview(label)
            self.sliderLabel = label
            }
        }
        self.setSliderValues(max: NSInteger(rangeSlider.maximumValue))

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK : Button Action
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
 
    @IBAction func rangeSliderValuechangedAction(_ sender: Any) {
        self.sliderLabel?.text = String(Int(rangeSlider.value))
        offerFilterArray = self.offerArray
        var filterArray  = [RedeemOfferListModel]()
        
        for dict in self.offerFilterArray {
            if dict.requiredPoint <= Int(rangeSlider.value) {
                filterArray.append(dict)
            }
        }
        
        offerFilterArray = filterArray
        collectionView.reloadData()
    }
    
    
    func setSliderValues(max : NSInteger){
        
    rangeSlider.maximumValue = Float(max)
    rangeSlider.minimumValue = 0
    rangeSlider.value =  Float(max)/2
    self.sliderLabel?.text = String(max/2)
    minRangeLabel.text = "0"
    sliderLabel?.text = String(max/2)
    maxRangeLabel.text = String(max)
        
    }
    
    // MARK : APIS call
    func getRedeemOfferList(){
         viewModel?.getRedeemOfferList(loginInfoDictionary[kCustomerId]! as AnyObject,pageIndex as AnyObject , redeemOfferHandelling:{ [weak self] (response, isSuccess, msg) in
            
            guard self != nil else { return }
            
            if isSuccess {
                if self?.pageIndex == 1 {
                    self?.offerArray = response.offerList
                } else {
                    self?.offerArray.append(contentsOf: response.offerList)
                }
                print(response)
                self?.offerDetailModel = response
                self?.offerFilterArray = (self?.offerArray)!
                self?.setSliderValues(max: response.maxPoint)
                self?.collectionView.reloadData()
            } else {
//                alertController(controller: self!, title: "", message:msg, okButtonTitle: "OK", completionHandler: {(index) -> Void in
//
//                })
            }
        })
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == kRedeemSegueIdentifier {
            let  offerRedeemDetails :FRRedeemOfferDetailController = segue.destination as! FRRedeemOfferDetailController
            offerRedeemDetails.redeemOfferDict  = sender as? RedeemOfferListModel
            offerRedeemDetails.offerDetailModel = offerDetailModel
        }
    }
    
}

// MARK Collection View Delegates

extension FRRedeemViewController : UICollectionViewDelegate{
    
    // MARK:- Collection view Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offerFilterArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RedeemOfferCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        let dict = offerFilterArray[indexPath.row]
        cell.setOfferData(dictionary:dict)
      
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (ScreenSize.width-30)/2, height: 180) // The size of one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, 10) // margin between cells
    }
}

extension FRRedeemViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = offerFilterArray[indexPath.row]
        self.performSegue(withIdentifier: kRedeemSegueIdentifier, sender: dict)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= -40 && offerFilterArray.count != 0 {
            pageIndex = pageIndex + 1
            showHude = true
            getRedeemOfferList()
        }
    }
}

extension FRRedeemViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let txtAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font: UIFont(name: kFontTextSemibold, size: 15.0)! , NSAttributedStringKey.foregroundColor: UIColor.black]
        let placeholderText = NSAttributedString(string: "No offer found", attributes: txtAttributes)
        return placeholderText
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attString = NSAttributedString(string: "Refresh", attributes: [ NSAttributedStringKey.font: UIFont(name: kFontTextMedium, size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.red])
        return attString
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.pageIndex = 1
        getRedeemOfferList()
    }
}
