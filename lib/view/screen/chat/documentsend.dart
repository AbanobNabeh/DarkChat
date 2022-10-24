import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubitchat/cubit.dart';
import 'package:darkchat/cubit/cubitchat/states.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../model/usermodel.dart';

class DocumentSend extends StatelessWidget {
  var phonenumber;
  var document;
  DocumentSend(this.document, this.phonenumber);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CubitChat()..getuser(phonenumber: phonenumber),
        child: BlocConsumer<CubitChat, StatesChat>(
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: Text(phonenumber),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                          color: isdark(
                              trueco: HexColor("404040"),
                              falseco: HexColor("FFFFFF")),
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            child: Center(
                              child: Icon(
                                NIcons.file_pdf,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: defcolor,
                              borderRadius: BorderRadiusDirectional.vertical(
                                  top: Radius.circular(15)),
                            ),
                          ),
                          deftext(
                              text:
                                  "${Uri.file(document.path).pathSegments.last}",
                              maxlines: 1,
                              overflow: TextOverflow.ellipsis,
                              size: 16,
                              color: defcolor)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: state is UploadDocumentLoading
                ? defCircular()
                : FloatingActionButton(
                    onPressed: () {
                      CubitChat.get(context).uploaddocument(
                          document,
                          phonenumber,
                          context,
                          CubitChat.get(context).userchat['name'],
                          CubitChat.get(context).userchat['image']);
                    },
                    child: Icon(Icons.send),
                    backgroundColor: defcolor,
                  ),
          ),
          listener: (context, state) {},
        ));
  }
}
