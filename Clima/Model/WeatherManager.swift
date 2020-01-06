//
//  WeatherManager.swift
//  Clima
//
//  Created by Dylan Perry on 1/5/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(_ weatherManager: WeatherManager, error: Error)
}

struct WeatherManager {
    let apiKey = "05f9326b5f8255b73c89c3d089316b77"
    
    let url = "https://api.openweathermap.org/data/2.5/weather"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(forCity city: String){
        let finalUrl = "\(self.url)?appid=\(self.apiKey)&units=imperial&q=\(city)"
        print(finalUrl)
        performRequest(with: finalUrl)
    }
    
    func fetchWeather(forLongitude longitude: String, forLatitude latitude: String) {
        let finalUrl = "\(self.url)?appid=\(self.apiKey)&units=imperial&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: finalUrl)
    }
    
    func performRequest(with urlString: String){
        
        //1. Create URL
        if let url = URL(string: urlString) {
            // 2. Create a URL Session
            // This is effecitvely like a browser - can perform network operations
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            // Could define a function to match this
            let task = session.dataTask(with: url) { (data:Data?, urlResponse:URLResponse?, error:Error?) in                
                if error != nil {
                    print("Error ocurred!")
                    print(error!)
                    self.delegate?.didFailWithError(self, error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
                
            }
            
            //4. Start the task
            // Newly initiated tasks begin in a suspended state
            task.resume()
        }
    }
    
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherObject = WeatherModel(temperature: decodedData.main.temp, conditionId: decodedData.weather[0].id, cityName: decodedData.name)
            
            print("\(weatherObject.cityName) - \(weatherObject.temperatureString) - \(weatherObject.conditionName)")
            return weatherObject
            
        } catch {
            print(error)
            self.delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
