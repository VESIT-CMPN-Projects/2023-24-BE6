import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:deliveryx/util/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final nameController = TextEditingController();
  final messageController = TextEditingController();
  final emailController = TextEditingController();

  Future<int?> sendEmail() async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    const serviceId = "service_m9bvefn";
    const templateId = "template_wobq303";
    const userId = "Hr_YJSRhNo93TKZzi";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost'
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "name": nameController.text,
            "message": messageController.text,
            "user_email": emailController.text,
          }
        }),
      );

      if (response.statusCode == 200) {
        // Success toast message
        showToast("Email sent successfully");
      } else {
        // Error toast message
        showToast("Failed to send email. Error code: ${response.statusCode}");
      }

      return response.statusCode;
    } catch (e) {
      // Exception toast message
      showToast("Error occurred while sending email: $e");
      return null; // or any other appropriate error code
    }
  }

  void showToast(String message) {
    // Your code to display toast message
    print("Toast message: $message");
  }

  void _launchPhoneCall() async {
    const String phoneNumber = 'tel:+918828596039';
    try {
      await launchUrlString(phoneNumber);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: AppColors.primary, // Set the color you desire
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'If you have any questions or concerns about DeliveryX or anything in particular, please contact us at:-',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 5),
            const Text(
              'Email: delivery0x0@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Phone: +1 (575) 575-5757'
              '\nLast Updated: [13-01-2024]',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _launchPhoneCall();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Button color
                    foregroundColor: AppColors.black, // Text color
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    //minimumSize: Size(double.infinity, 0), // Full width
                  ),
                  child: Text(
                    'Call',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Send us a Message',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            _buildContactForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person, color: AppColors.primary),
            hintText: "Name",
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 203, 195, 195)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email, color: AppColors.primary),
            hintText: "Email",
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 203, 195, 195)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: messageController,
          maxLines: 3,
          decoration: InputDecoration(
            // prefixIcon: Icon(Icons.email, color: AppColors.primary),
            hintText: "Message",
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromARGB(255, 203, 195, 195)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                sendEmail();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Button color
                foregroundColor: AppColors.black, // Text color
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
                //minimumSize: Size(double.infinity, 0), // Full width
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
