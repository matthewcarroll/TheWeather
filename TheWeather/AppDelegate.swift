//
//  AppDelegate.swift
//  TheWeather
//
//  Created by Matthew Carroll on 12/2/16.
//  Copyright © 2016 Third Cup lc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var segues: Segues?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window.map { segues = Segues(window: $0) }
        return true
    }
}


private final class Segues {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navigationController: UINavigationController
    
    init(window: UIWindow) {
        navigationController = window.rootViewController as! UINavigationController
        let fiveDayController = navigationController.viewControllers[0] as! FiveDayViewController
        fiveDayController.didSelect = showDetailView
        fiveDayController.didTapHeader = showDetailView
    }
    
    private func showDetailView(forecast: WeatherForecast) {
        let detail = DailyForecastViewController(forecast: forecast)
        navigationController.pushViewController(detail, animated: true)
        navigationController.isNavigationBarHidden = false
    }
}
