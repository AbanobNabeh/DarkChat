import 'package:darkchat/cubit/cubitauth/cubit.dart';
import 'package:darkchat/cubit/cubitauth/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../constants/constants.dart';
import '../../../constants/network/cachhelper.dart';

class PhoneNumberScreen extends StatelessWidget {
  TextEditingController phonenumber = TextEditingController();
  String initial = "eg";
  var formstate = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitAuth, StatesAuth>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  Text(
                    trans.appname,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Text(
                    trans.phonenumber,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(
                    trans.addphonenumber,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 40),
                  IntlPhoneField(
                    onTap: () {
                      CacheHelper.saveData(key: "theme", value: false);
                    },
                    onCountryChanged: (value) {
                      CubitAuth.get(context).country = value.code;
                    },
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.enterphone,
                            backgroundColor: Colors.red);
                      } else {
                        CubitAuth.get(context).phonenumberlogin(
                            context: context, phonenumber: phonenumber.text);
                      }
                    },
                    controller: phonenumber,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: trans.phonenumber,
                      labelStyle: TextStyle(
                          color: isdark(
                              trueco: HexColor('1A1A1A'),
                              falseco: Colors.white)),
                      fillColor:
                          theme == true ? Colors.grey.withOpacity(0.3) : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: HexColor('F4A135'),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: HexColor('F4A135'),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: HexColor('F4A135'),
                        ),
                      ),
                    ),
                    initialCountryCode: 'EG',
                    cursorColor: HexColor('F4A135'),
                    dropdownTextStyle: TextStyle(
                        color: isdark(
                            trueco: HexColor('1A1A1A'), falseco: Colors.white)),
                    style: TextStyle(
                        color: isdark(
                            trueco: HexColor('1A1A1A'), falseco: Colors.white)),
                  ),
                  SizedBox(height: 40),
                  state is phonenumberLoading
                      ? defCircular()
                      : defbutton(
                          text: trans.submit,
                          ontap: () {
                            if (phonenumber.text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)!.enterphone,
                                  backgroundColor: Colors.red);
                            } else {
                              CubitAuth.get(context).phonenumberlogin(
                                  context: context,
                                  phonenumber: phonenumber.text);
                            }
                          }),
                ],
              ),
            ),
          ),
        ),
      ),
      listener: (context, state) {},
    );
  }
}
