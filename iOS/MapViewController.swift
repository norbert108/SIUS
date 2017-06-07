/*

Kontroler widoku miejsc na mapie.

*/

import UIKit

class MapViewController: UIViewController {
  
    @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  let locationManager = CLLocationManager()
  let dataProvider = GoogleDataProvider()
  let searchRadius: Double = 1000
    
    @IBAction func refreshButtonTapped(sender: AnyObject){
        fetchNearbyPlaces(mapView.camera.target)
        
    }
    
    
    @IBAction func closeVC(sender: AnyObject){
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    
    @IBOutlet weak var myBarButtonRefresh: UIBarButtonItem!
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
  
  
  
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    mapView.clear()
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      for place: GooglePlace in places {
        let marker = PlaceMarker(place: place)
        marker.map = self.mapView
      }
    }
  }
}

// MARK: - TypesTableViewControllerDelegate
extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
    fetchNearbyPlaces(mapView.camera.target)
  }
}
  extension MapViewController: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
      if status == .AuthorizedWhenInUse {
        
        locationManager.startUpdatingLocation()
        
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
      }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.first {
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()
        fetchNearbyPlaces(location.coordinate)

      }
      
    }
}
    extension MapViewController: GMSMapViewDelegate {
      func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        
        if (gesture) {
          mapCenterPinImage.fadeIn(0.25)
          mapView.selectedMarker = nil
        }
      }
      
      func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        let placeMarker = marker as! PlaceMarker
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
          infoView.nameLabel.text = placeMarker.place.name
          
          if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
          } else {
            infoView.placePhoto.image = UIImage(named: "generic")
          }
          
          return infoView
        } else {
          return nil
        }
      }
      
      func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
      }
      
      func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
      }

}
