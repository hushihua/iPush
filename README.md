![iPush](https://github.com/hushihua/iPush/blob/master/iPush.png)

[![CI Status](https://img.shields.io/travis/adam/iPush.svg?style=flat)](https://travis-ci.org/adam/iPush)
[![Version](https://img.shields.io/cocoapods/v/iPush.svg?style=flat)](https://cocoapods.org/pods/iPush)
[![License](https://img.shields.io/cocoapods/l/iPush.svg?style=flat)](https://cocoapods.org/pods/iPush)
[![Platform](https://img.shields.io/cocoapods/p/iPush.svg?style=flat)](https://cocoapods.org/pods/iPush)


iPush同时提供APNS和Tcp两种方式的下行推送功能，用户可以根据项目需要，选择性使用。
如果只是简单接入APNS代理推送功能，说明4中关于Tcp功能接入部分可以忽略，以下是进行接入的流程步骤:

## 一：开设帐号，生成appkey

联系工作人员，提供 boundId，测试环境apns证书，正式环境apns证书，生成 appkey。

##  二：集成SDK

### 1.CocoaPods 集成

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

### 2.主项目添加 Push Notifications 功能
在```Targets```中选择主项，点击右则 ```Signing & Capabilities```， 点击 ```+ ```，选择``` Push Notifications```选项。

## 三：代码流程接入

### 1.在 AppDelegate.m 文件中引入 iPush，并初始化（以Swift项目为例）。
```
import iPush

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //选择运行环境 
    //true:测试环境，false:正式环境(默认)
    PushApi.getInstance().DEBUG = 1    
    //初始化sdk
    PushApi.getInstance().initSdk(appKey:“你申请生成的appkey”)  
    //申请获取 deviceToken
    PushApi.getInstance().registerNotification(application: application, delegate: self)    
    //生成register_id
    PushApi.getInstance().registerUID { (response:PHResponse<String>) in                    
        print("*** [SDK] \(response.data ?? "")")
    }
    return true
}
```
#### 申请获取 deviceToken
调用  ```PushApi.getInstance().registerNotification(application: application, delegate: self)```方法用于申请获取 deviceToken值，成功后会通过以下```UNUserNotificationCenterDelegate```代理方法回调（原生deviceToken的回调代理方法）
```
//MARK:- deviceToken申请结果回调
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
}
```

#### 生成iPush平如下的唯一id (registerId)

registerId用于在iPush平台唯一标识用户设备。生成唯一id后，上传到自己的服务中，与自己的业务系统用户id进行绑定。当需要进行推送时，业务系统附带registerId，调用iPush后台接口，对特定用记的特定设置进行精准推送。

生成registerId的代码如下，可以要启动的回调方法中进行调用：
```
PushApi.getInstance().registerUID { (response:PHResponse<String>) in
    if response.isSuccess = true, let sId:String = response.data{
        print("Register_Id = \(sId)")
    }
}
```

### 2. 提交APNS返回的推送token (deviceToken)
获取到deviceToken后， 调用pushToken方法，提交pushToken到推送平台，并确保提交成功。
```
PushApi.getInstance().pushToken(data:deviceToken) { (response:PHResponse<Bool>) in
    if response.isSuccess == true{
        print("提交成功")
    }
}
```

### 3. 实现推送回调方法
当收到apns推送时，将回调```UNUserNotificationCenterDelegate```代理方法参考如下(原生apns消息回调代理方法)。如要支持ios 10以下的系统，请自行补充版本兼容代码。
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

1. 实现``` PushCmdDelegate``` 代理的方法，当接收到tcp数据时自动回调 ```onReceiveCmd```方法
```
public protocol PushCmdDelegate: NSObject {
    func onReceiveCmd(item:PHCMDItem)
}
```

PHCMDItem封装了指令中的所有可用信息，数据结构如下：
```
   public var type:Int?
   public var data:Any?
   public var title:String?
   public var content:String?
```

2. 设置tcp推送监听器

通过上面，完成实例化监听器后，通过以下代码实现监听器的绑定
```
PushApi.getInstance().delegate = self
```

## 四. 运行Demo注意事项

### 1. pod install
下载demo项目后，打开主目录，在终端中执行 pod install。

### 2. 替换你的 appkey
打开项目，打开 AppDelegate文件，在 initSDK 方法中替换成你申请成功的appkey

注意： 测试环境下的appkey，与正式环境下的appkey不相同，请分开申请。

