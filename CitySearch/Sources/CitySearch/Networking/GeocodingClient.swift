//
//  GeocodingClient.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

struct GeocodingClient: GeocodingClientProtocol {
    private let networkManager: any NetworkingManagerProtocol
    private let decoder: any ResponseDecoderProtocol

    init(
        networkManager: any NetworkingManagerProtocol = NetworkingManager(
            builder: RequestBuilder(baseURL: GeocodingAPI.baseURL),
            errorMessage: OpenMeteoErrorDecoder().reason(from:)
        ),
        decoder: any ResponseDecoderProtocol
    ) {
        self.networkManager = networkManager
        self.decoder = decoder
    }

    func searchCities(named name: String) async throws(SearchError) -> [City] {
        do throws(NetworkError) {
            let data = try await networkManager.send(GeocodingAPI.search(name: name))
            let response = try await decoder.decode(GeocodingResponse.self, from: data)
            return (response.results ?? []).map { City($0) }
        } catch {
            throw SearchError(error)
        }
    }
}
