//
//  PreviewData.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

#if DEBUG
import Foundation
import Networking

@MainActor
final class PreviewHistoryStore: SearchHistoryStoreProtocol {
    private var cities: [City]

    init(cities: [City] = []) {
        self.cities = cities
    }

    func load() -> [City] {
        cities
    }

    func record(_ city: City) {
        remove(city)
        cities.insert(city, at: 0)
    }

    func remove(_ city: City) {
        cities.removeAll { $0.id == city.id }
    }

    func removeAll() {
        cities.removeAll()
    }
}

struct PreviewNetworkMonitor: NetworkMonitorProtocol {
    func monitorConnectivity() -> AsyncStream<Connectivity> {
        AsyncStream { $0.finish() }
    }
}

struct PreviewGeocodingClient: GeocodingClientProtocol {
    enum Response {
        case matching([City])
        case failure(SearchError)
        case pending
    }

    private let response: Response

    init(response: Response = .matching(City.previewCities)) {
        self.response = response
    }

    func searchCities(named name: String) async throws(SearchError) -> [City] {
        switch response {
        case .matching(let cities):
            return cities.filter { $0.name.localizedStandardContains(name) }
        case .failure(let error):
            throw error
        case .pending:
            let (stream, continuation) = AsyncStream<Never>.makeStream()
            defer { continuation.finish() }
            for await _ in stream {}
            throw .unknown
        }
    }
}

extension CitySearchViewModel {
    static func preview(
        query: String = "",
        history: [City] = [],
        response: PreviewGeocodingClient.Response = .matching(City.previewCities)
    ) -> CitySearchViewModel {
        let viewModel = CitySearchViewModel(
            geocoding: PreviewGeocodingClient(response: response),
            validator: CityNameValidator(),
            networkMonitor: PreviewNetworkMonitor(),
            history: PreviewHistoryStore(cities: history),
            debounce: .zero,
            onCitySelected: { _ in }
        )
        viewModel.query = query
        return viewModel
    }
}

extension City {
    static let previewCities: [City] = [
        City(id: 3093133, name: "Łódź", region: "Łódzkie", country: "Polska", latitude: 51.75, longitude: 19.46667),
        City(id: 3094802, name: "Kraków", region: "Małopolskie", country: "Polska", latitude: 50.06143, longitude: 19.93658),
        City(id: 3099434, name: "Gdańsk", region: "Pomorskie", country: "Polska", latitude: 54.35205, longitude: 18.64637),
    ]

    static let previewSameNameTowns: [City] = [
        City(id: 1, name: "Nowa Wieś", region: "Mazowieckie", country: "Polska", latitude: 52.1, longitude: 20.9),
        City(id: 2, name: "Nowa Wieś", region: "Wielkopolskie", country: "Polska", latitude: 52.3, longitude: 16.9),
        City(id: 3, name: "Nowa Wieś", region: "Pomorskie", country: "Polska", latitude: 54.1, longitude: 18.3),
    ]
}
#endif
