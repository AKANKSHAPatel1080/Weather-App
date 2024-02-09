//
//  ViewController.swift
//  Weather App
//
//  Created by Akanksha Patel on 13/01/24.
//

import UIKit

class ViewController: UIViewController {

    
    let apiKey = "9dd144c6c5da997fcac417791f5d2880"
    
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    let locationTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Enter location"
            textField.textAlignment = .center
            textField.tintColor = .black
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()

        let getWeatherButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Get Weather", for: .normal)
            button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
            button.tintColor = .white
            button.layer.cornerRadius = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()

        let weatherLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black

            setupUI()
            getWeatherButton.addTarget(self, action: #selector(getWeather), for: .touchUpInside)
        }

        func setupUI() {
            view.addSubview(locationTextField)
            view.addSubview(getWeatherButton)
            view.addSubview(weatherLabel)

            NSLayoutConstraint.activate([
                locationTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                locationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                locationTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                locationTextField.heightAnchor.constraint(equalToConstant: 40),

                getWeatherButton.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 20),
                getWeatherButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                getWeatherButton.widthAnchor.constraint(equalToConstant: 150),
                getWeatherButton.heightAnchor.constraint(equalToConstant: 40),

                weatherLabel.topAnchor.constraint(equalTo: getWeatherButton.bottomAnchor, constant: 20),
                weatherLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                weatherLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
        }

        @objc func getWeather() {
            guard let location = locationTextField.text, !location.isEmpty else {
                showAlert(message: "Please enter a location")
                return
            }

            guard let url = URL(string: "\(baseURL)?q=\(location)&appid=\(apiKey)") else {
                showAlert(message: "Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.showAlert(message: "Error: \(error.localizedDescription)")
                } else if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                        if let weather = json?["weather"] as? [[String: Any]], let main = json?["main"] as? [String: Any] {
                            if let description = weather.first?["description"] as? String, let temperature = main["temp"] as? Double {
                                DispatchQueue.main.async {
                                    self.weatherLabel.text = "Weather: \(description)\nTemperature: \(temperature)°C"
                                    self.weatherLabel.textColor = .red // Set red color for weather data
                                }
                            } else {
                                self.showAlert(message: "Unable to parse weather data")
                            }
                        } else {
                            self.showAlert(message: "Invalid response format")
                        }
                    } catch {
                        self.showAlert(message: "Error parsing JSON")
                    }
                }
            }.resume()
        }

        func showAlert(message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
