import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_fitness/presentation/camera/photo_progress/comparison_view.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/app_colors.dart';
import '../../../services/image_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/round_button.dart';
import '../camera_screen.dart';

class ProgressPhotoScreen extends StatefulWidget {
  const ProgressPhotoScreen({Key? key}) : super(key: key);

  @override
  State<ProgressPhotoScreen> createState() => _ProgressPhotoScreenState();
}

class _ProgressPhotoScreenState extends State<ProgressPhotoScreen> {
  Future<List<dynamic>> fetchProcessTracker() async {
    await Permission.storage.request();
    String? token = await getToken();
    // Thay $CURRENT_USER bằng userId
    final url = Uri.parse(
        'http://192.168.133.100:8055/items/process_tracker?limit=15&fields[]=*&sort[]=date_upload&page=1&filter[user_id][_eq]=\$CURRENT_USER');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      // Giải mã dữ liệu JSON
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      return jsonResponse['data']; // Trả về danh sách dữ liệu
    } else {
      throw Exception('Không thể tải dữ liệu theo dõi tiến trình');
    }
  }

  List photoArr = [];

  @override
  void initState() {
    super.initState();
    fetchProcessTracker().then((value) {
      setState(() {
        photoArr = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: const Text(
          "Ảnh tiến trình",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.primaryColor2.withOpacity(0.4),
                          AppColors.primaryColor1.withOpacity(0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                "Theo dõi tiến trình của bạn\nmỗi tháng bằng hình ảnh",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: media.width * 0.45,
                                height: 35,
                              )
                            ]),
                        Image.asset(
                          "assets/images/progress_each_photo.png",
                          width: 75,
                          fit: BoxFit.cover,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "So sánh hình ảnh của tôi",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 90,
                        height: 28,
                        child: RoundButton(
                          title: "So sánh",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ComparisonView(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Thư viện",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ComparisonView(),
                              ),
                            );
                          },
                          child: const Text(
                            "Xem thêm",
                            style: TextStyle(
                                color: AppColors.grayColor, fontSize: 12),
                          ))
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: ScrollController(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.3,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: photoArr.length,
                      itemBuilder: ((context, index) {
                        var pObj = photoArr[index] as Map? ?? {};
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrayColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FutureBuilder<Uint8List>(
                            future: ImageService.decryptAndSaveImageFromTextFile(
                              pObj['image'],
                              'image_$index.png',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      snapshot.data!,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: MediaQuery.of(context).size.width * 0.3,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                } else {
                                  return const Icon(Icons.error_outline);
                                }
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          PermissionStatus status = await Permission.camera.request();
          if (status.isGranted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
            if (result != null) {
              // Xử lý đường dẫn ảnh ở đây (nếu cần)
              print("Đã chụp ảnh: $result");
            }
          } else if (status.isDenied) {
            // Quyền bị từ chối, hiển thị thông báo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cần quyền truy cập camera để chụp ảnh.'),
              ),
            );
          } else if (status.isPermanentlyDenied) {
            // Quyền bị từ chối vĩnh viễn, hướng dẫn người dùng mở cài đặt
            openAppSettings();
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.secondary),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: const Icon(
            Icons.photo_library_outlined,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
