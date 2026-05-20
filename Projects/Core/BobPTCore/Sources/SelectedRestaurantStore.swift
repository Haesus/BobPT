//
//  SelectedRestaurantStore.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import Foundation
import BobPTDomain

@MainActor
public final class SelectedRestaurantStore: ObservableObject {
    @Published public private(set) var restaurants: [Restaurant] = []

    private let filename = "SelectedList.plist"

    public init() {
        copyBundledFileIfNeeded()
        load()
    }

    public func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            restaurants = []
            return
        }

        if let decoded = try? PropertyListDecoder().decode([Restaurant].self, from: data) {
            restaurants = decoded
        } else {
            restaurants = []
        }
    }

    public func insert(_ restaurant: Restaurant) {
        restaurants.insert(restaurant, at: 0)
        save()
    }

    public func delete(at offsets: IndexSet) {
        for offset in offsets.sorted(by: >) {
            restaurants.remove(at: offset)
        }
        save()
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    private func copyBundledFileIfNeeded() {
        guard !FileManager.default.fileExists(atPath: fileURL.path),
              let sourceURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return
        }

        try? FileManager.default.copyItem(at: sourceURL, to: fileURL)
    }

    private func save() {
        guard let data = try? PropertyListEncoder().encode(restaurants) else {
            return
        }

        try? data.write(to: fileURL)
    }
}
