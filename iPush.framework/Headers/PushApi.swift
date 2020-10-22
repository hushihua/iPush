//
//  PushApi.swift
//  iPush
//
//  Created by adam on 2020/7/18.
//  Copyright © 2020 awesome. All rights reserved.
//

import UIKit

@objc public protocol PushCmdDelegate {
    func onReceiveCmd(item:PHCMDItem)
}

@objc public protocol PushNotificationDelegate {
    func didReceive(notification:UNNotification)
    func willPresent(notification:UNNotification, completionHandler:@escaping (UNNotificationPresentationOptions) -> Void)
    func didReceiveRemoteNotification(userInfo:[AnyHashable : Any])
}

@objc public class PushApi: NSObject {
    
    static let instance:PushApi = PushApi()
    @objc public static func getInstance()-> PushApi{
        return instance
    }
    
    public weak var delegate:PushCmdDelegate?
    var pushHandler:[PushNotificationDelegate] = []
    
    public var DEBUG:Int{
        get{
            return Constant.DEBUG
        }
        set{
            Constant.DEBUG = newValue
            if newValue == 1{
                Constant.BASE_URL = Constant.DEBUG_BASE_URL
            }else if newValue == 2{
                Constant.BASE_URL = Constant.DEBUG_BASE_URL2
            }else{
                Constant.BASE_URL = Constant.RELEASE_BASE_URL
            }
        }
    }
    
    public var RegisterUid:String?{
        get{
            return Constant.REGISTER_UUID
        }
    }
    
    @objc public func initSDK(appKey:String){
        Constant.APP_KEY = appKey
        Constant.InitValue()
        //PushApi对像只处理 appid == 1(推送应用)的事件
        PHSocket.getInstance().addEventHandler(handler: self, type: 1)
    }
    
    @objc public func addPushHandler(handler:PushNotificationDelegate){
        self.pushHandler.append(handler)
    }
    
    public func registerUID(handler:@escaping (PHResponse<String>) ->Void){
        let key:String = Constant.APP_KEY + "_\(Constant.DEBUG)_"
        if let uuid:String = Constant.REGISTER_UUID, let sUrl:String = Constant.SockerUrl(key:key + "IPUSH_SOCKET_URL") {
            //启动websocket连接
            PHSocket.getInstance().startConnect(url: sUrl)
            //本地生成过，取本地
            handler(PHResponse(data:uuid))
        }else{
            //本地没有生成过，生成一次
//            PushManager.getInstance().registerUUID { (response:PHResponse<String>) in
//                if response.isSuccess, let _:String = response.data{
//                    if let sUrl:String = Constant.SOCKET_URL{
//                        //启动websocket连接
//                        PHSocket.getInstance().startConnect(url: sUrl)
//                    }
//                }
//                handler(response)
//            }
            PushManager.getInstance().registerUUID(key:key) { (response:PHResponse<String>) in
                if response.isSuccess, let _:String = response.data{
                    if let sUrl:String = Constant.SockerUrl(key:key + "IPUSH_SOCKET_URL"){
                        //启动websocket连接
                        PHSocket.getInstance().startConnect(url:sUrl)
                    }
                }
                handler(response)
            }
        }
    }
    
    public func pushToken(data:Data, test: Bool? = nil, handler:@escaping (PHResponse<Bool>) ->Void){
        var type: Int?
        if let test = test {
            type = test ? 0 : 1
        }
        PushManager.getInstance().postTokenData(data: data, type: type) { (response:PHResponse<Bool>) in
            handler(response)
        }
    }
    
    @objc public func debugEnable(_ debug:Int){
        self.DEBUG = debug
    }
    
    @objc public func generateRUId(handler: @escaping (NSString?) -> Void){
        self.registerUID { (response:PHResponse<String>) in
            if response.isSuccess == true, let sValue:String = response.data{
                handler(NSString(string: sValue))
            }else{
                handler(nil)
            }
        }
    }
    
    @objc public func pushToken(data:Data, handler: @escaping (Bool) -> Void){
        self.pushToken(data: data) { (response:PHResponse<Bool>) in
            handler(response.isSuccess)
        }
    }
    
}

extension PushApi{
    
    //MARK:- 申请推送请求，获取push_token
    @objc public func registerNotification(application: UIApplication, delegate:UNUserNotificationCenterDelegate)  {
        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = delegate
            let options: UNAuthorizationOptions = [UNAuthorizationOptions.alert, .badge, .sound]
            center.requestAuthorization(options: options) { (granted: Bool, error: Error?) in
                if granted == true {
//                    print("注册消息推送成功")
                }else {
//                    print(error ?? "注册消息推送失败")
                }
            }
        }
        application.registerForRemoteNotifications()        //获取device tokens
    }
    
    //MARK:- 通知的点击事件
    public func userNotificationCenter(_ center:UNUserNotificationCenter, didReceive response:UNNotificationResponse){
        for item in self.pushHandler{
            item.didReceive(notification: response.notification)
        }
    }
    
    //MARK:- app前台收到推送
    public func userNotificationCenter(_ center:UNUserNotificationCenter, willPresent notification:UNNotification, completionHandler:@escaping (UNNotificationPresentationOptions) -> Void){
        for item in self.pushHandler{
            item.willPresent(notification:notification, completionHandler:completionHandler)
        }
    }
    
    //MARK:- 静默推送
    public func application(_ application:UIApplication, didReceiveRemoteNotification userInfo:[AnyHashable : Any]) {
        for item in self.pushHandler{
            item.didReceiveRemoteNotification(userInfo: userInfo)
        }
    }
    
}

extension PushApi: PHSocketHandler{
    
    public func onEventHandler(notification:PHCMDItem){
        self.delegate?.onReceiveCmd(item: notification)
    }
    
}
