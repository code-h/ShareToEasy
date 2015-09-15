//
//  ShareBrain.swift
//  share-to
//
//  Created by Marquis on 15/9/10.
//  Copyright (c) 2015年 Marquis. All rights reserved.
//

import Foundation
import CoreData

class ShareBrain{
    
    var ShareParames = NSMutableDictionary()
    
    func getShareParames(Text: String, Images: String, Url: String, Title: String, Type: String){
        var types: (SSDKContentType) = SSDKContentType.Text
        switch Type {
        case "text": types = SSDKContentType.Text
        case "auto": types = SSDKContentType.Auto
        case "image": types = SSDKContentType.Image
        default:
            break
        }
        ShareParames.SSDKSetupShareParamsByText(Text,
            images : UIImage(named: Images),
            url : NSURL(string:Url),
            title : Title,
            type : types)
        
    }
    
    func shareWeiboBrain(Text: String, Images: String, Url: String, Title: String, Type: String, HSData: HistoryShareData, managedObjectContext: NSManagedObjectContext){
            self.getShareParames(Text, Images: Images, Url: Url, Title: Title, Type: Type)
        ShareSDK.share(SSDKPlatformType.TypeSinaWeibo, parameters: ShareParames) { (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
            self.isSuccess(state, Text: Text, Platfort: "weibo", error: error, HSData: HSData, managedObjectContext: managedObjectContext)
        }
        
    }
    
    func shareWechatTimeline(Text: String, Images: String, Url: String, Title: String, Type: String, HSData: HistoryShareData, managedObjectContext: NSManagedObjectContext){
        self.getShareParames(Text, Images: Images, Url: Url, Title: Title, Type: Type)
        ShareSDK.share(SSDKPlatformType.SubTypeWechatTimeline, parameters: ShareParames)  { (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
            self.isSuccess(state, Text: Text, Platfort: "wechat", error: error, HSData: HSData, managedObjectContext: managedObjectContext)
        }
    }
    
    func isSuccess(state: SSDKResponseState, Text: String, Platfort: String, error: NSError!, HSData: HistoryShareData, managedObjectContext: NSManagedObjectContext){
        switch state {
        case SSDKResponseState.Success: println("分享成功")
        let alert = UIAlertView(title: "分享成功", message: "分享成功", delegate: self, cancelButtonTitle: "取消")
        alert.show()
        //对数据持久化
        HSData.status = "success"
        HSData.platform = Platfort
        HSData.text = Text
        HSData.createdAt = NSDate()
        var error: NSError? = nil
        if !managedObjectContext.save(&error) {
            println("不能保存")
            }
        case SSDKResponseState.Fail: println("分享失败,错误描述:\(error)")
            HSData.status = "fail"
            HSData.platform = Platfort
            HSData.text = Text
            HSData.createdAt = NSDate()
        var error: NSError? = nil
        if !managedObjectContext.save(&error) {
                println("不能保存")
            }
        case SSDKResponseState.Cancel: println("分享取消")
        default:
            break
        }
    }
    
}
