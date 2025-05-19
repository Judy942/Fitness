import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/app_colors.dart';
import '../../../services/user_service.dart';
import '../camera_screen.dart';

class ResultView extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;
  const ResultView({super.key, required this.date1, required this.date2});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final UserService _userService = UserService();
  Map<int, List<dynamic>> groupedData = {};
  Map<int, List<dynamic>> groupedData2 = {};
  bool isLoading = true;
  String error = '';
  late double imageWidth;
  late double imageHeight;
  final double imageSpacing = 8.0;

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
    print('Initializing with date1: ${widget.date1}, date2: ${widget.date2}');
    
    fetchProcessTrackerByMounth(widget.date1.month.toString(), widget.date1.year).then((value) {
      print('Received data for date1: $value');
      setState(() {
        groupedData = value;
        isLoading = false;
      });
    }).catchError((error) {
      print('Error fetching data for date1: $error');
      setState(() {
        this.error = error.toString();
        isLoading = false;
      });
    });

    fetchProcessTrackerByMounth(widget.date2.month.toString(), widget.date2.year).then((value) {
      print('Received data for date2: $value');
      setState(() {
        groupedData2 = value;
        isLoading = false;
      });
    }).catchError((error) {
      print('Error fetching data for date2: $error');
      setState(() {
        this.error = error.toString();
        isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tính toán kích thước ảnh dựa trên màn hình
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40 - 16; // Trừ padding và spacing
    imageWidth = availableWidth * 0.4; // 40% chiều rộng màn hình
    imageHeight = imageWidth * 1.5; // Tỷ lệ 2:3
  }

  // Phần code tải ảnh, giải mã và lưu lại

  Future<Map<int, List<dynamic>>> fetchProcessTrackerByMounth(String month, int year) async {
    String? token = await getToken();
    final url = Uri.parse(
        'http://192.168.133.103:8055/items/process_tracker?fields[]=*&sort[]=date_upload&filter[user_id][_eq]=\$CURRENT_USER&filter[month(date_upload)][_eq]=$month&filter[year(date_upload)][_eq]=$year');

    print('Fetching data for month: $month, year: $year');
    print('URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      print('Data received: $data');
      
      // Lọc dữ liệu theo ngày chính xác
      final filteredData = data.where((item) {
        final dateUpload = DateTime.parse(item['date_upload']);
        return dateUpload.month == int.parse(month) && dateUpload.year == year;
      }).toList();
      
      // Nhóm dữ liệu theo tracker_position_id
      Map<int, List<dynamic>> groupedData = {};
      for (var item in filteredData) {
        int positionId = item['tracker_position_id'];
        if (!groupedData.containsKey(positionId)) {
          groupedData[positionId] = [];
        }
        groupedData[positionId]!.add(item);
      }
      
      print('Grouped data: $groupedData');
      return groupedData;
    } else {
      throw Exception('Failed to load process tracker data');
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
    final fileUrl = 'http://192.168.133.103:8055/assets/$filePath';
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

  Future<void> _deleteImage(String imageId) async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? token = await getToken();
      
      // Lấy thông tin ảnh trước khi xóa
      final getResponse = await http.get(
        Uri.parse('http://192.168.133.103:8055/items/process_tracker/$imageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (getResponse.statusCode == 200) {
        final imageData = jsonDecode(getResponse.body)['data'];
        final fileId = imageData['image'];

        // Xóa file trong storage
        final deleteFileResponse = await http.delete(
          Uri.parse('http://192.168.133.103:8055/files/$fileId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (deleteFileResponse.statusCode != 200 && deleteFileResponse.statusCode != 204) {
          throw Exception('Xóa file thất bại');
        }

        // Xóa record trong database
        final deleteResponse = await http.delete(
          Uri.parse('http://192.168.133.103:8055/items/process_tracker/$imageId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
        );

        // Đóng loading
        Navigator.pop(context);

        if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
          // Cập nhật lại dữ liệu sau khi xóa
          setState(() {
            isLoading = true;
          });
          await fetchProcessTrackerByMounth(widget.date1.month.toString(), widget.date1.year).then((value) {
            setState(() {
              groupedData = value;
              isLoading = false;
            });
          });
          await fetchProcessTrackerByMounth(widget.date2.month.toString(), widget.date2.year).then((value) {
            setState(() {
              groupedData2 = value;
              isLoading = false;
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa ảnh thành công')),
          );
        } else {
          throw Exception('Xóa ảnh thất bại');
        }
      } else {
        throw Exception('Không thể lấy thông tin ảnh');
      }
    } catch (e) {
      // Đóng loading nếu có lỗi
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa ảnh: $e')),
      );
    }
  }

  Future<void> _editImage(String imageId, int positionId, DateTime date) async {
    try {
      // Hiển thị dialog để chọn vị trí và ngày
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          int selectedPosition = positionId;
          DateTime selectedDate = date;
          
          return AlertDialog(
            title: const Text('Chỉnh sửa thông tin ảnh'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedPosition,
                      decoration: const InputDecoration(
                        labelText: 'Vị trí',
                      ),
                      items: List.generate(4, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(tracker_position[index]),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPosition = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày chụp',
                        ),
                        child: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context, {
                          'position': selectedPosition,
                          'date': selectedDate,
                          'changeImage': true,
                        });
                      },
                      child: const Text('Thay đổi ảnh'),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'position': selectedPosition,
                    'date': selectedDate,
                    'changeImage': false,
                  });
                },
                child: const Text('Lưu thông tin'),
              ),
            ],
          );
        },
      );

      if (result == null) return;

      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String? token = await getToken();
      
      // Lấy thông tin ảnh cũ
      final getResponse = await http.get(
        Uri.parse('http://192.168.133.103:8055/items/process_tracker/$imageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (getResponse.statusCode == 200) {
        final oldImageData = jsonDecode(getResponse.body)['data'];
        final oldFileId = oldImageData['image'];

        String newFileId = oldFileId;

        // Chỉ thay đổi ảnh nếu người dùng chọn
        if (result['changeImage'] == true) {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
          
          if (image != null) {
            // Mã hóa ảnh mới
            final encryptedFilePath = await encryptImage(image.path);
            
            // Tải lên ảnh đã mã hóa
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('http://192.168.133.103:8055/files'),
            );

            request.headers['Authorization'] = 'Bearer $token';
            request.files.add(await http.MultipartFile.fromPath('file', encryptedFilePath));

            var response = await request.send();
            if (response.statusCode == 200) {
              final responseData = await response.stream.bytesToString();
              newFileId = jsonDecode(responseData)['data']['id'];

              // Xóa file ảnh cũ
              await http.delete(
                Uri.parse('http://192.168.133.103:8055/files/$oldFileId'),
                headers: {
                  'Authorization': 'Bearer $token',
                },
              );
            } else {
              throw Exception('Tải lên ảnh thất bại');
            }
          } else {
            // Đóng loading nếu người dùng hủy chọn ảnh
            Navigator.pop(context);
            return;
          }
        }

        // Cập nhật thông tin ảnh trong database
        final updateResponse = await http.patch(
          Uri.parse('http://192.168.133.103:8055/items/process_tracker/$imageId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            'image': newFileId,
            'tracker_position_id': result['position'],
            'date_upload': result['date'].toIso8601String(),
          }),
        );

        // Đóng loading
        Navigator.pop(context);

        if (updateResponse.statusCode == 200 || updateResponse.statusCode == 204) {
          // Cập nhật lại dữ liệu sau khi sửa
          setState(() {
            isLoading = true;
          });
          await fetchProcessTrackerByMounth(widget.date1.month.toString(), widget.date1.year).then((value) {
            setState(() {
              groupedData = value;
              isLoading = false;
            });
          });
          await fetchProcessTrackerByMounth(widget.date2.month.toString(), widget.date2.year).then((value) {
            setState(() {
              groupedData2 = value;
              isLoading = false;
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin thành công')),
          );
        } else {
          throw Exception('Cập nhật thông tin thất bại');
        }
      } else {
        throw Exception('Không thể lấy thông tin ảnh cũ');
      }
    } catch (e) {
      // Đóng loading nếu có lỗi
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật thông tin: $e')),
      );
    }
  }

  void _showImageOptions(BuildContext context, String imageId, int positionId, DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _editImage(imageId, positionId, date);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, imageId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String imageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ảnh này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteImage(imageId);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.memory(
                    imageData,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(Uint8List imageData, String imageId, int positionId, DateTime date) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageData),
      onLongPress: () => _showImageOptions(context, imageId, positionId, date),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          imageData,
          fit: BoxFit.cover,
          width: imageWidth,
          height: imageHeight,
        ),
      ),
    );
  }

  Future<String> encryptImage(String imagePath) async {
    // Đọc hình ảnh dưới dạng byte
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Thêm padding vào dữ liệu hình ảnh
    Uint8List paddedImageBytes = addPadding(imageBytes);

    final keyAndIv = await getKeyAndIv();

    String? encryptionKey = keyAndIv['key'];
    String? encryptionIv = keyAndIv['iv'];

    if (encryptionKey == null || encryptionIv == null) {
      throw Exception("Key hoặc IV không tồn tại trong storage");
    }

    final key = encrypt.Key.fromBase64(encryptionKey);
    final iv = encrypt.IV.fromBase64(encryptionIv);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Mã hóa dữ liệu hình ảnh đã được padding
    final encrypted = encrypter.encryptBytes(paddedImageBytes, iv: iv);
    // Chuyển đổi dữ liệu đã mã hóa thành Base64
    String base64Encrypted = base64.encode(encrypted.bytes);

    // Lưu vào file văn bản
    String encryptedFilePath = '${imagePath}_encrypted.txt';
    File encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsString(base64Encrypted);

    return encryptedFilePath;
  }

  Uint8List addPadding(Uint8List input) {
    int blockSize = 16; // Kích thước block của AES
    int paddingLength = blockSize - (input.length % blockSize);
    if (paddingLength == 0) {
      return input; // Không cần padding nếu đã là bội số của blockSize
    }

    Uint8List paddedInput = Uint8List(input.length + paddingLength);
    paddedInput.setAll(0, input);

    // Padding theo chuẩn PKCS7: điền paddingLength vào cuối dữ liệu
    for (int i = 0; i < paddingLength; i++) {
      paddedInput[input.length + i] = paddingLength;
    }
    return paddedInput;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = '';
                  });
                  initState();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    String formatDate(DateTime date) {
      return '${date.month}/${date.year}';
    }

    if (groupedData.isEmpty && groupedData2.isEmpty) {
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
        body: const Center(
          child: Text('Không có dữ liệu để hiển thị'),
        ),
      );
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cột bên trái - Thời gian 1
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    formatDate(widget.date1),
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: imageSpacing,
                                    childAspectRatio: imageWidth / imageHeight,
                                  ),
                                  itemCount: items2.length,
                                  itemBuilder: (context, i) {
                                    return FutureBuilder<Uint8List>(
                                      future: decryptAndSaveImageFromTextFile(
                                        items2[i]['image'],
                                        'image_$i.png',
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if (snapshot.hasData) {
                                            return _buildImage(
                                              snapshot.data!,
                                              items2[i]['id'],
                                              items2[i]['tracker_position_id'],
                                              DateTime.parse(items2[i]['date_upload']),
                                            );
                                          } else {
                                            return const Icon(Icons.error_outline);
                                          }
                                        } else {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Cột bên phải - Thời gian 2
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    formatDate(widget.date2),
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: imageSpacing,
                                    childAspectRatio: imageWidth / imageHeight,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (context, i) {
                                    return FutureBuilder<Uint8List>(
                                      future: decryptAndSaveImageFromTextFile(
                                        items[i]['image'],
                                        'image_$i.png',
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if (snapshot.hasData) {
                                            return _buildImage(
                                              snapshot.data!,
                                              items[i]['id'],
                                              items[i]['tracker_position_id'],
                                              DateTime.parse(items[i]['date_upload']),
                                            );
                                          } else {
                                            return const Icon(Icons.error_outline);
                                          }
                                        } else {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
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
