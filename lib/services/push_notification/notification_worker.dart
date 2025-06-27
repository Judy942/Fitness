import 'package:workmanager/workmanager.dart';

import 'NotificationSyncService.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncNotifications':
        await NotificationSyncService.syncAllNotifications();
        break;
    }
    return true;
  });
} 