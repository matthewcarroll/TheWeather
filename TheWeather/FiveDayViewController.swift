//
//  FiveDayViewController.swift
//  TabbediOS
//
//  Created by Matthew Carroll on 11/16/16.
//  Copyright © 2016 Third Cup lc. All rights reserved.
//

import UIKit


final class FiveDayViewController: UITableViewController {

    private var dataSource = FiveDayDataSource<WeatherForecast>(tableView: UITableView())
    private var todaysForecast: WeatherForecast?

    var didSelect: (WeatherForecast) -> () = { _ in }
    var didTapHeader: (WeatherForecast) -> () = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = FiveDayDataSource(tableView: tableView)
        tableView.dataSource = dataSource
        let nib = UINib(nibName: "ForecastViewHeader", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! UIView
        tableView.tableHeaderView = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.refreshData(fetch: fetchWeather)
        navigationController?.isNavigationBarHidden = true
    }
    
    func fetchWeather(completion: @escaping ([WeatherForecast]?) -> ()) {
        var success5Day = false
        var successCurrent = false
        let client = HTTPClient()
        let group = DispatchGroup()
        group.enter()
        client.load(resource: WeatherForecast.currentConditions) { forecast in
            mainQueue.add {
                self.configureView(forecast: forecast ?? WeatherForecast(d: [:]))
            }
            successCurrent = forecast != nil
            group.leave()
        }
        group.enter()
        client.load(resource: WeatherForecast.fiveDayForecast) { forecasts in
            completion(forecasts?.dropFirst)
            self.todaysForecast = forecasts?.first
            success5Day = forecasts?.count == 5
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            self.showMessage(successCurrent: successCurrent, success5Day: success5Day)
        }
    }
    
    private func showMessage(successCurrent: Bool, success5Day: Bool) {
        guard !successCurrent || !success5Day else { return }
        var key = !successCurrent ? "error.message.currentConditions" : "error.message.5day"
        key = (!success5Day && !successCurrent) ? "error.message" : key
        UIAlertController.show(from: self, title: NSLocalizedString(key: key), ok: nil)
    }

    private func configureView(forecast: WeatherForecast) {
        let view = tableView.tableHeaderView as! WeatherForecastView
        let forecastModel = ForecastViewModel(forecast: forecast)
        view.monthDay?.text = forecastModel.monthDay
        view.hiTemp?.text = forecastModel.hiTemp
        view.lowTemp?.text = forecastModel.lowTemp
        view.icon?.image = forecastModel.icon
        view.phrase?.text = forecastModel.phrase
        view.recognizer?.addTarget(self, action: #selector(tappedHeaderView))
    }
    
    @objc private func tappedHeaderView() {
        todaysForecast.map { didTapHeader($0) }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(dataSource.objects[indexPath.row])
    }
}


private final class FiveDayDataSource<T>: NSObject, UITableViewDataSource {
    
    private let tableView: UITableView
    fileprivate var objects = [T]()
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func refreshData(fetch: (@escaping ([T]?) -> ()) -> ()) {
        fetch { (objects: [T]?) in
            objects.map { self.objects = $0 }
            mainQueue.addOperation { self.tableView.reloadData() }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FiveDayCell
        let forecast = objects[indexPath.row] as! WeatherForecast
        let forecastModel = ForecastViewModel(forecast: forecast)
        cell.icon?.image = forecastModel.icon
        cell.weekDay?.text = forecastModel.weekDay
        cell.phrase?.text = forecastModel.phrase
        cell.hiTemp?.text = forecastModel.hiTemp
        cell.loTemp?.text = forecastModel.lowTemp
        return cell
    }
}
