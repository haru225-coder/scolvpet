import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import 'miniprogram_controller.dart';

/// 尚未开放的小程序能力只读说明，不暴露内部审核或发布操作。
class MiniprogramHubPage extends StatelessWidget {
  const MiniprogramHubPage({super.key, required this.controller});

  final MiniprogramController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('小程序说明')),
      body: BearSoftBackdrop(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          children: [
            const IosModuleIntro(
              icon: CupertinoIcons.device_phone_portrait,
              title: '客户分享小程序',
              description:
                  '客户侧微信小程序工程已在仓库 apps/miniprogram 落地（浏览/预订/合同）。正式微信 AppID、登录与域名配置完成后即可提审。在此之前请继续使用公开主页获客。',
              trailing: IosStatusBadge(
                label: '工程已就绪',
                color: IosColors.systemGreen,
                icon: CupertinoIcons.checkmark_seal,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: IosBanner(
                key: Key('mp-read-only'),
                icon: CupertinoIcons.lock_shield,
                color: IosColors.systemOrange,
                text: '本页不执行微信后台审核/发布。生产上线请使用微信开发者工具打开 apps/miniprogram。',
              ),
            ),
            const SizedBox(height: 12),
            const IosGroupedSection(
              header: IosSectionHeader('现在可用'),
              children: [
                IosListTile(
                  key: Key('mp-public-site-ready'),
                  leading: IosGlyph(
                    icon: CupertinoIcons.link_circle_fill,
                    color: IosColors.systemGreen,
                  ),
                  title: '公开主页',
                  subtitle: '整理熊舍介绍、仓鼠资料和对外分享链接',
                  trailing: IosStatusBadge(
                    label: '可使用',
                    color: IosColors.systemGreen,
                  ),
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const IosGroupedSection(
              header: IosSectionHeader('开放前准备'),
              children: [
                IosListTile(
                  leading: IosGlyph(icon: CupertinoIcons.checkmark_shield),
                  title: '账号与主体校验',
                  subtitle: '确保发布主体、隐私说明和客户授权信息完整',
                  showChevron: false,
                ),
                IosListTile(
                  leading: IosGlyph(icon: CupertinoIcons.doc_checkmark),
                  title: '正式发布回执',
                  subtitle: '接入可追踪的审核结果、发布时间和版本记录',
                  showChevron: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
