import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';

/// 系统通知通道尚未开放时的只读说明页。
class PushSettingsPage extends StatelessWidget {
  const PushSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知说明')),
      body: BearSoftBackdrop(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          children: [
            const IosModuleIntro(
              icon: CupertinoIcons.bell_circle,
              title: '重要提醒',
              description: '系统通知通道尚未开放。现阶段请在今日待办和桌面组件中查看提醒。',
              trailing: IosStatusBadge(
                label: '准备中',
                color: IosColors.systemOrange,
                icon: CupertinoIcons.clock,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: IosBanner(
                key: Key('push-read-only'),
                icon: CupertinoIcons.lock_shield,
                color: IosColors.systemOrange,
                text: '本页仅说明开放状态，不会请求系统通知权限或产生通知操作。',
              ),
            ),
            const SizedBox(height: 12),
            const IosGroupedSection(
              header: IosSectionHeader('当前提醒方式'),
              children: [
                IosListTile(
                  key: Key('push-in-app-ready'),
                  leading: IosGlyph(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    color: IosColors.systemGreen,
                  ),
                  title: '今日待办',
                  subtitle: '集中查看逾期、即将到期和当天照护任务',
                  trailing: IosStatusBadge(
                    label: '可使用',
                    color: IosColors.systemGreen,
                  ),
                  showChevron: false,
                ),
                IosListTile(
                  leading: IosGlyph(icon: CupertinoIcons.square_grid_2x2),
                  title: '桌面组件',
                  subtitle: '在主屏快速查看已经同步的待办摘要',
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const IosGroupedSection(
              header: IosSectionHeader('开放条件'),
              children: [
                IosListTile(
                  leading: IosGlyph(icon: CupertinoIcons.checkmark_shield),
                  title: '稳定送达',
                  subtitle: '完成系统通知接入、权限说明与真实设备验证',
                  showChevron: false,
                ),
                IosListTile(
                  leading: IosGlyph(icon: CupertinoIcons.arrow_2_circlepath),
                  title: '可追踪状态',
                  subtitle: '明确展示启用状态、最近送达和失败恢复结果',
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
