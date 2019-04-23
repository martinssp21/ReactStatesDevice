//
//  MainViewController.swift
//  ReactStatesDevice
//
//  Created by Rodrigo Martins on 23/04/19.
//  Copyright © 2019 Rodrigo Martins. All rights reserved.
//

import UIKit
import Reachability
import CoreMotion
import CoreLocation
import Lottie

class MainViewController: UIViewController {

    @IBOutlet weak var imageViewConnectionType: UIImageView!
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var viewAnimatedMoving: LOTAnimatedControl!
    
    var locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getNetworkType(){
        if let reachability = Reachability(){ 
            reachability.whenReachable = { reachability in
                if reachability.connection == .wifi {
                    print("wifi")
                    self.imageViewConnectionType?.image = UIImage(named: "wifi")!
                    self.viewImage.layoutIfNeeded()
                } else {
                    print("4g_5g_3g")
                    self.imageViewConnectionType?.image = UIImage(named: "4g_5g_3g")!
                    self.viewImage.layoutIfNeeded()
                }
            }
            reachability.whenUnreachable = { _ in
                print("Connection OFF")
                self.imageViewConnectionType?.image = UIImage(named: "block_cancel")!
                self.viewImage.layoutIfNeeded()
            }
            
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    }

    
    func TimerBackGround(){
        DispatchQueue.global(qos: .background).async {
            let timerNetworkDetect = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startTimer), userInfo: nil, repeats: true)
            let timerMovimentDetect = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getSpeed), userInfo: nil, repeats: true)
            
            let runLoop = RunLoop.current
            
            runLoop.add(timerNetworkDetect, forMode: RunLoop.Mode.default)
            runLoop.add(timerMovimentDetect, forMode: RunLoop.Mode.default)
            
            runLoop.run()
        }
    }

    @objc func startTimer(){
        self.getNetworkType()
    }
    
    func whenMonving(){
        self.viewAnimatedMoving.animationView.setAnimation(named: "duck_walking")
        self.viewAnimatedMoving.animationView.loopAnimation = true
        self.viewAnimatedMoving.animationView.play()
        
        self.viewAnimatedMoving.animationView.stop()
    }
    
    func whenNoMonving(){
        self.viewAnimatedMoving.animationView.setAnimation(named: "duck_walking")
        self.viewAnimatedMoving.animationView.loopAnimation = false
        self.viewAnimatedMoving.animationView.play(toFrame: 0, withCompletion: nil)
    }
    
    @objc func getSpeed(){
        var speed: CLLocationSpeed = CLLocationSpeed()
        if let location = locationManager.location {
            speed = location.speed
        } else {
            speed = 0
        }
        
        print(String(format: "%.0f km/h", speed * 3.6)) //Current speed in km/h
        
        //If speed is over 10 km/h
        if(speed * 3.6 > 10 ){
            
            //Getting the accelerometer data
            if motionManager.isAccelerometerAvailable{
                let queue = OperationQueue()
                motionManager.startAccelerometerUpdates(to: queue, withHandler:
                    {data, error in
                        
                        guard let data = data else{
                            return
                        }
                        
                        print("X = \(data.acceleration.x)")
                        print("Y = \(data.acceleration.y)")
                        print("Z = \(data.acceleration.z)")
                        
                        self.whenMonving()
                        
                }
                )
            } else {
                print("Accelerometer is not available")
            }
        }else {
            self.whenNoMonving()
        }
        
    }
    
    @IBAction func buttonStartTimer(_ sender: Any) {
        self.TimerBackGround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
