# iPush

[code-past]:https://github.com/hushihua/iPush/blob/master/iPush.png

[![CI Status](https://img.shields.io/travis/adam/LMPush.svg?style=flat)](https://travis-ci.org/adam/LMPush)
[![Version](https://img.shields.io/cocoapods/v/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)
[![License](https://img.shields.io/cocoapods/l/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)
[![Platform](https://img.shields.io/cocoapods/p/LMPush.svg?style=flat)](https://cocoapods.org/pods/LMPush)


iPush同时提供APNS和Tcp两种方式的下行推送功能，用户可以根据项目需要，选择性使用。
如果只是简单接入APNS代理推送功能，说明4中关于Tcp功能接入部分可以忽略，以下是进行接入的流程步骤:

## 一：开设帐号，生成appkey

联系工作人员，提供 boundId, 测试环境apns证书，正式环境apns证书，生成 appkey。

##  二：集成SDK

### CocoaPods 集成

iPush支持 CocoaPods 方式和手动集成两种方式。我们推荐使用 CocoaPods 方式集成，以便随时更新至最新版本。

在 Podfile 中增加以下内容。
```
 pod 'iPush'
```
执行以下命令，安装 iPush。
```
 pod install
```
如果无法安装 SDK 最新版本，执行以下命令更新本地的 CocoaPods 仓库列表。
```
 pod repo update
```

## 三：代码流程接入

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
### 2. 提交APNS返回的推送token (deviceToken)
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

当需要用到Tcp通道进行推送时，要接入iPush tcp 推送流程，接入顺序如下：

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

### 5. 生成iPush平如下的唯一id (registerId)

registerId用于在iPush平台唯一标识用户设备。生成唯一id后，上传到自己的服务中，与自己的业务系统用户id进行绑定。当需要进行推送时，业务系统附带registerId，调用iPush后台接口，对特定用记的特定设置进行精准推送。

生成registerId的代码如下，可以要启动的回调方法中进行调用：
```
PushApi.getInstance().registerUID { (response:PHResponse<String>) in
    if response.isSuccess = true, let sId:String = response.data{
        print("Register_Id = \(String)")
    }
}

```

