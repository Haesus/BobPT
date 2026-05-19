//
//  RestaurantModel.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import Foundation
import BobPTShare

public struct Restaurant: Codable, Identifiable, Sendable {
    public var id: String {
        "\(title)-\(address)-\(date)"
    }

    public let title: String
    public let link: String
    public let category: String
    public let description: String
    public let address: String
    public let mapx: String
    public let mapy: String
    public let date: String
    public var imageString: String?

    public init(
        title: String,
        link: String,
        category: String,
        description: String,
        address: String,
        mapx: String,
        mapy: String,
        date: String = dateFormatter(),
        imageString: String? = nil
    ) {
        self.title = title
        self.link = link
        self.category = category
        self.description = description
        self.address = address
        self.mapx = mapx
        self.mapy = mapy
        self.date = date
        self.imageString = imageString
    }
}

public struct Root: Codable, Sendable {
    public var items: [Restaurant]

    public init(items: [Restaurant]) {
        self.items = items
    }
}
