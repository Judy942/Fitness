import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/app_colors.dart';
import '../../onboarding_screen/start_screen.dart';
import '../camera_screen.dart';

class ResultView extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;
  const ResultView({super.key, required this.date1, required this.date2});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  List imaArr = [];
  List statArr = [];

  List tracker_position = [
    "Front Facing",
    "Back Facing",
    "Left Facing",
    "Right Facing",
  ];

  @override
  void initState() {
    super.initState();
    fetchProcessTrackerByMounth(widget.date1.month.toString()).then((value) {
      setState(() {
        imaArr = value;
      });
    });
    fetchProcessTrackerByMounth(widget.date2.month.toString()).then((value) {
      setState(() {
        statArr = value;
      });
    });
  }

  // Phần code tải ảnh, giải mã và lưu lại

  Future<List<dynamic>> fetchProcessTrackerByMounth(String m) async {
    String? token = await getToken();
    final url = Uri.parse(
        'http://162.248.102.236:8055/items/process_tracker?limit=25&fields[]=*&sort[]=date_upload&page=1&filter[user_id][_eq]=\$CURRENT_USER&filter[month(date_upload)][_eq]=$m&filter[year(date_upload)][_eq]=${widget.date1.year}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          return jsonResponse['data'];
        } else {
          return []; // Trả về danh sách rỗng nếu không có dữ liệu
        }
      } else {
        return []; // Trả về danh sách rỗng nếu không có dữ liệu
      }
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Trả về danh sách rỗng trong trường hợp lỗi
    }
  }

// Loại bỏ padding sau khi giải mã
  Uint8List removePadding(Uint8List input) {
    int paddingLength = input.last; // Lấy giá trị padding ở cuối
    print('Padding length: $paddingLength');
    return input.sublist(0, input.length - paddingLength); // Cắt bỏ padding
  }

  Future<Uint8List> decryptImageFromBase64(String encryptedBase64) async {
    final encryptedBytes = base64.decode(encryptedBase64);
    print("độ dài Base64 trước giải mã: ${encryptedBase64.length}");
    print("độ dài Byte trước giải mã: ${encryptedBytes.length}");
    print(
        "Decrypted data (first 100 bytes): ${encryptedBytes.sublist(0, 100)}");

    // final key = encrypt.Key.fromUtf8('my 32 length key................');
    // final iv = encrypt.IV.fromLength(16);
    final keyAndIv = await getKeyAndIv();

// Ensure that both key and iv are not null before using them
    String? encryptionKey = keyAndIv['key'];
    String? encryptionIv = keyAndIv['iv'];

    if (encryptionKey == null || encryptionIv == null) {
      // Handle the case where the key or iv is missing
      throw Exception("Key or IV is missing in storage");
    }

    final key = encrypt.Key.fromBase64(encryptionKey);
    final iv = encrypt.IV.fromBase64(encryptionIv);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
    print("Kích thước ảnh (bytes): ${decryptedBytes.length}");
    print(
        "Ảnh sau giải mã: ${decryptedBytes.sublist(0, 100)}"); // In 100 byte đầu
    if (decryptedBytes.isEmpty) {
      throw Exception("Dữ liệu giải mã trống.");
    }

    return removePadding(Uint8List.fromList(decryptedBytes));
  }

  Future<String> fetchFileContent(String url) async {
    String? token = await getToken();

    try {
      // Gửi yêu cầu HTTP GET
      final response = await http.get(
        // url,
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        // Thành công, nội dung file trả về dưới dạng bytes hoặc string
        final content = response.body;
        return content;
      } else {
        print(
            "Lỗi khi tải file: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Lỗi khi tải nội dung file: $e");
    }
    return '';
  }

  Future<Uint8List> decryptAndSaveImageFromTextFile(
      String filePath, String fileName) async {
    final fileUrl = 'http://162.248.102.236:8055/assets/$filePath';
    String fileContent = await fetchFileContent(fileUrl);
    try {
      // Kiểm tra xem file có tồn tại không
      if (fileContent.isNotEmpty) {
        // Giải mã Base64 từ nội dung file
        final decryptedBytes = await decryptImageFromBase64(fileContent);
        print("giải mã thành công!!!!");
        if (decryptedBytes.isEmpty) {
          throw Exception("Giải mã thất bại: Dữ liệu sau khi giải mã rỗng.");
        }
        return decryptedBytes;
        // Lưu ảnh vào tệp
        // return await saveImageToFile(decryptedBytes, fileName);
      } else {
        throw Exception("File không tồn tại tại đường dẫn: $filePath");
      }
    } catch (e) {
      print("Lỗi khi giải mã hoặc lưu ảnh: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    var groupedData = <int, List<dynamic>>{};
    for (var item in statArr) {
      int positionId = item['tracker_position_id'];
      if (!groupedData.containsKey(positionId)) {
        groupedData[positionId] = [];
      }
      groupedData[positionId]!.add(item);
    }

    var groupedData2 = <int, List<dynamic>>{};
    for (var item in imaArr) {
      int positionId = item['tracker_position_id'];
      if (!groupedData2.containsKey(positionId)) {
        groupedData2[positionId] = [];
      }
      groupedData2[positionId]!.add(item);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Result",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, index) {
                  int positionId = index + 1;
                  if (!groupedData.containsKey(positionId) &&
                      !groupedData2.containsKey(positionId)) {
                    return const SizedBox();
                  }
                  List<dynamic> items = groupedData[positionId] ?? [];
                  List<dynamic> items2 = groupedData2[positionId] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          tracker_position[positionId - 1],
                          style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Before",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: items2.length,
                            itemBuilder: (context, i) {
                              return FutureBuilder<Uint8List>(
                          future: decryptAndSaveImageFromTextFile(
                            items2[i]['image'],
                            'image_$i.png',
                          ),
                          builder: (context, snapshot) {
                            // Image.file(File(snapshot.data!.path));
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                // return Image.file(snapshot.data!);
                                return Image.memory(snapshot.data!);
                              } else {
                                return const Icon(Icons.error_outline);
                              }
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                                
                              );
                            },
                          ),
                          const Text(
                            "After",
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              return FutureBuilder<Uint8List>(
                          future: decryptAndSaveImageFromTextFile(
                            items2[i]['image'],
                            'image_$i.png',
                          ),
                          builder: (context, snapshot) {
                            // Image.file(File(snapshot.data!.path));
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                // return Image.file(snapshot.data!);
                                return Image.memory(snapshot.data!);
                              } else {
                                return const Icon(Icons.error_outline);
                              }
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

                // return Column(
//                   children: [
//                     Center(child: Text(tracker_position[positionId - 1])),
//                     // Hiển thị ảnh giải mã từ base64
//                     GridView.builder(
//                       shrinkWrap: true,
//                       itemCount: items2.length,
//                       itemBuilder: (context, i) {
//                         return FutureBuilder<Uint8List>(
//                           future: decryptAndSaveImageFromTextFile(
//                             items2[i]['image'],
//                             'image_$i.png',
//                           ),
//                           builder: (context, snapshot) {
//                             // Image.file(File(snapshot.data!.path));
//                             if (snapshot.connectionState ==
//                                 ConnectionState.done) {
//                               if (snapshot.hasData) {
//                                 // return Image.file(snapshot.data!);
//                                 return Image.memory(snapshot.data!);
//                               } else {
//                                 return const Icon(Icons.error_outline);
//                               }
//                             } else {
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             }
//                           },
//                         );
//                       },
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                       ),
//                     ),
//                     // Tương tự cho các ảnh "After"
//                     GridView.builder(
//                       shrinkWrap: true,
//                       itemCount: items.length,
//                       itemBuilder: (context, i) {
//                         return FutureBuilder<Uint8List>(
//                           future: decryptAndSaveImageFromTextFile(
//                             items[i]['image'],
//                             'image_after_$i.jpg',
//                           ),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.done) {
//                               if (snapshot.hasData) {
//                                 // return Image.file(snapshot.data!);
//                                 return Image.memory(snapshot.data!);
//                               } else {
//                                 return const Icon(Icons.error_outline);
//                               }
//                             } else {
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             }
//                           },
//                         );
//                       },
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
