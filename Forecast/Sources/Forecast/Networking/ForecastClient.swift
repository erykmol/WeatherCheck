//
//  ForecastClient.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

struct ForecastClient: ForecastClientProtocol {
    private let networkManager: any NetworkingManagerProtocol
    private let api: any ForecastAPIProtocol
    private let decoder: any ResponseDecoderProtocol
    private let mapper: any ForecastMapperProtocol

    init(
        networkManager: any NetworkingManagerProtocol = NetworkingManager(
            builder: RequestBuilder(baseURL: ForecastAPI.baseURL),
            errorMessage: OpenMeteoErrorDecoder().reason(from:)
        ),
        api: any ForecastAPIProtocol = ForecastAPI(),
        decoder: any ResponseDecoderProtocol = ResponseDecoder(),
        mapper: any ForecastMapperProtocol = ForecastMapper()
    ) {
        self.networkManager = networkManager
        self.api = api
        self.decoder = decoder
        self.mapper = mapper
    }

    func forecast(latitude: Double, longitude: Double) async throws(ForecastError) -> WeatherForecast {
        let response: ForecastResponse
        do throws(NetworkError) {
            let data = try await networkManager.send(api.forecast(latitude: latitude, longitude: longitude))
            response = try await decoder.decode(ForecastResponse.self, from: data)
        } catch {
            throw ForecastError(error)
        }
        return try mapper.forecast(from: response)
    }
}
