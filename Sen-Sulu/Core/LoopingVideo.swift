import SwiftUI
import UIKit
import AVFoundation

/// Full-bleed looping brand film (the campaign video from sen-sulu.com, cropped to portrait).
final class VideoController {
    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?

    init(resource: String, ext: String = "mp4") {
        let url = Bundle.main.url(forResource: resource, withExtension: ext)
            ?? Bundle.main.url(forResource: resource, withExtension: ext, subdirectory: "Resources")
        if let url {
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: player, templateItem: item)
        }
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .moviePlayback)
    }

    func play() { player.play() }
    func pause() { player.pause() }
    func setMuted(_ muted: Bool) {
        if !muted { try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback) }
        player.isMuted = muted
    }
}

final class PlayerUIView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

struct LoopingVideoView: UIViewRepresentable {
    let controller: VideoController

    func makeUIView(context: Context) -> PlayerUIView {
        let v = PlayerUIView()
        v.playerLayer.player = controller.player
        v.playerLayer.videoGravity = .resizeAspectFill
        v.backgroundColor = .black
        return v
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}
