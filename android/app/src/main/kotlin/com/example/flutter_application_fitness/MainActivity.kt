package com.example.flutter_application_fitness

// import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}


// package com.example.flutter_application_fitness

// import android.app.Activity
// import android.content.Intent
// import android.os.Bundle
// import androidx.activity.result.contract.ActivityResultContracts
// import androidx.health.connect.client.HealthConnectClient
// import androidx.health.connect.client.permission.Permission
// import androidx.health.connect.client.records.StepsRecord
// import io.flutter.embedding.android.FlutterFragmentActivity
// import kotlinx.coroutines.*

// class MainActivity : FlutterFragmentActivity() {
//     private lateinit var healthConnectClient: HealthConnectClient

//     // Request code không còn cần nếu dùng ActivityResultLauncher (modern way)
//     private val permissions = setOf(
//         Permission.readRecords(StepsRecord::class),
//         Permission.writeRecords(StepsRecord::class)
//     )

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
//         healthConnectClient = HealthConnectClient.getOrCreate(this)

//         // Gọi kiểm tra quyền bằng coroutine
//         CoroutineScope(Dispatchers.Main).launch {
//             checkAndRequestPermissions()
//         }
//     }

//     private suspend fun checkAndRequestPermissions() {
//         val granted = healthConnectClient.permissionController.getGrantedPermissions()
//         if (!granted.containsAll(permissions)) {
//             val intent = healthConnectClient.permissionController
//                 .createRequestPermissionIntent(permissions)
//             startActivityForResult(intent, 1001)
//         }
//     }

//     // (Tùy chọn) xử lý kết quả xin quyền
//     override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//         super.onActivityResult(requestCode, resultCode, data)
//         if (requestCode == 1001 && resultCode == Activity.RESULT_OK) {
//             // Quyền được cấp thành công
//         }
//     }
// }
