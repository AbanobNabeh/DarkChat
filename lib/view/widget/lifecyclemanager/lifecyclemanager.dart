import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darkchat/constants/link.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../constants/constants.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget? child;
  LifeCycleManager({Key? key, this.child}) : super(key: key);
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      states(state: DateFormat.jm().format(DateTime.now()));
    } else if (state == AppLifecycleState.detached) {
      states(state: DateFormat.jm().format(DateTime.now()));
    } else if (state == AppLifecycleState.paused) {
      states(state: DateFormat.jm().format(DateTime.now()));
    } else if (state == AppLifecycleState.resumed) {
      states(state: "online");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }

  void states({required String state}) {
    FIREUSER.doc(id).update({"state": state});
  }
}
