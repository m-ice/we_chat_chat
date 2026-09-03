import '../../domain/entities/guide_article.dart';
import '../../domain/entities/user.dart';

abstract final class GuideArticleProvider {
  static List<GuideArticle> tutorials(User user) => _articles(user, true);
  static List<GuideArticle> guides(User user) => _articles(user, false);

  static List<GuideArticle> _articles(User user, bool tutorial) {
    final activity = user.teamPost?.activity ?? '';
    if (activity.contains('骑行')) {
      return tutorial
          ? const [
              GuideArticle(
                title: '新手骑行入门：车辆与护具怎么选',
                summary: '车架尺寸、头盔手套、夜骑反光装备一次讲清',
                body:
                    '第一次参与骑行组队，建议先确认车辆是否适合自己身高，头盔必须佩戴。城市休闲骑选择平把公路车或山地车均可，速度控制在 20km/h 以内更安全。组队前检查胎压、刹车，携带补胎工具和饮水，跟队时保持 1-2 米车距，转弯提前打手势。',
                readMinutes: 5,
              ),
              GuideArticle(
                title: '城市休闲骑路线规划技巧',
                summary: '避开高峰、设置补给点，让队伍骑得更轻松',
                body: '组队路线优先选择绿道、滨水步道等机动车少的区域。建议每 8-10 公里设置休息点，夏季避开正午高温时段。',
                readMinutes: 4,
              ),
            ]
          : const [
              GuideArticle(
                title: '骑行组队安全守则',
                summary: '跟队礼仪、超车与突发状况处理',
                body:
                    '跟队时不要并排占用整条车道；超车需提前示意。如遇爆胎或体力不支，及时在群内告知并靠边等待。雷雨天气建议改期，夜间骑行必须配备前后车灯。',
                readMinutes: 3,
              ),
            ];
    }
    if (activity.contains('露营')) {
      return tutorial
          ? const [
              GuideArticle(
                title: '露营装备清单（新手版）',
                summary: '帐篷、睡袋、炊具、照明，按季节增减',
                body: '基础装备：帐篷、防潮垫、睡袋、头灯、炉具、套锅、饮用水。组队可分工携带公共装备，出发前在群里核对清单。',
                readMinutes: 6,
              ),
            ]
          : const [
              GuideArticle(
                title: '野外用火与食品安全',
                summary: '禁火区遵守规定，食材分装保鲜',
                body: '许多营地禁止明火，请提前确认是否可使用卡式炉。食材建议提前清洗分装，肉类需冷链或当天食用。垃圾全部带走。',
                readMinutes: 3,
              ),
            ];
    }
    if (activity.contains('吃饭') ||
        activity.contains('美食') ||
        activity.contains('火锅')) {
      return tutorial
          ? const [
              GuideArticle(
                title: '组队聚餐怎么点菜不踩雷',
                summary: '先问忌口，荤素搭配，控制预算',
                body: '组队吃饭前在群内收集忌口与辣度偏好。点菜遵循冷热荤素搭配，预算提前说好 AA 还是轮流请客。',
                readMinutes: 4,
              ),
            ]
          : const [
              GuideArticle(
                title: '探店组队找店技巧',
                summary: '看评价、预约、错峰到店',
                body: '优先选择支持多人拼桌的餐厅，热门店提前电话预约。组队可共享探店笔记，标记停车与地铁出口。',
                readMinutes: 3,
              ),
            ];
    }
    return tutorial
        ? const [
            GuideArticle(
              title: '年轻人组队平台使用指南',
              summary: '发布活动、筛选队友、线下见面三步走',
              body: '在微撩组队完善个人资料与兴趣标签，浏览首页组队帖选择合适活动。申请加入后通过聊天沟通细节，确认时间地点与费用。',
              readMinutes: 5,
            ),
          ]
        : const [
            GuideArticle(
              title: '线下组队安全提示',
              summary: '核实信息、告知亲友、保留沟通记录',
              body: '见面前后在群内确认身份与行程。勿轻易转账或透露隐私信息。如遇不适可随时退出活动。',
              readMinutes: 3,
            ),
          ];
  }
}
