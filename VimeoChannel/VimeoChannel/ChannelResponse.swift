//
//  ChannelResponse.swift
//  VimeoChannel
//
//  Created by Parth Adroja on 26/02/17.
//  Copyright © 2017 Parth Adroja. All rights reserved.
//

import UIKit
import ObjectMapper

class ChannelResponse: Mappable {
    var totalVideos: Int?
    var currentPage: Int?
    var videoData: [VideoData]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        totalVideos <- map["total"]
        currentPage <- map["page"]
        videoData <- map["data"]
    }
}

class VideoData: Mappable {
    var id: String?
    var name: String?
    var thumb: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["uri"]
        name <- map["name"]
        thumb <- map["pictures.sizes.3.link_with_play_button"]
    }
}
