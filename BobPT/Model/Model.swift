//
//  RestaurantModel.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import Foundation

struct Restaurant: Codable, Identifiable {
    var id: String {
        "\(title)-\(address)-\(date)"
    }

    let title: String
    let link: String
    let category: String
    let description: String
    let address: String
    let mapx: String
    let mapy: String
    let date: String
    var imageString: String?

    init(
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

struct Root: Codable {
    var items: [Restaurant]
}
