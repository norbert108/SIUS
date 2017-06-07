/*
Moduł odpowiedzialny za rzutowanie wyników requestów do obiektów swiftowych.

*/


import Foundation
import SwiftyJSON
import Alamofire

class ObjectResponse {

static func initialObjects(completion:(ClusteringResponse) -> ()) {
  
  let myId = (UIApplication.sharedApplication().delegate as! AppDelegate).id!
  print(myId)
    Alamofire.request(.GET, "https://sius.herokuapp.com/coords", parameters: ['id': myId])
      .responseJSON { response in
        
        if let json = response.result.value {
          
          let clusteringResponse = ClusteringResponse(representation: JSON(json))
          completion(clusteringResponse)
          
        }
    }
}

  static func postCurrentLocation(){
    
    let lat = String(50.06196 + (0.0...1.0).random()*0.01 - 0.005)
    let long = String(19.9378 + (0.0...1.0).random()*0.01 - 0.005)
 
    Alamofire.request(.PUT, "https://sius.herokuapp.com/update", parameters: ["lat": lat, "long":long, "id":(UIApplication.sharedApplication().delegate! as! AppDelegate).id!], encoding: .JSON).responseJSON{ response in
        print("\(response)")
      
    }
  }
  
}


class ClusteringResponse {
    
  let objects: [String: [String]]?
  
    
    init(representation: JSON) {
      
      print(representation)
      objects = representation["coords"].dictionaryObject as? [String: [String]]
      
    }
    
}


extension IntervalType {
  public func random() -> Bound {
    let range = (self.end as! Double) - (self.start as! Double)
    let randomValue = (Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * range + (self.start as! Double)
    return randomValue as! Bound
  }
}

