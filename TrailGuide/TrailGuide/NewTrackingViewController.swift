//
//  NewTrackingViewController.swift
//  TrailGuide
//
//  Created by Labuser on 11/16/15.
//  Copyright (c) 2015 csilkwor. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit

let DetailSegueName = "TrackDetails"

class NewTrackingViewController: UIViewController {
    
   // var managedObjectContext: NSManagedObjectContext?
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var track: Track!
    var seconds = 0.0
    var distance = 0.0
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // Boolean to determine whether the timer is currently paused. Used to implement pause/resume functionality
    var isPaused = true
    
    var locs = [CLLocation]()
    
    lazy var locationManager: CLLocationManager = {
        var locationManager2 = CLLocationManager()
        locationManager2.delegate = self
        locationManager2.desiredAccuracy = kCLLocationAccuracyBest
        locationManager2.activityType = .Fitness
       // locationManager2.distanceFilter = .0
        return locationManager2
    }()
    //An array containing all location objects
    lazy var locations = [CLLocation]()
    // keeps track of the seconds
    lazy var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(isPaused){
            startButton.backgroundColor = UIColor.greenColor()
            timeLabel.text = "0:00:00"
            distanceLabel.text = "0.00"
            speedLabel.text = "0.00"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        dateLabel.text = dateFormatter.stringFromDate(NSDate())
        
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        stopButton.backgroundColor = UIColor.redColor()
        stopButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        locationManager.requestAlwaysAuthorization()
        resetInitialView()
    }
    
    func resetInitialView(){
        isPaused = true
        seconds = 0.0
        distance = 0.0

        timer.invalidate()
        locations.removeAll(keepCapacity: false)
        timeLabel.text = "0.0"
        distanceLabel.text = "0.0"
        speedLabel.text = "0.0"
        
        timeLabel.hidden = true
        distanceLabel.hidden = true
        speedLabel.hidden = true
        
        startButton.hidden = false
        stopButton.hidden = false
        startButton.setTitle("Start", forState: .Normal)
        
        startButton.backgroundColor = UIColor.greenColor()
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        stopButton.backgroundColor = UIColor.redColor()
        stopButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        locations.removeAll()
        
        //Remove the tracking line
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        locationManager.requestAlwaysAuthorization()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func startPressed(sender: AnyObject) {
        
        if (isPaused) {
            timeLabel.hidden = false
            distanceLabel.hidden = false
            speedLabel.hidden = false
            startUpdatingLocation()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "secondsCounter:", userInfo: nil, repeats: true)
            
            startButton.setTitle("Pause", forState: .Normal)
            startButton.backgroundColor = UIColor.orangeColor()
            
            isPaused = false
            
        } else {
            timer.invalidate()
           // stopUpdatingLocation()
            
            startButton.setTitle("Resume", forState: .Normal)
            startButton.backgroundColor = UIColor.greenColor()
            isPaused = true
        }

        
    }
    
    @IBAction func stopPressed(sender: AnyObject) {
        
        //timer.invalidate()
        //stopUpdatingLocation()
        
        let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Erase")
        
        actionSheet.actionSheetStyle = .Default
        
        actionSheet.showInView(view)
        
    }
    
    func convertSecondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
    }
    
    func convertMetersToMiles() -> Double {
        return (distance / 1609.344)
    }
    
    func findSpeed() -> Double {
       return convertMetersToMiles() / (seconds / 3600)
    }
    
    func secondsCounter(timer: NSTimer) {
        seconds++
        
        //Print updated time label in the format H:MM:SS
        let (h,m,s) = convertSecondsToHoursMinutesSeconds()
        if(m < 10 && s < 10){
            timeLabel.text = "\(h):0\(m):0\(s)"
        } else if(m < 10 && s >= 10){
            timeLabel.text = "\(h):0\(m):\(s)"
        } else if(m >= 10 && s < 10){
            timeLabel.text = "\(h):\(m):0\(s)"
        } else {
            timeLabel.text = "\(h):\(m):\(s)"
        }
        
        //Print updated distance label in miles with an accurracy of 2 decimal places
        distanceLabel.text = String(format: "%.2f", convertMetersToMiles())

        
        //Print speed in miles per hour
        speedLabel.text = String(format: "%.2f", findSpeed())
        
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func saveTrack() {
      
        let savedTrack = NSEntityDescription.insertNewObjectForEntityForName("Track", inManagedObjectContext: self.managedContext) as! Track
        savedTrack.distance = distance
        savedTrack.duration = seconds
        savedTrack.timestamp = NSDate()
        
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
                inManagedObjectContext: self.managedContext) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedTrack.locations = NSOrderedSet(array: savedLocations)
        
        track = savedTrack
        
        do {
            try managedContext.save()
        }
        catch {
            print("Track not saved")
        }
    }
    
   
    func mapRegion() -> MKCoordinateRegion {
        let initialLocation = track.locations.firstObject as! Location
        
        var lat1 = initialLocation.latitude.doubleValue
        var long1 = initialLocation.longitude.doubleValue
        var lat2 = lat1
        var long2 = long1
        
        let locations = track.locations.array as! [Location]
        
        for location in locations {
            lat1 = min(lat1, location.latitude.doubleValue)
            long1 = min(long1, location.longitude.doubleValue)
            lat2 = max(lat2, location.latitude.doubleValue)
            long2 = max(long2, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (lat1 + lat2) / 2, longitude: (long1 + long2) / 2), span: MKCoordinateSpan(latitudeDelta: (lat2 - lat1) * 1.1, longitudeDelta: (long2 - long1) * 1.1))
    }
    
    
}

extension NewTrackingViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if(buttonIndex == 1){
            saveTrack()
            stopUpdatingLocation()
            timer.invalidate()
            mapView.region = mapRegion()
            startButton.hidden = true
            stopButton.hidden = true
            locations.removeAll(keepCapacity: false)
          
            
        }else if buttonIndex == 2 {
            navigationController?.popToRootViewControllerAnimated(true)
            resetInitialView()
            locations.removeAll(keepCapacity: false)
            
        }
        
    }
}

extension NewTrackingViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        mapView.showsUserLocation = true
        
        for location in locations {
          
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                if self.locations.count > 0 {
                    if(!isPaused){
                    distance += location.distanceFromLocation(self.locations.last!)
                    }
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    if(!isPaused){
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                    }
                }
                self.locations.append(location)
                locs.append(location)
            }
        }
    }
}

extension NewTrackingViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        if(!isPaused){
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.redColor()
        renderer.lineWidth = 4
        return renderer
        } else {
            return nil
        }
    }
}
