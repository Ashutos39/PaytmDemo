//
//  ViewController.swift
//  paytmDemo
//
//  Created by Sds mac mini on 19/09/18.
//  Copyright © 2018 straightdrive.co.in. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ViewController: UIViewController,PGTransactionDelegate {
    var merchant:PGMerchantConfiguration!
    var MID="Car93022631499989"
    var Channel_id="WAP"
    var INDUSTRY_TYPE_ID="Retail109"
    var WEBSITE="CarWAP"
    var CUST_ID="CUST105"
    var ORDER_ID="ASHUTOS"
    var TXN_AMOUNT="1.00"
    var GENERATE_CHECKSUM = "https://sundarASHUTOS.com/api/sundar_1/paytm/generateChecksum.php"
    var callBackUrl = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID="
    var checkSum = ""
    //    private var root : UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        //random number generation
        let number = arc4random_uniform(10000) + 1
        ORDER_ID = ORDER_ID + String(number)
        setMerchant()
        // Do any additional setup after loading the view.
    }
    
    func setMerchant(){
        merchant = PGMerchantConfiguration.default()!
        merchant.checksumGenerationURL = "https://sundarASHUTOS.com/api/sundar_1/paytm/generateChecksum.php"
        //merchant.checksumValidationURL = "https://sundarcarcare.com/api/sundar_1/paytm/verifyChecksum.php"
        getCheckSum()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getCheckSum(){
        
        SVProgressHUD.show()
        let params:[String: Any] = ["MID":MID,"CHANNEL_ID":Channel_id,"INDUSTRY_TYPE_ID":INDUSTRY_TYPE_ID,"WEBSITE":WEBSITE,"TXN_AMOUNT":TXN_AMOUNT,"ORDER_ID":ORDER_ID,"CUST_ID":CUST_ID,"CALLBACK_URL":callBackUrl + ORDER_ID]
        printLog(log: params)
        postRequest(GENERATE_CHECKSUM, params: params as [String : AnyObject]?,oauth: true, result: {
            (response: JSON?, error: NSError?, statuscode: Int) in
            SVProgressHUD.dismiss()
            guard error == nil else {
                return
            }
            if response!["payt_STATUS"].stringValue != "1" {
                printLog(log: response!["reason"].stringValue)
            } else {
                printLog(log: response!)
                if statuscode == 200{
                    self.checkSum = response!["CHECKSUMHASH"].stringValue
                    self.createPayment()
                }
            }
        })
    
    }
    
    func createPayment(){
        var orderDict=[String : String]()
        
        orderDict["CHANNEL_ID"]=Channel_id   //mandatory // paste here channel id // mandatory
        orderDict["MID"]=MID//paste here your merchant id
        orderDict["INDUSTRY_TYPE_ID"]=INDUSTRY_TYPE_ID //paste industry type //mandatory
        orderDict["WEBSITE"]=WEBSITE // paste website//mandatory
        //Order configuration in the order object
        orderDict["TXN_AMOUNT"]=TXN_AMOUNT // amount to charge// mandatory
        orderDict["ORDER_ID"]=ORDER_ID//change order id every time on new transaction
        //orderDict["REQUEST_TYPE"] = "DEFAULT";// remain same
        orderDict["CUST_ID"]=CUST_ID // change acc. to your database user/customers
        orderDict["CALLBACK_URL"]=callBackUrl + ORDER_ID
        orderDict["CHECKSUMHASH"]=checkSum
        
        let pgOrder = PGOrder(params: orderDict )
        let transaction = PGTransactionViewController.init(transactionFor: pgOrder)
        transaction!.serverType = eServerTypeProduction
        transaction!.merchant = merchant
        transaction!.loggingEnabled = true
        transaction!.delegate = self
        self.present(transaction!, animated: true, completion: {
        })
    }
    
    func showAlert(title:String,message:String)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //    func didFinishCASTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
    //        print(response)
    //        showAlert(title: "cas", message: "")
    //    }
    
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        let data = responseString.data(using: .utf8)!
        let obj = JSON(data: data)
        
        if obj["STATUS"].stringValue != "TXN_SUCCESS" {
           
            print("Sucess")
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!) {
        print("Cancelled")
        
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        print("Missing Parameter")
        
    }
    
    
}

