// import 'package:firebase_chat_demo/Component/TextView.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // flutter_bloc: ^8.0.1
// class MyState {
//   final int counter;
//
//   const MyState(this.counter);
// }
//
// class MyEvent {
//   final DateTime timeStamp;
//
//   MyEvent({DateTime? timeStamp}) : this.timeStamp = timeStamp ?? DateTime.now();
// }
//
// class Increment extends MyEvent {}
//
// class Decrement extends MyEvent {}
//
// class MyBloc extends Bloc<MyEvent, MyState> {
//   MyBloc(MyState initialState) : super(initialState) {
//     on<Increment>((_, emit) => emit(MyState(state.counter + 1)));
//     on<Decrement>((_, emit) => emit(MyState(state.counter - 1)));
//   }
//
//   void increment() => this.add(Increment());
//
//   void decrement() => this.add(Decrement());
// }
//
// class DummyScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: [
//         BlocBuilder(builder:(context,MyState state) => TextView(label:state.counter.toString() ), bloc: BlocProvider.of<MyBloc>(context),),
//
//         BlocProvider<MyBloc>(
//           create: (context) => MyBloc(const MyState(0)),
//           child: IconButton(
//               icon: Icon(Icons.build),
//               onPressed: () {
//                 BlocProvider.of<MyBloc>(context).increment();
//               }),
//         )
//       ],
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../Storage.dart';
import '../main.dart';

class StateVariable extends ChangeNotifier {
  int _userId = 0;

  int get userId => _userId;

  set userId(int value) {
    _userId = value;
    notifyListeners();
    if (value != null) controller.UserId(_userId);
  }

// UpdateValue({int? newid}) async {
//   if (newid != null) {
//     userId = newid;
//   } else {
//     userId = await MyPrefs.getUserId();
//   }
//   notifyListeners();
//   if (userId != null) controller.UserId(userId);
// }
}

class UserColor extends ChangeNotifier {
  final Brightness appBrightness =
      SchedulerBinding.instance!.window.platformBrightness;

  late bool isDark = (appBrightness == Brightness.dark);
  late Color textColor = isDark ? Colors.white : Colors.black;
  late Color iconColor = isDark ? Colors.white : Colors.black;
  Color themeColor = Color.fromRGBO(11, 139, 131, 1);
  Color white = Colors.white;
  Color grey = Color.fromRGBO(47, 79, 79, 1);
  Color pinkLight = Color.fromRGBO(228, 64, 141, 1);

  late Color tabbarColor = isDark ? themeColor : white;
  late Color chatRowColor =
      isDark ? themeColor : Color.fromRGBO(137, 222, 179, 1);

  late Color themeTransparent = isDark ? Colors.transparent : themeColor;

  void changeDarkMode(bool mode) {
    isDark = mode;
    notifyListeners();
  }
}

class DBRef extends ChangeNotifier {
  FirebaseApp? _app;
  FirebaseStorage? _fireStore;

  DatabaseReference? _reference,
      _ChatListReference,
      _StatusListReference,
      _MessageListReference,
      _UserAccountReference;

  initValues() async {
    print("init");
    _app = await InitFirebaseDatabase();
    _fireStore = await FirebaseStorage.instanceFor(app: _app);
    _reference = FirebaseDatabase(app: _app).reference();
    _ChatListReference = reference.child('ChatList');
    _StatusListReference = reference.child('StatusList');
    _MessageListReference = reference.child('messageview');
    _UserAccountReference = reference.child('UserAccount');
    notifyListeners();
    print("initValues");
    print(UserAccountReference);
  }

  FirebaseApp get app => _app!;

  FirebaseStorage get fireStore => _fireStore!;

  DatabaseReference get reference => _reference!;

  DatabaseReference get MessageListReference => _MessageListReference!;

  DatabaseReference get UserAccountReference => _UserAccountReference!;

  DatabaseReference get ChatListReference => _ChatListReference!;

  DatabaseReference get StatusListReference => _StatusListReference!;

  set app(FirebaseApp value) {
    _app = value;
  }

  set fireStore(FirebaseStorage value) {
    _fireStore = value;
  }

  set UserAccountReference(value) {
    _UserAccountReference = value;
  }

  set StatusListReference(value) {
    _StatusListReference = value;
  }

  set MessageListReference(value) {
    _MessageListReference = value;
  }

  set reference(DatabaseReference value) {
    _reference = value;
  }

  set ChatListReference(value) {
    _ChatListReference = value;
  }
}
