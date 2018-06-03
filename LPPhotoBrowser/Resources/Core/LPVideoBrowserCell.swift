//
//  LPVideoBrowserCell.swift
//  LPPhotoBrowser
//
//  Created by 李鹏 on 2018/6/1.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPVideoBrowserCell: LPBaseBrowserCell {
    //@class AVPlayer, AVPlayerLayer;
    //@interface TZVideoPreviewCell : TZAssetPreviewCell
    //@property (strong, nonatomic) AVPlayer *player;
    //@property (strong, nonatomic) AVPlayerLayer *playerLayer;
    //@property (strong, nonatomic) UIButton *playButton;
    //@property (strong, nonatomic) UIImage *cover;
    //- (void)pausePlayerAndShowNaviBar;
    //@end

}
//@implementation TZVideoPreviewCell
//
//- (void)configSubviews {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:UIApplicationWillResignActiveNotification object:nil];
//}
//
//- (void)configPlayButton {
//    if (_playButton) {
//        [_playButton removeFromSuperview];
//    }
//    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
//    [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlayHL"] forState:UIControlStateHighlighted];
//    [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_playButton];
//}
//
//- (void)setModel:(TZAssetModel *)model {
//    [super setModel:model];
//    [self configMoviePlayer];
//}
//
//- (void)configMoviePlayer {
//    if (_player) {
//        [_playerLayer removeFromSuperlayer];
//        _playerLayer = nil;
//        [_player pause];
//        _player = nil;
//    }
//
//    [[TZImageManager manager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//        self->_cover = photo;
//    }];
//    [[TZImageManager manager] getVideoWithAsset:self.model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self->_player = [AVPlayer playerWithPlayerItem:playerItem];
//            self->_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self->_player];
//            self->_playerLayer.backgroundColor = [UIColor blackColor].CGColor;
//            self->_playerLayer.frame = self.bounds;
//            [self.layer addSublayer:self->_playerLayer];
//            [self configPlayButton];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self->_player.currentItem];
//        });
//    }];
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    _playerLayer.frame = self.bounds;
//    _playButton.frame = CGRectMake(0, 64, self.tz_width, self.tz_height - 64 - 44);
//}
//
//- (void)photoPreviewCollectionViewDidScroll {
//    [self pausePlayerAndShowNaviBar];
//}
//
//#pragma mark - Click Event
//
//- (void)playButtonClick {
//    CMTime currentTime = _player.currentItem.currentTime;
//    CMTime durationTime = _player.currentItem.duration;
//    if (_player.rate == 0.0f) {
//        if (currentTime.value == durationTime.value) [_player.currentItem seekToTime:CMTimeMake(0, 1)];
//        [_player play];
//        [_playButton setImage:nil forState:UIControlStateNormal];
//        if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
//        if (self.singleTapGestureBlock) {
//            self.singleTapGestureBlock();
//        }
//    } else {
//        [self pausePlayerAndShowNaviBar];
//    }
//}
//
//- (void)pausePlayerAndShowNaviBar {
//    if (_player.rate != 0.0) {
//        [_player pause];
//        [_playButton setImage:[UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay"] forState:UIControlStateNormal];
//        if (self.singleTapGestureBlock) {
//            self.singleTapGestureBlock();
//        }
//    }
//}
//
//@end
