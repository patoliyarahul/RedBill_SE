//
//  Constant.swift
//  NUE Partners
//
//  Created by Dharmesh Vaghani on 24/03/17.
//  Copyright © 2017 Dharmesh Vaghani. All rights reserved.
//

import UIKit
import Foundation

let userDefault = UserDefaults.standard
let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let dashBoardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
let myAccountStoryboard = UIStoryboard(name: "MyAccount", bundle: nil)

let _screenFrame    = UIScreen.main.bounds
let _screenSize     = _screenFrame.size
let _widthRatio     = _screenSize.width/320
let _heighRatio     = _screenSize.height/568
let cellSpacingHeight: CGFloat = 0

let closeNotificationName = Notification.Name("close_Sidemenu")
let refreshManage = Notification.Name("referesh_Manage")
let helperOb = HelperMethod()

let fixOrganizationID = "1"

class Constant {
//    Live
//    static let URL_PREFIX   =   "http://54.67.19.220/RedbillDevelopment/ws/api/"
//        static let baseImagePath   =   "http://54.67.19.220/RedbillDevelopment/assets/upload/listing/";
//    Testing
    static let URL_PREFIX   =   "http://54.67.19.220/RedbillDevelopment-Test/ws/api/"
    static let baseImagePath   =   "http://54.67.19.220/RedbillDevelopment-Test/assets/upload/listing/";

    
    static let kIsLoggedIn  =   "kIsLoggedIn";
    static let kAuthToken   =   "kAuthToken";
}

func uiColorFromHex(rgbValue:UInt32)->UIColor{
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
    let blue = CGFloat(rgbValue & 0xFF)/255.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

func dubugPrint(_ object : Any) {
    print(object)
}

struct Allergies
{
    var name: String!
}
struct fontName
{
    static let regularFontName = "ProximaNova-Regular"
    static let boldFontName = "ProximaNova-Bold"
    static let blackFontName = "ProximaNova-Black"
}
struct ColorButton
{
    static let btnBackgroundColor = uiColorFromHex(rgbValue: 0x14A1A2)
    static let activeColor = uiColorFromHex(rgbValue: 0x14ABAC)
    static let inactiveColor = uiColorFromHex(rgbValue: 0xCBCBCB)
}

struct ColorBorder
{
    static let viewBorderColor = 0x979797
    static let patientViewBorderColor = 0xDAE3E9
    static let btnPatientInfoBorderColor = 0x4990E2
}
struct Color
{
    // APP color
    static var navBarColor = uiColorFromHex(rgbValue: 0xF1F1F1)
    static var buttonBorderColor = uiColorFromHex(rgbValue: 0xEA1917)
    static var textColor = uiColorFromHex(rgbValue: 0x4A4A4A)
    static var redColor = uiColorFromHex(rgbValue: 0xEA1917)
}
struct ApiName {
    static let get_content              = "content/get_content"
    static let post_login               = "content/login"
    static let check_email               = "content/check_email"
    static let forgot_password          = "content/forgot_password"
    static let signup                   = "content/signup"
    static let GetConfiguration         = "content/GetConfiguration"
    static let system_setting           = "content/system_setting"
    static let GetCategory              = "content/GetCategory"
    
    static let CreateListing            = "product/CreateListing"
    static let UpdateListing            = "product/UpdateListing"
    static let GetListing               = "product/GetListing"
    static let UpdateListingStatus      = "product/UpdateListingStatus"
    static let makeOffer                = "offer/make_offer"
    static let manageOffer              = "offer/manage_offer"
    static let OfferDetails             = "offer/offer_details"
    static let getSavedCard             = "content/GetCardDetails"
    static let addPaymentCard           = "content/AddCardDetails"
    static let updatePaymentCard        = "content/UpdateCardDetails"
    static let myProductList            = "offer/product_user_sell_buy"
    static let cancelOffer              = "offer/cancel_offer"
    static let acceptOffer              = "offer/accept_offer"
    static let denyOffer                = "offer/denny_offer"
    static let updateOffer              = "offer/update_offer"
    static let support                  = "content/contact_us"
    static let update_profile           = "content/update_profile"
    static let delete_profile           = "content/delete_user_account"
    static let change_pass              = "content/change_password"
    static let change_push              = "content/update_push_setting"
    static let logout                   = "content/logout"
    static let chatNotification         = "content/chat_push_notification"
    static let sellerOrganizationDonation        = "offer/SellerOrganizationDonation"
    
    static let offerHistory             = "offer/offer_history"
    static let create_order_buyer       = "offer/create_order_buyer"
    static let get_product_donation     = "offer/getSellerForDonation"
    
    static let updateProductView     = "offer/update_product_view"
    static let getOfferCount     = "offer/get_offer_count"

}

struct API_param {
    static let status = "status"
    static let data = "data"
    static let message = "message"
    static let pushNotification = "push_notification"
    
    struct Content {
        static let content = "content"
        static let code = "code"
    }
    
    struct Login {
        static let email = "email"
        static let password = "password"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let device_id = "device_id"
        static let type = "type"
        static let UserId = "user_id"
        static let fb_token = "fb_token"
        static let login_type = "login_type"
        static let first_name = "first_name"
        static let last_name = "last_name"
        static let phone = "phone"
    }
    
    struct Signup {
        static let first_name = "first_name"
        static let last_name = "last_name"
        static let email = "email"
        static let password = "password"
        static let phone = "phone"
        static let organization = "organization"
        static let card_number = "card_number"
        static let cvv = "cvv"
        static let expiry_date = "expiry_date"
        static let billing_zip_code = "billing_zip_code"
        static let device_id = "device_id"
    }
    struct Product {
        
        static let title = "title"
        static let category_id = "category_id"
        static let min_price = "min_price"
        static let max_price = "max_price"
        static let distance = "distance"
        static let id = "id"
        static let limit = "limit"
        static let offset = "offset"
        static let created_by = "created_by"
        static let mylist = "mylist"
        static let description = "description"
        static let category_name = "category_name"
        static let name = "name"
        static let category_keyword = "category_keyword"
        static let price = "price"
        static let status = "status"
        static let images = "images"
        static let image_path = "image_path"
        static let image_name = "image_name"
        static let buyer_id = "buyer_id"
        static let product_id = "product_id" //productid
        static let seller_id = "seller_id"
        static let offer_type = "offer_type"
        static let seller_email = "seller_email"
        static let master_offer_id = "master_offer_id"
    }
    
    //MARK: Manage Offer Parameters
    struct ManageOfferParams {
        static let User_Id       =   "user_id"
        static let Product_Id    =   "product_id"
    }
    
    //MARK: Manage Offer Parameters
    struct updateProductView {
        static let Seller_Id                = "seller_id"
        static let Buyer_Id                 = "buyer_id"
        static let Product_Id               = "product_id"
    }
    
    //MARK: Offer Details Parameters
    struct OfferDetailsParams {
        static let Seller_Id                = "seller_id"
        static let Buyer_Id                 = "buyer_id"
        static let Product_Id               = "product_id"
        static let ProductId                = "product_id" //productid
        static let Offer_Price              = "offer_price"
        static let Master_offer_id          = "master_offer_id"
        static let Organization_id          = "organization_id"
        static let Order_price              = "order_price"
        static let Seller_order_price       = "seller_order_price"

        static let Order_Id                 = "order_id"
        static let DonationPrice            = "donation_price"
    }
    
    //MARK: Add card Parameters
    struct AddCardParams
    {
        static let User_Id          =   "user_id"
        static let Card_Number      =   "card_number"
        static let Cvv              =   "cvv"
        static let Is_Default       =   "is_default"
        static let Expiry_Date      =   "expiry_date"
        static let Zip_Code         =   "zip_code"
        static let Card_Id          =   "card_id"
    }
    
    //MARK: Update Offer Parameters
    struct UpdateOfferParams
    {
        static let Offer_Id          =   "offer_id"
        static let Offer_Price       =   "offer_price"
    }
}

struct SegueIdentifire {
    static let ForgetPassword = "ForgetPassword"
    static let Payment = "paymentSegue"
    static let Organization = "organizationSegue"
    
    static let LoginSegue = "loginSegue"
    static let detailSgue = "detailSgue"
    
    static let createItemSegue = "createItemSegue"
    
    static let editItemSegue = "editItemSegue"
    static let itemDetailSegue = "itemDetailSegue"
    
    static let manageProductSegue = "manageProductSegue"
    static let historySegue = "productHistorySegue"
    static let settingSegue = "settingSegue"
    static let managePaymentSegue = "managePaymentSegue"
    static let offerDetailSegue = "OfferDetailSegue"
    static let myCardsSegue = "MyCardsSegue"
    static let addPaymentCardSegue = "AddPaymentCardSegue"
    static let productOfferSegue = "ProductOfferSegue"
    static let homeSegue = "HomeSegue"
    static let offerDetailsPaymentSegue = "OfferDetailsPaymentSegue"
    static let offerDetailsOfferEditSegue = "OfferDetailsOfferEditSegue"
    static let confirmPurchaseSegue = "ConfirmPurchaseSegue"
    static let transactionCompleteSegue = "transactionCompleteSegue"
    static let donationSegue = "donationSegue"
    
    static let chatSegue        = "chatSegue"
    static let showChatSegue    = "showChatSegue"
}

struct statusColor {
    static let active   = UIColor(red: 20.0/255, green: 171.0/255, blue: 172.0/255, alpha: 1)
    static let blue     = UIColor(red: 43.0/255, green: 165.0/255, blue: 205.0/255, alpha: 1)
    static let error    = UIColor(red: 251.0/255, green: 147.0/255, blue: 149.0/255, alpha: 1)
}

struct DefaultValues {
    static let device_type      =   "device_type"
    static let login_type       =   "login_type"
    static let device_id        =   "device_id"
    static let user_type        =   "user_type"
    static let uuid             =   "uuid"
    static let percentage       =   "5"
    static let device_type_val  =   "1" //  1 for ios 2 for android
    static let login_type_nor   =   "1" //  1 for normal login
    static let login_type_fb    =   "2" //  2 for android login
    static let user_type_val    =   "2" //  2 for end user
    static let prfoileDir       =   "/uploads_profile/"
    
}

struct Regx {
    static let email        = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    static let pass         = "[A-Za-z0-9.!@#$^_]{8,20}"
    static let phone        = "[(]?[1-9][0-9]{2}[)]?[ -]?[0-9]{3}[ -]?[0-9]{4}"
    static let firstName    = "^[a-zA-Z0-9!@#$&()\\-`.+,/\" ]{1,50}"
    static let lastName     = "^[a-zA-Z0-9!@#$&()\\-`.+,/\" ]{1,50}"
    static let ZIPCode      = "^([0-9]{5})$"
    static let Street       = "^[a-zA-Z0-9!@#$&()\\-`.+,/\" ]{1,80}"
    static let CVV          = "^([0-9]{3,4})$"
    static let card         = "^([0-9-]{15,25})$"
    static let price         = "[0-9.]{1,8}"
    static let title         = "[a-zA-Z0-9!@#$&()\\-`.+,/\" ]{2,30}"
}

//MARK: Login Parameters

struct LoginParams {
    
    static let Username               =   "username"
    static let Password               =   "password"
    static let type                   =   "type"
}
//MARK: ForgetPwd Parameters

struct ForgetPwd {
    
    static let Email               =   "email"
}

//MARK: Get ALl Patient Parameters

struct GetAllPatientParams {
    static let nurse_id               =   "nurse_id"
}

//MARK: Common Parameters

struct commonParams {
    
    static let http_user               =   "http_user"
    static let http_pass               =   "http_pass"
    static let http_auth               =   "http_auth"
}

//MARK: Get patient_prescription Parameter

struct PatientPrescriptionParams {
    
    static let Patient_Id               =   "patient_id"
    static let Nurse_Id                 =   "nurse_id"
}

//MARK: Reorder Prescription Parameters Value

struct ReorderPrescriptionParamsValue {
    
    static let Prescription_id            =   "prescription_id"
}

//MARK: Make InActive Prescription Parameters Value

struct InactivePrescriptionParamsValue {
    static let Prescription_id            =   "prescription_id"
}

//MARK: Make Add Prescription To Cart Parameters Value

struct AddPrescriptionToCartParamsValue {
    static let Prescription_id            =   "prescription_id"
}

//MARK: Common Parameters Value

struct commonParamsValue {
    static let Appstone                =   "appstone"
    static let Tech                    =   "Tech@123"
    static let Digest                  =   "digest"
}

struct staus {
    static let Denny                  =   "Denny"
    static let Counter                =   "Counter"
    static let Accept                 =   "Accept"
    static let Accepted                 =   "Accepted"
    static let Cancel                 =   "Cancel"
    static let Cancled                =   "Cancled"
    static let Edit                   =   "Edit"
}

struct Offer_Message {
    static let Offer_Decline = "Offer Decline."
    static let Offer_Accepeted = "Accepeted."
    static let Offer_Canceled = "Offer Canceled."
}

struct User {
    static let Buyer = "Buyer"
    static let Seller = "Seller"
}

struct MESSAGES {
    
    static let NO_PRODUCT = "No Product Found"
    static let SERVER_PROBLEM  = "Opps, Getting Problem at ServerSide"
    static let app_name         = "RedBill"
    static let error         = "Error"
    static let no_internet = "The Internet connection appears to be offline."
    //Login & Signup Messages
    static let email_empty      =   "Please enter email address."
    static let email_valid      =   "Please enter valid email address."
    static let phone_valid      =   "Please enter valid phone number."
    
    static let pass_empty       =   "Please enter password."
    static let conform_pass_empty  =   "Please enter confirm password."
    
    static let conform_pass_no_match =   "Password and Confirm Password are not same."
    static let pass_valid       =   "Please enter valid password."
    
    static let login_success    =   "You have successfully logged in."
    static let login_failed     =   "Something wrong in login process."
    
    //Signup Message
    
    static let firstName_empty  =   "Please enter first name."
    static let firstName_valid  =   "Please enter valid first name."
    static let lastName_empty   =   "Please enter last name."
    static let lastName_valid   =   "Please enter valid last name."
    static let phone_empty      =   "Please enter Phone"
    
    // Add Payment
    
    static let card_empty = "Please enter card number"
    static let cvv_empty = "Please enter CVV number"
    static let date_empty = "Please enter expiry date"
    static let cvv_valid = "Please enter valid CVV"
    static let zip_valid = "Please enter valid ZIP code"
    static let card_valid = "Please enter valid card number"
    
    // Product
    static let title_empty = "Please enter title"
    static let category_empty = "Please select categoty"
    static let price_empty = "Please enter price"
    static let desc_empty = "Please enter description"
    static let photo_empty = "Please add minimum 1 picture of a product!"

    static let title_valid = "Title should be between 2 to 30 characters."
    static let price_valid = "Price can be 8 digit max."
    static let minPice_empty = "Please enter min price"
    static let maxPice_empty = "Please enter max price"
    static let maxPice_inValid = "Max price should be greater then Min price!"
    
    static let first_empty      =   "Please enter name"
    static let request_rebooked =   "Request booked successfully"
    static let old_Pass_empty   =   "Please enter old password"
    static let new_Pass_empty   =   "Please enter new password"
    
    static let confirm_Pass_empty       = "Please enter confirm password"
    static let confirm_Pass_nomatch     = "New password and confirm password does not match"
    static let NO_SERVICE_SELECTED      = "Please select atleast one service to continue"
    static let request_canceled_succ    = "Request canceled successfully."
    static let cancel_order             = "If you are cancelling after 5 minutes of placing an order there will be a 15% fee of your order total.  Do you wish to continue cancelling your order?"
    
    static let cancel_offer = "Are you sure you want to cancel the offer?"
    static let accept_offer = "Are you sure you want to accept the offer?"
    static let not_edit_offer = "You cann't edit older offer!"
    
    static let donation_succes = "Thank you for your contribution.  We will donate the funds on your behalf to your selected organization."
}

//MARK: DateFormet
struct DateFormet {
    static let DoB                              =   "MMM d, YYYY"
    static let ServerDateFormet                 =   "yyyy-MM-dd HH:mm:ss"
    static let NormalDateFormet                 =   "yyyy-MM-dd"
    static let DatePickerDateFormet             =   "yyyy-MM-dd HH:mm:ss Z"
    static let DeliverybyDateFormet             =   "HH:mm a"
}

//MARK : - JSON 
extension Dictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        debugPrint(json)
    }
}
//MARK : - Check Whether Array is Sorted Or Not
extension Array {
    func isSorted( isOrderedBefore: (String, String) -> Bool) -> Bool {
        for i in 1..<count {
            if !isOrderedBefore(self[i-1] as! String, self[i] as! String) {
                return false
            }
        }
        return true
    }
}

/*
 0 = UnPurchase
 1 = Add To Cart
 2 = Active
 
 UnPurchase = U
 Inactive = I
 Active = A
 */


//MARK: - ChatNotification Paramters

struct ChatNotificationParams {
    static let recieverId   = "recieverId"
    static let senderId     = "sender_id"
    static let senderName   = "sender_name"
    static let senderEmail  = "sender_email"
    static let pushMessage  = "push_message"
}

//MARK: - paramters for firebase chat

struct FUserParams {
    static let FUSER_PATH                           = "User"                //    Path name
    static let FUSER_OBJECTID                       = "objectId"            //    String
    
    static let FUSER_EMAIL                          = "email"                //    String
    static let FUSER_FIRSTNAME                      = "first_name"            //    String
    static let FUSER_LASTNAME                       = "last_name"            //    String
    static let FUSER_FULLNAME                       = "fullname"            //    String
    static let FUSER_TYPE                           = "userType"                //    String
    
    static let FUSER_PICTURE                        = "picture"                //    String
    static let FUSER_THUMBNAIL                      = "thumbnail"            //    String
    
    static let FUSER_CREATEDAT                      = "createdAt"            //    Interval
    static let FUSER_UPDATEDAT                      = "updatedAt"            //    Interval
    
    static let FUSER_DBID                           =  "dbId"
}

struct FMessageParams {
    static let FMESSAGE_PATH                        = "Message"                //    Path name
    static let FMESSAGE_OBJECTID                    = "objectId"            //    String
    
    static let FMESSAGE_GROUPID                     = "groupId"                //    String
    static let FMESSAGE_SENDERID                    = "senderId"            //    String
    static let FMESSAGE_SENDERNAME                    = "senderName"            //    String
    static let FMESSAGE_SENDERINITIALS                = "senderInitials"        //    String
    
    static let FMESSAGE_TYPE                        = "type"                //    String
    static let FMESSAGE_TEXT                        = "text"                //    String
    
    static let FMESSAGE_PICTURE                     = "picture"                //    String
    static let FMESSAGE_PICTURE_WIDTH                = "picture_width"        //    Number
    static let FMESSAGE_PICTURE_HEIGHT                = "picture_height"        //    Number
    static let FMESSAGE_PICTURE_MD5                 = "picture_md5"            //    String
    
    static let FMESSAGE_VIDEO                        = "video"                //    String
    static let FMESSAGE_VIDEO_DURATION                = "video_duration"        //    Number
    static let FMESSAGE_VIDEO_MD5                    = "video_md5"            //    String
    
    static let FMESSAGE_AUDIO                        = "audio"                //    String
    static let FMESSAGE_AUDIO_DURATION                = "audio_duration"        //    Number
    static let FMESSAGE_AUDIO_MD5                    = "audio_md5"            //    String
    
    static let FMESSAGE_LATITUDE                    = "latitude"            //    Number
    static let FMESSAGE_LONGITUDE                    = "longitude"            //    Number
    
    static let FMESSAGE_STATUS                        = "status"                //    String
    static let FMESSAGE_ISDELETED                    = "isDeleted"            //    Boolean
    
    static let FMESSAGE_CREATEDAT                    = "createdAt"            //    Interval
    static let FMESSAGE_UPDATEDAT                    = "updatedAt"            //    Interval
}

struct FRecentParams {
    static let FRECENT_PATH                         =   "Recent"                //    Path name
    static let FRECENT_OBJECTID                     =   "objectId"                //    String
    
    static let FRECENT_USERID                        =   "userId"                //    String
    static let FRECENT_GROUPID                        =   "groupId"                //    String
    
    static let FRECENT_INITIALS                     =   "initials"                //    String
    static let FRECENT_PICTURE                        =   "picture"                //    String
    static let FRECENT_DESCRIPTION                    =   "description"            //    String
    static let FRECENT_MEMBERS                        =   "members"                //    Array
    static let FRECENT_PASSWORD                     =   "password"                //    String
    static let FRECENT_TYPE                         =   "type"                    //    String
    
    static let FRECENT_COUNTER                        =   "counter"                //    Number
    static let FRECENT_LASTMESSAGE                    =   "lastMessage"            //    String
    static let FRECENT_LASTMESSAGEDATE                =   "lastMessageDate"        //    Interval
    
    static let FRECENT_ISARCHIVED                    =   "isArchived"            //    Boolean
    static let FRECENT_ISDELETED                    =   "isDeleted"            //    Boolean
    
    static let FRECENT_CREATEDAT                    =   "createdAt"            //    Interval
    static let FRECENT_UPDATEDAT                    =   "updatedAt"            //    Interval
    
    static let FRECENT_DBID                         =   "dbId"              // id from data base
}

struct FStatusParams {
    static let FUSERSTATUS_PATH                     =   "UserStatus"            //    Path name
    static let FUSERSTATUS_OBJECTID                 =   "objectId"            //    String
    
    static let FUSERSTATUS_NAME                     =   "name"                //    String
    
    static let FUSERSTATUS_CREATEDAT                =   "createdAt"            //    Interval
    static let FUSERSTATUS_UPDATEDAT                =   "updatedAt"            //    Interval
}

