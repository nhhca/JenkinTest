//
//  ViewController.swift
//  SmartAttendence
//
//  Created by 王贤玉 on 2018/9/13.
//  Copyright © 2018年 isprint. All rights reserved.
//

import UIKit
class DeviceUtil:NSObject{
    //MARK: 获取手机UUID e.g. E621E1F8-C36C-495A-93FC-0C247A3E6E5F
    class func deviceUUID() -> String {
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString
        if deviceUUID != nil {
            return deviceUUID!
        }else{
            return getIOSGuid()
        }
    }
    
    fileprivate class func getIOSGuid() -> String{
        let setting = UserDefaults.standard
        let value = setting.object(forKey: "guid")
        if value == nil {
            let uuid = CFUUIDCreate(kCFAllocatorDefault)
            let uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid)
            let result = uuidStr! as String
            
            setting.set(result, forKey: "guid")
            setting.synchronize()
            return result
            
        }else{
            return value as! String
        }
    }
}
extension NSData
{
    func hexedString() -> String
    {
        var string = String()
        let unsafePointer = bytes.assumingMemoryBound(to: UInt8.self)
        for i in UnsafeBufferPointer<UInt8>(start:unsafePointer, count: length)
        {
            string += (NSString(format:"%02x", Int(i)) as String)
        }
        return string
    }
    func MD5() -> NSData
    {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        let unsafePointer = result.mutableBytes.assumingMemoryBound(to: UInt8.self)
        CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(unsafePointer))
        return NSData(data: result as Data)
    }
}
extension String {
    

    public var md5Str:String{
        let data = (self as NSString).data(using: String.Encoding.utf8.rawValue)! as NSData
        return data.MD5().hexedString()
    }
}

var requestUrlStr = "http://10.106.3.1"

class ViewController: UIViewController {
    var webview = UIWebView()

    
    @IBOutlet weak var reloadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.webview.frame = self.view.bounds
        self.view.addSubview(self.webview)
        
        reloadBtn.isHidden = true
        reloadBtn.layer.cornerRadius = 5
        reloadBtn.layer.masksToBounds = true
        reloadBtn.layer.borderColor = UIColor.gray.cgColor
        reloadBtn.layer.borderWidth = 0.5
        self.view.bringSubview(toFront: reloadBtn)
        self.getURL()
        
    }
    
    func getURL(){
        //let urlstr = "http://222.85.156.72:8003/gyeducation/api/member/login"
        let urlstr = "https://api.lccfd.51sprint.com/lesprint/api/student/passwordLogin"
        let url = URL.init(string: urlstr)
        var request = URLRequest.init(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Accept":"application/json",
                                       "Content-Type":"application/x-www-form-urlencoded; charset=utf-8"]
        let para =  ["loginName":"18576778673",
                     "password":"123456".md5Str,
                     "deviceType":"iOS",
                     "longitude":0.0,
                     "latitude":0.0,
                     "deviceId":DeviceUtil.deviceUUID()
            ] as [String : Any]
        var paraStr = ""
        for item in para {
            paraStr.append("\(item.key)=\(item.value)&")
        }
        
        let jsonData = paraStr.data(using: String.Encoding.utf8)
        request.httpBody = jsonData
        

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                do{
                    
                    if data == nil{
                        self.reloadBtn.isHidden = false
                        return
                    }
                    self.reloadBtn.isHidden = true
                    
                    let dic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! Dictionary<String, Any>
                    print(dic)
                    if let code = dic["status"] as? Int{
                        if code == 0{//成功
                            requestUrlStr = "http://172.16.2.200"
                            
                        }
                        else{
                            requestUrlStr = "http://10.106.3.1"
                        }
                    }else{
                        requestUrlStr = "http://10.106.3.1"
                    }
                    
                    
                }catch{
                    requestUrlStr = "http://10.106.3.1"
                }
                
                print(requestUrlStr)
                if let requestUrl = URL.init(string: requestUrlStr){
                    self.webview.loadRequest(URLRequest(url: requestUrl))
                }
            }
        
        }
        
        task.resume()
    }

   
    @IBAction func reloadAction(_ sender: Any) {
        self.getURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

