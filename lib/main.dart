// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:convert'; // For JSON decoding

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: PhotoCaptureScreen(),
//     );
//   }
// }

// class PhotoCaptureScreen extends StatefulWidget {
//   @override
//   _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
// }

// class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
//   File? _image;
//   String? _uploadedFileUrl;
//   String? _prediction; // Variable to store predictions

//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_image == null) {
//       print("No image selected.");
//       return;
//     } else {
//       print("Image selected.");
//     }

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://rasanjali-smart-green-web.hf.space/upload'),
//       );

//       request.files
//           .add(await http.MultipartFile.fromPath('photo', _image!.path));

//       final response = await request.send();
//       final responseData = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         print("Upload success");
//         print(response);

//         // Decode the JSON response
//         final Map<String, dynamic> jsonResponse = json.decode(responseData);
//         print(jsonResponse);

//         // Extract the filename and prediction
//         final String prediction = jsonResponse['prediction'] as String;

//         setState(() {
//           _uploadedFileUrl =
//               'http://rasanjali-smart-green-web.hf.space/uploads/${jsonResponse['filename']}';
//           _prediction = prediction;
//         });
//       } else {
//         print('Upload failed');
//       }
//     } catch (e) {
//       print('Error occurred: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: Center(
//         child: Text(
//           'Smart Green',
//           textAlign: TextAlign.center,
//         ),
//       )),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _image == null ? Text('No image selected.') : Image.file(_image!),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: Text('Capture Photo'),
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: _uploadImage,
//                 child: Text('Upload Photo'),
//               ),
//               SizedBox(height: 20),
//               _uploadedFileUrl != null
//                   // ? Image.network(_uploadedFileUrl!)
//                   ? Text("")
//                   : Text('No image uploaded.'),
//               SizedBox(height: 20),
//               _prediction != null
//                   ? SizedBox(
//                       height: 100,
//                       child: Text('Prediction: $_prediction'),
//                     )
//                   : Text('No predictions available.'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PhotoCaptureScreen(),
    );
  }
}

class PhotoCaptureScreen extends StatefulWidget {
  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  File? _image;
  String? _uploadedFileUrl;
  String? _prediction;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File? croppedFile = await _cropImage(File(pickedFile.path));

      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
      }
    }
  }

  // Future<File?> _cropImage(File imageFile) async {
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: imageFile.path,
  //     aspectRatioPresets: [
  //       CropAspectRatioPreset.square,
  //       CropAspectRatioPreset.ratio3x2,
  //       CropAspectRatioPreset.original,
  //       CropAspectRatioPreset.ratio4x3,
  //       CropAspectRatioPreset.ratio16x9,
  //     ],
  //     androidUiSettings: AndroidUiSettings(
  //       toolbarTitle: 'Crop Image',
  //       toolbarColor: Colors.deepOrange,
  //       toolbarWidgetColor: Colors.white,
  //       initAspectRatio: CropAspectRatioPreset.original,
  //       lockAspectRatio: false,
  //     ),
  //     iosUiSettings: IOSUiSettings(
  //       minimumAspectRatio: 1.0,
  //     ),
  //   );

  //   if (croppedFile != null) {
  //     return File(croppedFile.path);
  //   }
  //   return null;
  // }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(
          ratioX: 1.0,
          ratioY: 1.0), // Replace aspectRatioPresets with aspectRatio if needed
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      print("No image selected.");
      return;
    } else {
      print("Image selected.");
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://rasanjali-smart-green-web.hf.space/upload'),
      );

      request.files
          .add(await http.MultipartFile.fromPath('photo', _image!.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Upload success");
        print(response);

        final Map<String, dynamic> jsonResponse = json.decode(responseData);
        print(jsonResponse);

        final String prediction = jsonResponse['prediction'] as String;

        setState(() {
          _uploadedFileUrl =
              'http://rasanjali-smart-green-web.hf.space/uploads/${jsonResponse['filename']}';
          _prediction = prediction;
        });
      } else {
        print('Upload failed');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Smart Green',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null ? Text('No image selected.') : Image.file(_image!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Capture and Crop Photo'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Photo'),
              ),
              SizedBox(height: 20),
              _uploadedFileUrl != null ? Text("") : Text('No image uploaded.'),
              SizedBox(height: 20),
              _prediction != null
                  ? SizedBox(
                      height: 100,
                      child: Text('Prediction: $_prediction'),
                    )
                  : Text('No predictions available.'),
            ],
          ),
        ),
      ),
    );
  }
}
