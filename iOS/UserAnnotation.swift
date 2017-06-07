/*
Ta klasa przedstawia uzytkownika na mapie

*/

import MapKit
import Foundation


class UserAnnotation: MKPointAnnotation{
  
  let name: String
  var currentCoordinate: CLLocationCoordinate2D
  var lastCoordinate: CLLocationCoordinate2D?
  
  
  init(name:String, coordinate: CLLocationCoordinate2D){
    self.name = name
    self.currentCoordinate = coordinate
    super.init()
    self.coordinate = coordinate
    
  }
  
}
