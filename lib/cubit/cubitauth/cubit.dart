import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/constants/link.dart';
import 'package:darkchat/constants/network/cachhelper.dart';
import 'package:darkchat/cubit/cubitauth/states.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/model/modelprofile.dart';
import 'package:darkchat/view/screen/auth/completingaccount.dart';
import 'package:darkchat/view/screen/auth/otpscreen.dart';
import 'package:darkchat/view/screen/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CubitAuth extends Cubit<StatesAuth> {
  CubitAuth() : super(initAuthState());
  static CubitAuth get(context) => BlocProvider.of(context);

  //PhoneNumber Auth
  var country = "+20";
  bool timeout = false;
  phonenumberlogin({
    required BuildContext context,
    required String phonenumber,
  }) async {
    emit(phonenumberLoading());
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$country$phonenumber',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        switch (e.code) {
          case "invalid-phone-number":
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.phonenumbererro);
            break;
          case "invalid-phone-number":
            Fluttertoast.showToast(msg: AppLocalizations.of(context)!.spam);
            break;
          default:
            print("This E Code${e.code}");
            Fluttertoast.showToast(msg: e.toString());
        }
        print("error ${e.toString()}");
        emit(verificationFailed());
      },
      codeSent: (String verificationId, int? resendToken) {
        navof(
            context: context,
            screen: OTPScreen(phonenumber, country, verificationId));
        emit(codeSent());
      },
      timeout: const Duration(seconds: 30),
      codeAutoRetrievalTimeout: (String verificationId) {
        timeout = true;
        emit(codeAutoRetrievalTimeout());
      },
    );
  }

  resendcode({
    required BuildContext context,
    required String phonenumber,
    required String countrycode,
  }) async {
    emit(phonenumberLoading());
    timeout = false;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$countrycode$phonenumber',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        switch (e.code) {
          case "invalid-phone-number":
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.phonenumbererro);
            break;
          case "invalid-phone-number":
            Fluttertoast.showToast(msg: AppLocalizations.of(context)!.spam);
            break;
          default:
            print("This E Code${e.code}");
            Fluttertoast.showToast(msg: e.toString());
        }
        emit(verificationFailed());
      },
      codeSent: (String verificationId, int? resendToken) {
        emit(codeSent());
      },
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: (String verificationId) {
        timeout = true;
        emit(codeAutoRetrievalTimeout());
      },
    );
  }

  verotp({
    required String verificationId,
    required String smsCode,
    required BuildContext context,
  }) {
    emit(OTPLoading());
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    FirebaseAuth.instance.signInWithCredential(credential).then((valueu) {
      FIREUSER.doc(valueu.user!.phoneNumber).get().then((value) async {
        if (value.data() == null) {
          navof(
              context: context,
              screen: CompletingAccountScreen(valueu.user!.phoneNumber));
        } else {
          id = valueu.user!.phoneNumber.toString();
          await await CubitHome.get(context)
              .getProfile(phonenumber: valueu.user!.phoneNumber.toString());
          FirebaseMessaging.instance.getToken().then((val) {
            FIREUSER.doc(valueu.user!.phoneNumber).update({"token": val});
            CacheHelper.saveData(
                key: "id", value: valueu.user!.phoneNumber.toString());
            navof(context: context, screen: HomePage());
          });
        }
      });
      emit(OTPSuccess());
    }).catchError((error) {
      switch (error.code) {
        case "invalid-verification-code":
          Fluttertoast.showToast(msg: AppLocalizations.of(context)!.otpe);
          break;
        default:
          print("This E Code${error.code}");
          Fluttertoast.showToast(msg: error.toString());
      }
      print(error.code);
      emit(OTPError());
    });
  }

  //End

  //UploadProfileInfo
  requestPermissionpost() {
    Permission.storage.request().then((status) {
      print(status);
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else if (status.isGranted) {
        selectImage();
      }
    });
  }

  File? image;
  final ImagePicker pickerimage = ImagePicker();
  Future<void> selectImage() async {
    final cover = await pickerimage.pickImage(source: ImageSource.gallery);
    if (cover != null) {
      image = File(cover.path);
      emit(ImageSuccess());
    } else {
      print('No Image Selected');
      emit(ImageError());
    }
  }

  uploadimage({
    required String name,
    required String email,
    required String barthday,
    required String bio,
    required String phonenumber,
    required BuildContext context,
  }) {
    emit(UploadProfileLoading());
    STOAGEUSER
        .child("$phonenumber/${Uri.file(image!.path).pathSegments.last}")
        .putFile(image!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        uploadprofile(
            name: name,
            email: email,
            barthday: barthday,
            bio: bio,
            phonenumber: phonenumber,
            image: value,
            context: context);
      });
    }).catchError((error) {});
  }

  ModelProfile? modelProfile;
  uploadprofile({
    required String name,
    required String email,
    required String barthday,
    required String bio,
    required String phonenumber,
    required String image,
    required BuildContext context,
  }) {
    List<String> searchcase = [];
    List<String> number = phonenumber.split(" ");
    for (int i = 0; i < number.length; i++) {
      for (int y = 1; y < number[i].length + 1; y++) {
        searchcase.add(number[i].substring(0, y).toLowerCase());
      }
    }
    ModelProfile model = ModelProfile(
        name: name,
        bio: bio,
        date: barthday,
        email: email,
        phonenumber: phonenumber,
        private: false,
        sarahah: true,
        searchcase: searchcase,
        state: "online",
        image: image,
        token: null,
        block: []);
    FIREUSER.doc(phonenumber).set(model.toMap()).then((value) async {
      id = phonenumber;
      await CubitHome.get(context).getProfile(phonenumber: phonenumber);
      FirebaseMessaging.instance.getToken().then((val) {
        FIREUSER.doc(phonenumber).update({"token": val});
        CacheHelper.saveData(key: "id", value: phonenumber);
        navof(context: context, screen: HomePage());
      });
      emit(UploadProfileSuccess());
    }).catchError((error) {
      emit(UploadProfileError());
    });
  }
  //End

}
