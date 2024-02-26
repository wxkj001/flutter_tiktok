import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tiktok/common/application.dart';
import 'package:flutter_tiktok/controller/main_page_scroll_controller.dart';
import 'package:flutter_tiktok/event/stop_play.dart';
import 'package:flutter_tiktok/model/comment_model.dart';
import 'package:flutter_tiktok/model/video_model.dart';
import 'package:flutter_tiktok/page/widget/video_bottom_bar_widget.dart';
import 'package:flutter_tiktok/page/widget/video_comment_widget.dart';
import 'package:flutter_tiktok/page/widget/video_right_bar_widget.dart';
import 'package:flutter_tiktok/page/widget/video_share_widget.dart';
import 'package:flutter_tiktok/util/screen_utils.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:ui';
import 'package:video_player/video_player.dart';

import '../../res/colors.dart';
import '../../util/screen_utils.dart';
import '../../util/screen_utils.dart';
import 'disk_widget.dart';
import 'like_gesture_widget.dart';

///视频播放列表组件
// ignore: must_be_immutable
class VideoWidgetNew extends StatefulWidget {
  VideoModel? videoModel;
  bool? showFocusButton;
  double? contentHeight;
  Function? onClickHeader;
  VideoWidgetNew({Key? key, @required this.videoModel,bool? this.showFocusButton,this.contentHeight,this.onClickHeader}) : super(key: key);

  @override
  _VideoWidgetState createState() {

    return _VideoWidgetState();
  }
}

class _VideoWidgetState extends State<VideoWidgetNew> {
// Create a [Player] to control playback.
  late final player = Player();
  late int? videoHeight;
  late int? videoWidth;
  // Create a [VideoController] to handle video output from [Player].
  late final _videoPlayerController = VideoController(player);
  // late VideoPlayerController _videoPlayerController;
  MainPageScrollController mainController = Get.find();
  bool _playing = false;
  double scale = 1;
  double videoLayoutWidth=1024;
  double videoLayoutHeight=768;

  @override
  void initState() {
    super.initState();
    print("video url:"+widget.videoModel!.videoUrl);
    player.open(Media(widget.videoModel!.videoUrl));
    _playOrPause();
    player.setPlaylistMode(PlaylistMode.loop);
    // 桌面和web下有bug第一次会无法获取到视频宽高
    player.stream.videoParams.listen((VideoParams videoParams) {
      print("_videoPlayerController.value.isInitialized:");
      print("widget.contentHeight");
      print(widget.contentHeight);
      widget.contentHeight ??= MediaQuery.of(context).size.height - 48 - MediaQueryData.fromWindow(window).padding.top;
      double rateWidthHeightContent = screenWidth(context) / widget.contentHeight!;
      double rateWidthContentVideo = screenWidth(context) / videoParams.w!;
      double heightVideoByRate = videoParams.h! * rateWidthContentVideo;
      print('视频宽:${videoParams.w} 视频高:${videoParams.h}');
      print('视频宽高比:${videoParams.w!/videoParams.h!}');
      print('屏幕宽:${screenWidth(context)}  高：${screenHeight(context)}');
      print('内容高度:${widget.contentHeight}');
      print('内容宽高比例:$rateWidthHeightContent');
      print('比例:$rateWidthContentVideo');
      print('比例换算视频高度:$heightVideoByRate');
      if(widget.contentHeight! > heightVideoByRate ){
        double rateHeightContentVideo = widget.contentHeight! /  videoParams.h!;
        setState(() {
          videoLayoutHeight = heightVideoByRate;
          videoLayoutWidth = screenWidth(context);
          scale = (widget.contentHeight! / videoLayoutHeight)!;
        });

        print('width:$videoLayoutWidth height:$videoLayoutHeight scale:$scale rate:$rateHeightContentVideo');
      }
    });

    Application.eventBus.on<StopPlayEvent>().listen((event) {
      player.pause();
    });

  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.color_1,
      body: Stack(
        children: [
          LikeGestureWidget(
            onSingleTap: () {
              _playOrPause();
            },
            child: _getVideoPlayer(scale),
          ),

          Positioned(
              right: 10,
              bottom: 110,
              child: VideoRightBarWidget(
                videoModel: widget.videoModel!,
                showFocusButton: widget.showFocusButton!,
                onClickComment: (){
                  showBottomComment();
                },
                onClickShare: (){
                  showBottomShare();
                },
                onClickHeader: (){
                  widget.onClickHeader?.call();
                },
              )),
          Positioned(
              right: 2,
              bottom: 20,
              child: VinylDisk(widget.videoModel!.videoMusicImage)),
          Positioned(
            left: 12,
            bottom: 20,
            child: VideoBottomBarWidget(widget.videoModel!),
          )


        ],
      ),
    );
  }

  void _playOrPause() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        player.play();
      } else {
        player.pause();
      }
    });
  }


  _getVideoPlayer(double scale) {
    return  Stack(
        children: [
          Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Container(
                width: videoLayoutWidth,
                height: videoLayoutHeight ,
                child: Video(controller:_videoPlayerController,controls:NoVideoControls)),
          ),
        _playing == true? Container() : _getPauseButton(),
        ],
    );
  }

  _getPauseButton() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/images/pause.webp',
              fit: BoxFit.fill,
            )
        )
    );
  }

  //展示评论
  void showBottomComment() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true, //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),),
        builder: (context){
          return VideoCommentWidget(commentList:widget.videoModel!.commentList);
        });
  }

  //展示分享布局
  void showBottomShare() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true, //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),),
        backgroundColor: ColorRes.color_1,
        builder: (context){
          return VideoShareWidget();
        });
  }



}