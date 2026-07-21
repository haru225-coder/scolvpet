import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/i2_repository.dart';
import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../genetic/genetic.dart';
import '../health/health_controller.dart';
import '../health/health_models.dart';
import '../tasks/task_controller.dart';
import '../tasks/task_models.dart';
import '../weight/weight_alerts.dart';
import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

part 'hamster_list_page.dart';
part 'hamster_detail_page.dart';
part 'hamster_detail_parts.dart';
part 'litter_list_page.dart';
part 'hamster_editor_page.dart';
part 'batch_hamster_editor_page.dart';
part 'weight_entry_page.dart';

String _hamsterWriteRestrictionMessage(I2Controller controller, String action) {
  if (controller.offline) return '当前为离线只读，联网后再$action';
  return '当前角色没有$action的权限';
}
