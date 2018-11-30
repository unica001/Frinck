import UIKit

struct ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
    static let frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
}
class Constants {
    
    class var QB_USERS_ENVIROMENT: String {
        
        #if DEBUG
        return "dev"
        #elseif QA
        return "qbqa"
        #else
        assert(false, "Not supported build configuration")
        return ""
        #endif
    }
}
struct DeviceType {
    static let iPhone4orLess = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength < 568.0
    static let iPhone5orSE = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 568.0
    static let iPhone678 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 667.0
    static let iPhone678p = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 736.0
    static let iPhoneX = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 812.0
    
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxLength == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxLength == 1366.0
}

enum Firebase: String {
    case CustomBundleId = "frinck.com.frinckapp"
    case appStoreId = "123456789"
    case firebaseDomain = "jm36x.app.goo.gl"
    case androidPackageName = ""
}

//FONTS

let kFontTextRegular  = "Montserrat-Regular"
let kFontTextRegularBold  = "Montserrat-Bold"
let kFontTextSemibold = "Montserrat-Semibold"
let kFontTextLight  = "Montserrat-Light"
let kFontTextMedium  = "Montserrat-Medium"

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kMessageContainerWidthPadding:CGFloat = 40.0

// color
let kLightGrayColor  = UIColor(red: 237/255.0, green:
    237/255.0, blue: 237.0/255.0, alpha: 1.0)
let kRedColor  = UIColor(red: 245/255.0, green:
    0/255.0, blue: 6.0/255.0, alpha: 1.0)

// MARK: - Base url
//
//let kBaseUrl = "http://103.91.90.234/api/v1/"

#if DEBUG
let kBaseUrl = "http://api.frinck.com/v1/"

#else
let kBaseUrl = "http://api.frinck.com/v1/"

#endif

let kPayload = "payloads"
let kCode =  "code"
let kMessage = "message"
let kContryCode = "91"
let kDeviceType = "deviceType"
let kUserType = "userType"

//MARK: - NSUser default
//
let kUserDefault  =  UserDefaults.standard

// MARK:- Sign Up

let kCustomerName = "CustomerName"
let kCustomerUserName = "CustomerUserName"
let kCustomerDob = "CustomerDob"
let kCustomerEmail = "CustomerEmail"
let kCustomerMobile = "CustomerMobile"
let kCustomerPassword = "CustomerPassword"
let kCustomerReferalCode = "CustomerReferalCode"
let kCustomerGender = "CustomerGender"
let kCustomerRegisterType = "CustomerRegisterType"
let kCustomerCountryCode = "CustomerCountryCode"
let kCustomerDeviceType = "CustomerDeviceType"
let kCustomerDeviceToken = "CustomerDeviceToken"
let kCustomerProfileImage = "ProfileImage"
let kSocialId  = "socialId"
let kStype = "stype"
let kFbId = "fbId"
let kGpId = "gpId"
let KCustomerSocialId = "CustomerSocialId"
let kCustomerSocialType = "CustomerSocialType"
let kPostedTime = "PostedTime"

// set new Password
let kCustomerConfirmPassword = "CustomerConfirmPassword"
let kremovePhoto = "user/photo/remove"
//MARK: - OTP

let kCustomerId = "CustomerId"
let kCustomerOtp = "CustomerOtp"

// MARK: - Login

let kloginInfo = "loginInfo"

//MARK: - Device

let kVerifySegueIdentifier = "verifySegueIdentifier"
let kVerifyForgotPasswordSegueIdentifier = "verifyForgotPasswordSegueIdentifier"
let kselectCityIdentifier = "selectCityIdentifier"
let ksegueSetNewPassword = "segueSetNewPassword"
let ksegueLoginController = "segueLoginController"
//let kSearchAllBrandSegueIdentifier = "searchAllBrandSegueIdentifier"

//MARK: -  Forgot password

let kCustomerOldPassword = "CustomerOldPassword"
let kCustomerNewPassword = "CustomerNewPassword"
let kForgotPassword = "CustomerMobile"

let ksignupSegueIdentifier = "signupSegueIdentifier"
let kforgotPasswordSegueIdentifier = "SegueForgotPassword"
let khomeViewSegueIdentifier = "homeViewSegueIdentifier"
let kOfferDetailedSegueIdentifier = "offerDetailedSegueIdentifier"
let kofferStoryboardID = "offerStoryboardID"
let kofferSegmentStoryBoard = "offerSegmentStoryBoard"
let kstoryStoryboardID = "storyStoryboardID"
let kbrnadDetailsSegueIdentifier = "brnadDetailsSegueIdentifier"
let kstatusSegueIdentifier = "statusSegueIdentifier"
let kcreatStorySegueIdentifier = "creatStorySegueIdentifier"
let kRedeemSegueIdentifier = "RedeemSegueIdentifier"
let kFRFavouriteBrandsStoryboardID = "FRFavouriteBrandsStoryboardID"
let kFRBrandDetailViewController = "FRBrandDetailViewController"

// MARK : APIs Name
let kGetcity = "location/getcity"
let kcityupdate = "user/cityupdate"
let kBrand = "brand/getbrand"
let kBrandFavourite = "brand/makefavourite"
let kOfferGetOffer = "offer/getoffer"
let kSaveOffer = "offer/saveoffer"
let kOfferDetail = "offer/offerdetail"
let kMyFavouriteBrand = "brand/myfavouritebrand"
let kcheckingetstore = "checkin/getstore"
let kmycheckinstore = "mycheckin/store"
let kbranddetail  = "brand/branddetail"
let kuserstory = "user/userstory"
let kbrandstory = "brand/brandstory"
let kcheckinconfirmation = "checkin/confirmation"
let kcheckinStatus = "checkin/status"
let kcheckinpoststory = "checkin/poststory"
let kcommentlist = "comment/list"
let kcommentpost = "comment/post"
let kgetfollowing = "user/getfollowing"
let kgetfollowers = "user/getfollowers"
let kuserList = "user/list"
let kuserUnfollow = "user/unfollow"
let kuserFollow = "user/follow"
let ksetPassword = "registration/setpassword"
let kresetPassword = "registration/changepassword"
let kuserProfile = "user/profile"
let kchangePhoto = "user/changephoto"
let keditProfile = "user/editprofile"
let kdeleteStory = "user/deletestory"
let kuserSpecificStory = "user/userspecificstory"
let kblockUser = "user/block"
let kstoryHide = "user/story/hide"
let kremovefollower = "user/removefollower"
let kredeemoffers = "redeem/offers"
let kusermypoint = "user/mypoint"
let kUnblockUser = "user/unblock"
let ksavedOffer = "user/offer"
let kreportUser = "user/report"
let kflagInappropriate = "user/flaginappropriate"
let kuserView = "user/story/getview"
let kpurchasepoint = "purchase/point"
let kpurchasevoucher = "purchase/voucher"
let kpurchasemytransaction = "purchase/mytransaction"
let kcustomerLevel = "user/level"
let ksetNotification = "user/setnotification"
let kInvite = "user/sendinvite"
let kgetNotification = "user/getnotification"
let kstorydetail = "story/detail"
let kstoryEdit = "user/editstory"
let kbrandStore = "brand/store"
let kdailyCheckIn = "user/dailyappcheckin"
let kclickUrl = "user/clickurl"
let kmyStory = "story/mystory"
let klogout = "authorization/logout"
let konlineBrand = "brand/getonlinebrand"

let kCityId = "cityId"
let kpageNo = "PageNo"
let kBrandLogo = "BrandLogo"
let kBrandList = "BrandList"
let kSearchKey = "SearchKey"
let kRequestId = "RequestId"
let kstoreWebsite = "storeWebsite"
let kstoreImage = "storeImage"

// MARK: - Get location

let kLocationId = "LocationId"
let kViewType = "ViewType"
let kOffer = "offer"
let kOfferId = "OfferId"
let kBanner = "Banner"
let kimageUrl = "imageUrl"
let kprofilePic = "profilePic"
// Offer details

let ktitle = "title"
let konlineUrl = "onlineUrl"
let kimage = "image"
let kOfferType = "OfferType"
let konline = "online"

// Brand Details
let kBrandId = "BrandId"
let kBrandStore = "BrandStore"
let kStoreAddress = "StoreAddress"
let kStoreId = "StoreId"
let kStoreName = "StoreName"
let kBrandName = "BrandName"
let kBrandOffer = "BrandOffer"
let kLatitude = "latitude"
let kLongitude = "longitude"
let kStoryId = "StoryId"

// User Story
let kMediaUrl = "MediaUrl"
let kIsReadMore = "isReadMore"
let kMediaType = "MediaType"
let kDescription = "Description"
let kIsShowComment = "showCommment"
let kVideo = "video"
let kBrandStories = "BrandStories"
let kUserStories = "UserStories"
let kisFavourite = "isFavourite"
let kBrandInfo = "BrandInfo"
let kFB = "F"
let KG = "G"

// Check in
let kmyCheckInSegueIdentifier = "myCheckInSegueIdentifier"
let kStoreDistance = "StoreDistance"
let kIsCheckIn = "IsCheckIn"
let kStoreCheckInPoint = "StoreCheckinPoint"
let kCustomerLevel = "CustomerLevel"
let kCustomerPoint = "CustomerPoint"
let kcheckinDate = "checkinDate"
let kIsExpire = "isExpire"

// CheckIn Status
let kisStoryPost = "isStoryPost"
let kCustomerTotalPoint = "CustomerTotalPoint"
let kCustomerProfilePic = "CustomerProfilePic"
let kType = "Type"
let kTitle = "Title"
let kCommentStoryboardID = "CommentStoryboardID"

// Comment
let kComment = "Comment"
let StoryId = "StoryId"
let ktotal = "total"
let kMySavedOffer = "My Saved Offer"

// Redeem Offers

let kPointUsed = "PointUsed"
let kPaidAmount = "PaidAmount"
let kTransactionId = "TransactionId"
let kPurchasedTime = "PurchasedTime"
let kQty = "Qty"
let kPoint = "Point"
let kredeemOffer = "redeemOffer"
let kVoucherId = "VoucherId"
let kPrice = "Price"
let kRequiredPoint = "RequiredPoint"
let kmaxPoint = "maxPoint"
let kpointPirceValue = "pointPirceValue"
let kmyEarned = "point/myrecievepoint"
let kPassword = "user@123"
let kqbId = "qbId"

let kBrandNotification = "BrandNotification"
let kSavedOfferNotification = "SavedOffer"
let kmyPurchaseVoucher = "purchase/myvoucher"
