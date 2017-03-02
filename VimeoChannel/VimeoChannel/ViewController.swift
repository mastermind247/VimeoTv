//
//  ViewController.swift
//  VimeoChannel
//
//  Created by Parth Adroja on 26/02/17.
//  Copyright © 2017 Parth Adroja. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import YTVimeoExtractor
import AVKit
import AVFoundation
import Kingfisher
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    var channelResponse: ChannelResponse?
    @IBOutlet weak var IBlblChannelName: UILabel!
    @IBOutlet weak var IBcollectionView: UICollectionView!
    @IBOutlet weak var IBviewActivityHud: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityHUD()
        getListOfVideos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
    func getListOfVideos() {
        let headers: HTTPHeaders = [
            "Authorization":"Bearer a8b95bef8cf89109e1738cbfe3f749ce"
        ]
//        https://api.vimeo.com/channels/musicvideoland/videos?per_page=100
        let requestUrl = "https://api.vimeo.com/users/62781041/videos?per_page=100"
        Alamofire.request(requestUrl, headers: headers)
            .responseObject { (response: DataResponse<ChannelResponse>) in
                self.channelResponse = response.result.value
                self.hideActivityHUD()
                self.IBcollectionView.reloadData()
        }
    }
    
    func playVideoWithVideoURL(videoID: String) {
        showActivityHUD()
        YTVimeoExtractor.shared().fetchVideo(withIdentifier: videoID, withReferer: nil) { (vimeoVideo, error) in
            if error == nil {
                if let videoUrl = vimeoVideo?.highestQualityStreamURL() {
                    print(videoUrl)
                    self.hideActivityHUD()
                    let player = AVPlayer(url: videoUrl)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }
        }
    }
    
    func getVideoIDFromURL(url: String) -> String {
        let videoID = url.components(separatedBy: "/")[2]
        return videoID
    }
}

extension ViewController {
    
    func showActivityHUD() {
        IBviewActivityHud.startAnimating()
    }
    
    func hideActivityHUD() {
        if IBviewActivityHud.isAnimating {
            IBviewActivityHud.stopAnimating()
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfVideos = channelResponse?.videoData?.count {
            return numberOfVideos
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCellCollectionViewCell
        cell.IBimgThumb.image = nil
        if let safeChannelResponse = channelResponse {
            cell.IBlblTitle.text = safeChannelResponse.videoData?[indexPath.row].name
            let videoID = safeChannelResponse.videoData?[indexPath.row].id
            cell.videoID = getVideoIDFromURL(url: videoID!)
            if let imageUrl = safeChannelResponse.videoData?[indexPath.row].thumb {
                cell.IBimgThumb.kf.setImage(with: URL(string: imageUrl))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! VideoCellCollectionViewCell
        playVideoWithVideoURL(videoID: cell.videoID!)
    }
}
