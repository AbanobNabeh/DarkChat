import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitauth/cubit.dart';
import 'package:darkchat/cubit/cubitauth/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatelessWidget {
  String phonenumber;
  var country;
  var verificationId;
  OTPScreen(this.phonenumber, this.country, this.verificationId);
  TextEditingController otp = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitAuth, StatesAuth>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Text(
                trans.appname,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              SizedBox(
                height: 80,
              ),
              deftext(text: trans.verifynumber, size: 25, color: defcolor),
              deftext(text: trans.otpmessage, size: 15, color: defcolor),
              deftext(
                  text: "$country${phonenumber}", size: 18, color: defcolor),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: PinCodeTextField(
                  controller: otp,
                  appContext: context,
                  length: 6,
                  onChanged: (value) {},
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    errorBorderColor: Colors.red,
                    selectedFillColor: Colors.transparent,
                    activeFillColor: Colors.transparent,
                    inactiveFillColor:
                        isdark(trueco: Colors.grey, falseco: Colors.black38),
                    selectedColor: defcolor,
                    inactiveColor: defcolor,
                    activeColor: defcolor,
                  ),
                  cursorColor: defcolor,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  errorTextSpace: 30,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "err";
                    }
                  },
                  hintStyle: TextStyle(color: defcolor),
                  hintCharacter: "-",
                  animationType: AnimationType.scale,
                ),
              ),
              SizedBox(
                height: 80,
              ),
              state is OTPLoading
                  ? defCircular()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: defbutton(
                          text: trans.verifynumber,
                          ontap: () {
                            CubitAuth.get(context).verotp(
                                verificationId: verificationId,
                                smsCode: otp.text,
                                context: context);
                          }),
                    ),
              SizedBox(
                height: 10,
              ),
              CubitAuth.get(context).timeout == true
                  ? TextButton(
                      onPressed: () {
                        CubitAuth.get(context).resendcode(
                            context: context,
                            phonenumber: phonenumber,
                            countrycode: country);
                      },
                      child: deftext(text: trans.resendcode, size: 16))
                  : SizedBox()
            ],
          ),
        ),
      ),
      listener: (context, state) {},
    );
  }
}
