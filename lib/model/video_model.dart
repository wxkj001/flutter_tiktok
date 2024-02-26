
import 'comment_model.dart';
import 'user_model.dart';


///视频的数据模型
class VideoModel{
  late String title;//视频标题
  late String author;//视频作者
  late String authorHeaderUrl;//作者头像
  late String videoUrl;//视频地址
  late bool favorite;//是否收藏
  late bool like;//是否喜欢
  late String likeNumber;//喜欢的数量
  late List<CommentModel> commentList;//评论列表数据
  late String shareNumber;//分享的数量
  late String videoMusicName;//视频音乐的名称
  late String videoMusicImage;//视频音乐的图片
  late UserModel user;

}