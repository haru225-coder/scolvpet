part of 'i2_hamsters.dart';

class LitterListPage extends StatelessWidget {
  const LitterListPage({super.key, required this.controller});

  final I2Controller controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('窝次')),
      body: Column(
        children: [
          I2OfflineBanner(
            offline: controller.offline,
            lastSyncLabel: controller.lastSyncLabel,
          ),
          Expanded(
            child: I2AsyncStateView<I2Snapshot>(
              state: controller.snapshotState,
              onRetry: controller.retry,
              builder: (snapshot) => snapshot.litters.isEmpty
                  ? const I2StateMessage(
                      icon: CupertinoIcons.person_3,
                      message: '暂无窝次记录',
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                      children: [
                        IosGroupedSection(
                          children: [
                            for (final litter in snapshot.litters)
                              IosListTile(
                                title: i2LitterStateLabel(litter.state),
                                subtitle:
                                    '${i2DateLabel(litter.bornAt)} · '
                                    '初始 ${litter.initialAliveCount} 只 · '
                                    '当前 ${litter.currentManagedCount} 只',
                                trailing: Text(
                                  litter.state,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                showChevron: false,
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}
