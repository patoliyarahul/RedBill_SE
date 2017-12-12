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
let _screenFrame    = UIScreen.main.bounds
let _screenSize     = _screenFrame.size
let _widthRatio     = _screenSize.width/320
let _heighRatio     = _screenSize.height/568
let cellSpacingHeight: CGFloat = 0

let closeNotificationName = Notification.Name("close_Sidemenu")
let refreshManage = Notification.Name("referesh_Manage")


let fixOrganizationID = "1"

class Constant {
    static let URL_PREFIX   =   "http://54.67.19.220/RedbillDevelopment/ws/api/"
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

struct ApiName {
    static let get_content              = "content/get_content"
    static let post_login               = "content/login"
    static let forgot_password          = "content/forgot_password"
    static let signup                   = "content/signup"
    static let GetConfiguration         = "content/GetConfiguration"
    static let system_setting           = "content/system_setting"
    static let GetCategory              = "content/GetCategory"
    
    static let CreateListing            = "product/CreateListing"
    static let UpdateListing            = "product/UpdateListing"
    static let GetListing               = "product/GetListing"
    static let UpdateListingStatus      = "product/UpdateListingStatus"
    
    static let makeOffer      = "offer/make_offer"
}

struct API_param {
    static let status = "status"
    static let data = "data"
    static let message = "message"
    
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
        static let UserId = "UserId"
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
        static let product_id = "productid"
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
    
    static let manageOfferSegue = "manageOfferSegue"
    static let historySegue = "historySegue"
    static let settingSegue = "settingSegue"
    static let managePaymentSegue = "managePaymentSegue"
    
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
    
    static let device_type_val  =   "1" //  1 for ios 2 for android
    static let login_type_nor   =   "1" //  1 for normal login
    static let login_type_fb    =   "2" //  2 for android login
    static let user_type_val    =   "2" //  2 for end user
    static let prfoileDir           =   "/uploads_profile/"
    
}

struct Regx {
    static let email        = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    static let pass         = "[A-Za-z0-9.!@#$^_]{8,20}"
    static let phone        = "[(]?[1-9][0-9]{2}[)]?[ -]?[0-9]{3}[ -]?[0-9]{4}"
    static let firstName    = "[a-zA-Z ]{1,50}"
    static let lastName     = "[a-zA-Z ]{1,50}"
    static let ZIPCode      = "^([0-9]{5})$"
    static let Street       = "[A-Za-z0-9. _]{1,80}"
    static let CVV          = "^([0-9]{3,4})$"
    static let card         = "^([0-9-]{15,25})$"
    static let price         = "[0-9.]{1,8}"
    static let title         = "[a-zA-Z0-9 ]{2,30}"

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

//enum status {
//    case
//}


//MARK: Webservice Action

struct WebApi {
    
    static let loginApi                            =   "nurse/login"
    static let getAllPatientOfNurse                =   "patient/get" // Get All All Patient Of  Nurse
    static let addPatient                          =   "patient/add_patient"   // Add new patient
    static let updatePatient                       =   "patient/update_patient"   // Update patient
    static let getAllAllergies                     =   "patient/allergies"
    static let getAllpatient_Prescription          =   "patient/patient_prescription" // Get All All Prescription
    static let forgot_password                     =   "nurse/forgot_password" // Forgot_password
    static let generateReorderPre                  =   "patient/generateReorderPre" // Generate Reorder Prescription
    static let inactivate_prescription             =   "patient/inactivate_prescription" // Make Inactive Prescription
    static let AddToCart_prescription              =   "patient/addtocart" // Make Inactive Prescription
    static let getDrug                             =   "patient/drug" // Get Drug
    static let add_prescription                    =   "patient/add_prescription" // ADD Prescription
    
    
    static let getPaymentDetailsList    =   "get_payment_details_list.php"
    static let addPyamentDetails        =   "add_payment_details.php"
    static let logOut                   =   "log_out.php"
    static let getRateAndGuest          =   "get_rate_and_guest.php"
    static let placeOrder               =   "place_order.php"
    static let getAppointmentHistory    =   "get_end_user_order_history.php"
    static let getInsuranceProviderList =   "get_insurance_provider_list.php"
    static let enableDisableNotification    =   "enable_disable_notification.php"
    static let editPaymentById          =   "edit_payment_method_by_id.php"
    static let deletePaymentById        =   "delete_payment_method_by_id.php"
    static let updateOrderStatus        =   "update_order_status_by_id.php"
    static let support                  =   "contact_support.php"
    
    static let getAcceptedOrderList     =   "get_end_user_accepted_order.php"
    static let updateAcceptedOrder      =   "update_accepted_order.php"
    
    
}

struct MESSAGES {
    
    static let SERVER_PROBLEM  = "Opps, Getting Problem at ServerSide"
    static let app_name         = "RedBill"
    
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

    static let title_valid = "Title should be between 2 to 30 characters."
    static let price_valid = "Price can be 8 digit max."
    static let minPice_empty = "Please enter min price"
    static let maxPice_empty = "Please enter max price"
    static let maxPice_inValid = "Max price should be greater then Min price!"
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
