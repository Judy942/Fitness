import 'dart:math';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailService {
  static String generateOTP(int length) {
    const chars = '0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Lưu OTP và thời gian tạo
  static Future<void> saveOTP(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('otp_$email', otp);
    await prefs.setInt('otp_time_$email', DateTime.now().millisecondsSinceEpoch);
  }

  // Verify OTP
  static Future<bool> verifyOTP(String email, String inputOTP) async {
    final prefs = await SharedPreferences.getInstance();
    final savedOTP = prefs.getString('otp_$email');
    final otpTime = prefs.getInt('otp_time_$email');

    print('Đang verify OTP cho email: $email');
    print('OTP đã lưu: $savedOTP');
    print('OTP người dùng nhập: $inputOTP');
    print('Thời gian tạo OTP: $otpTime');

    if (savedOTP == null || otpTime == null) {
      print('Không tìm thấy OTP cho email $email');
      return false;
    }

    // Kiểm tra thời gian hết hạn (10 phút)
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = currentTime - otpTime;
    final isExpired = timeDiff > 10 * 60 * 1000; // 10 phút

    print('Thời gian hiện tại: $currentTime');
    print('Khoảng thời gian: $timeDiff ms');
    print('OTP hết hạn: $isExpired');

    if (isExpired) {
      print('OTP đã hết hạn');
      return false;
    }

    // So sánh OTP
    final isValid = savedOTP == inputOTP;
    print('OTP hợp lệ: $isValid');

    if (isValid) {
      // Xóa OTP sau khi verify thành công
      await prefs.remove('otp_$email');
      await prefs.remove('otp_time_$email');
      print('Đã xóa OTP sau khi verify thành công');
    }
    return isValid;
  }

  static Future<bool> sendOTPEmail(String recipientEmail) async {
    try {
      print('Bắt đầu gửi OTP đến $recipientEmail');
      
      // Tạo mã OTP
      final otp = generateOTP(6);
      print('Đã tạo mã OTP: $otp');

      // Lưu OTP
      await saveOTP(recipientEmail, otp);
      print('Đã lưu OTP vào bộ nhớ');

      // Cấu hình SMTP
      print('Đang cấu hình SMTP...');
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: 'trinhthuc130902@gmail.com',
        password: 'gkkt dvcr sbry mcya',
        name: 'Fitness App',
        ssl: false,
        allowInsecure: true,
      );
      print('Cấu hình SMTP thành công');

      // Tạo email
      final message = Message()
          ..from = Address('trinhthuc130902@gmail.com', 'Fitness App')
        ..recipients.add(recipientEmail)
        ..subject = 'Mã xác thực Fitness App'
        ..html = '''
          <h3>Xin chào,</h3>
          <p>Cảm ơn bạn đã sử dụng Fitness App.</p>
          <p>Mã xác thực của bạn là: <strong>$otp</strong></p>
          <p>Mã này sẽ hết hạn sau 10 phút.</p>
          <p>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.</p>
          <br>
          <p>Trân trọng,<br>Đội ngũ Fitness App</p>
        '''
        ..text = '''
          Xin chào,

          Cảm ơn bạn đã sử dụng Fitness App.
          Mã xác thực của bạn là: $otp
          Mã này sẽ hết hạn sau 10 phút.

          Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.

          Trân trọng,
          Đội ngũ Fitness App
        ''';

      // Gửi email
      print('Đang gửi email...');
      final sendReport = await send(message, smtpServer);
      print('Kết quả gửi email: $sendReport');
      
      // Kiểm tra kết quả gửi email
      if (sendReport.toString().contains('Message successfully sent')) {
        print('Email đã được gửi thành công đến $recipientEmail');
        print('Mã OTP: $otp'); // In ra mã OTP để test
        return true;
      } else {
        print('Không thể gửi email đến $recipientEmail');
        print('Lỗi: ${sendReport.toString()}');
        return false;
      }
    } catch (error) {
      print('Lỗi chi tiết khi gửi email: $error');
      return false;
    }
  }
} 