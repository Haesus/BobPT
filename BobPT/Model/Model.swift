//
//  RestaurantModel.swift
//  BobPTProjectSearchApi
//
//  Created by 강희창 on 4/6/24.
//

import Foundation

struct Restaurant: Codable{
    let title: String
    let link: String
    let category: String
    let description: String
    let address: String
    let mapx: String
    let mapy: String
    
//    enum CodingKeys: String, CodingKey {
//            case title, link, category, description, telephone, mapx, mapy
//        }

}

struct Root: Codable {
    let items: [Restaurant]
}
