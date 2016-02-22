//
//  HomeViewController.swift
//  TrailGuide
//
//  Created by Connor Silkworth on 12/6/15.
//  Copyright © 2015 csilkwor. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var startTracking: UIButton!
    
    
    override func viewDidLoad() {
       // self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)
      
        
        startTracking.backgroundColor = UIColor.redColor()
        startTracking.layer.cornerRadius = 5
        startTracking.layer.borderWidth = 1
        startTracking.layer.borderColor = UIColor.redColor().CGColor
    }
    
    
}
