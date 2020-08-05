# iPush

[![CI Status](https://img.shields.io/travis/adam/LMPush.svg?style=flat)](https://travis-ci.org/adam/LMPush)
[![Version](https://img.shields.io/cocoapods/v/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)
[![License](https://img.shields.io/cocoapods/l/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)
[![Platform](https://img.shields.io/cocoapods/p/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)


iPush同时提供APNS和Tcp两种方式的下行推送功能，用户可以根据项目需要，选择性使用。
如果只是简单接入APNS代理推送功能，说明4中关于Tcp功能接入部分可以忽略，以下是进行接入的流程步骤

## 一：联系客服，开设帐号，生成appkey

##  二：集成SDK

### CocoaPods 集成

支持 CocoaPods 方式和手动集成两种方式。我们推荐使用 CocoaPods 方式集成，以便随时更新至最新版本。

在 Podfile 中增加以下内容。
```
 pod 'iPush'
```
执行以下命令，安装 LMPush。
```
 pod install
```
如果无法安装 SDK 最新版本，执行以下命令更新本地的 CocoaPods 仓库列表。
```
 pod repo update
```

## 三：在代码处理

### 1.在 AppDelegate.m 文件中引入 iPush，并初始化（以Swift项目为例）。
```
import iPush

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    PushApi.getInstance().DEBUG = true                                                      //true:连接测试服务
    PushApi.getInstance().initSdk(appKey:"4d3967b5d1c4b7a3cad814af")                        //初始化sdk
    PushApi.getInstance().registerNotification(application: application, delegate: self)    //申请获取 deviceToken
    PushApi.getInstance().registerUID { (response:PHResponse<String>) in                    //生成register_id
        print("*** [SDK] \(response.data ?? "")")
    }
    return true
}
```

调用  ```PushApi.getInstance().registerNotification(application: application, delegate: self)```方法用于申请获取 deviceToken值，成功后会通过以下```UNUserNotificationCenterDelegate```代理方法回调
```
//MARK:- deviceToken申请结果回调
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
}
```
### 2. 提交APNS返回的推送token
在合适的位置进行推送token的提交，并确保提交成功。
```
PushApi.getInstance().pushToken(data:deviceToken) { (response:PHResponse<Bool>) in
}
```

### 3. 实现推送回调方法
当收到apns推送时，将回调```UNUserNotificationCenterDelegate```代理方法如下，与原生开发一致
```
@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
    
}

@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
    
}

func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
}

```

### 4. 设置Tcp推送监听器

1. 实现 PushCmdDelegate 中的方法，当接收到tcp数据时回调 ```onReceiveCmd```方法
```
public protocol PushCmdDelegate: NSObject {
    func onReceiveCmd(item:PHCMDItem)
}
```

PHCMDItem的数据结构如下：
```
   public var type:Int?
   public var data:Any?
   public var title:String?
   public var content:String?
```

2. 设置tcp推送监听器
通过上面，完成实例化监听器后，通过以下代友实现监听器的绑定
```
PushApi.getInstance().delegate = self
```
