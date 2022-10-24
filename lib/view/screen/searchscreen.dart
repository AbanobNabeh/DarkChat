import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/cubit/cubithome/cubit.dart';
import 'package:darkchat/cubit/cubithome/states.dart';
import 'package:darkchat/view/screen/profileuser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchScreen extends StatelessWidget {
  TextEditingController phonenumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var trans = AppLocalizations.of(context)!;
    return BlocConsumer<CubitHome, StatesHome>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              TextFormField(
                cursorColor: Colors.white,
                onChanged: (value) {
                  CubitHome.get(context)
                      .searchuser(phonenumber: phonenumber.text);
                },
                controller: phonenumber,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  label: Text(
                    trans.search,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: defcolor,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
              ),
              deftext(text: trans.searchnote, size: 12),
              search(CubitHome.get(context).search, context, issearch: true)
            ],
          ),
        ),
      ),
      listener: (context, state) {},
    );
  }
}

Widget search(cubit, context, {issearch = false}) => ConditionalBuilder(
    condition: cubit.length > 0,
    builder: (context) => Expanded(
        child: ListView.separated(
            itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    CubitHome.get(context)
                        .getuser(phonenumber: cubit[index]['phonenumber']);
                    navto(
                        context: context,
                        screen: ProfileUserScreen(cubit[index]['phonenumber']));
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(cubit[index]['image']),
                              fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            deftext(text: cubit[index]['name'], size: 16),
                            deftext(
                                text: cubit[index]['phonenumber'],
                                size: 14,
                                fontWeight: FontWeight.normal)
                          ],
                        ),
                      ),
                      deftext(text: cubit[index]['state'], size: 15)
                    ],
                  ),
                ),
            separatorBuilder: (context, index) => defDiv(),
            itemCount: CubitHome.get(context).search.length < 10
                ? CubitHome.get(context).search.length
                : 10)),
    fallback: (context) => issearch
        ? Container()
        : Center(
            child: defCircular(),
          ));
