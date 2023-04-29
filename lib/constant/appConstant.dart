import 'package:flutter/material.dart';

import '../main.dart';

class AppConst extends ChangeNotifier {
  static String AppName = "ChatApp";
  static String PlaceHolder = "https://picsum.photos/id/237/200/300";

  String enterNumber = "Enter your phone number";
  String verifyNumber = "${AppName} will need to verify your phone number.";
  String carrierCharge = "Carrier charges may apply";
  String enterOtp = "Enter OTP";
  var provideOtp = (number) => "Provide the OTP sent to $number";
  late String otpPlease = "Please " + enterOtp;
  String validOtp = "Provide valid OTP code";
  String cancel = "Cancel";
  String verify = "Verify";
  String next = "Next";
  String phoneNumber = "phone number";

  //ProfileInfo Screen

  String profileInfo = "Profile info";
  String provideInfo =
      "Please provide your name and an optional profile photo.";
  String yourName = "Type your name here";
  String enterName = "Please enter your name";

  //ChatScreen
  String deleteMsg = "Delete conversation";
  String sureDeleteMsg = "Are you sure!! You want to delete this conversation";
  String yes = "Yes";
  String no = "No";

  //Status Screen
  String stories = "Stories";
  String myStatus = 'My Status';
  String status = 'Status';
  String addStatus = 'Tap to add status update';

  //Profile
  String userProfile = "User Profile";
  String name = "Name";
  String about = "About";
  String number = "Number";
  String save = "Save";
  var enterField = (field) => 'Enter your ${field.toLowerCase()}';

  //Account
  String account = "Accounts";
  String proceed = "Proceed";
  String changeNumber = "Change Number";
  String needtoVerify = "Verify Number";
  String requestInfo = "Request account info";
  String proceedToVerify = "Proceed to verify";
  String deleteMyAccount = "Delete my account";
  String deleteAccount = "Delete Account";
  String migrateAccount =
      "Changing your phone number will migrate your account info,groups & settings.";
  String verifyNewNumber =
      "Before proceeding, please confirm that you are able to receive SMS or calls at your new number";
  String changeOldPhone =
      "If you have both a new phone & a new number,first change your number on your old phone.";
  String enterOldNumber = "Enter your old phone number with country code";
  String enterNewNumber = "Enter your new phone number with country code";
  String clickproceedToVerify =
      "if you want to edit number then press back/cancel. Click on 'Proceed' to verify number.";
  String clickToDelete = "Click to delete your account";
  String sendOtp = "Send OTP";

  //Help Screen
  String help = "Help";
  String helpCenter = "Help Center";
  String contactUs = "Contact us";
  String howToHelp = "Tell us how we can help";
  String deviceIfo = "Include device information? (optional)";
  String techDetails =
      "Technical details like your model and settings can help us answer your question.";
  String respondInChat = "We will respond to you in a $AppName chat";
  String termPolicy = "Terms and Privacy Policy";
  String appMessanger = AppName + " Messenger";
  String onward = "2022-onwards $AppName.inc";
  String appInfo = "App Info";

  //Utils
  String camera = "Camera";
  String gallery = "Gallery";
  String location = "Location";
  String document = "Documents";
  String audio = "Audio";
  String contact = "Contact";
  String selectContact = "Select Contact";
  String photoLibrary = "Photo Library";
  String shareContact = "Share contact";
  String sendContact = "Send this selected contact?";
  String send = "Send";

  //Qr code Screen
  String qrCode = "QR Code";
  String myQR = "My QR";
  String scanQR = "Scan QR";
  String privateQR =
      "Your QR code is private. If you share it with someone, they can scan if with their $AppName camera to add you as a contact.";
  String imageSaved = "Image successfully saved to gallery";
  String scanCode = "Scan Code";
  var inviteMessage = (bool condition) => condition ? "Message" : "Invite";

  //SettingScreen
  String chats = "Chats";
  String fromCompany = "From\n$AppName";

  //MapScreen
  String keepOpen = "Keep open";
  String goBack = "Go Back";
  String lastLocation = "Last Location";
  String activeLocation = "Active Location";
  String stoppedLocation = "Location Sharing stopped";
  String stopFromSender = "Sender has Stopped live location.";
  String activlyLocation = "Actively Sharing Location";

  String sharingEnded = "Location Sharing ended";
  String shareLocation = "Share Live Location";

  String sharingStop = "Stop Sharing";
  String nearby = "NearBy Place";
  String sendLocation = "Send your current location";
  String comment = "Comments";



  //
  String comingSoon = "Coming soon";
  String backup = "Backup";
  String backupData = "Backup Data";
  String restore = "Restore";
  String restoreData = "Restore Data";
}

class AppWidget {
  Decoration chatImageDecoration = BoxDecoration(
      image: DecorationImage(
          image: AssetImage(controller.isDarkMode
              ? "assets/background2.jpg"
              : "assets/background4.jpg"),
          fit: BoxFit.cover,
          scale: 1));
}
