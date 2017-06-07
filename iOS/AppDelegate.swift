/*

Pierwszy plik uruchamiany podczas budowania aplikacji. W metodzie didFinishLaunchingWithOptions odbywa sie zazwyczaj wstepna konfiguracja.
Tutaj inicjalizujemy użytkownika na serwerze lub pobieramy jego id z dysku.

*/

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var id: Int? = 98;
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    GMSServices.provideAPIKey("AIzaSyD4eBGdDE4aAO_irT1uOpoWQz6zKvU6Gu4")

   let userDefaults = NSUserDefaults.standardUserDefaults()
    
    if let highscore = userDefaults.valueForKey("id"){
      self.id = highscore as? Int
    }
    else {
  
       Alamofire.request(.GET, "https://sius.herokuapp.com/initialise")
       .responseJSON { response in
         
         if let json = response.result.value {
           let id = JSON(json)["id"].stringValue
           self.id = id
           userDefaults.setValue(id, forKey: "id")
           userDefaults.synchronize()
           ObjectResponse.postCurrentLocation()
           
         }
    return true
    }

  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
//}

