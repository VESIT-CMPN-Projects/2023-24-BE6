import 'package:flutter/cupertino.dart';
import '../../../services/auth.dart';
import 'package:flutter/material.dart'
    show
        AppBar,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Colors,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        Icon,
        IconButton,
        Icons,
        InputDecoration,
        PreferredSize,
        Radius,
        RoundedRectangleBorder,
        Row,
        Scaffold,
        Size,
        State,
        StatefulWidget,
        Text,
        TextAlign,
        TextEditingController,
        TextField,
        TextStyle,
        Widget;
import 'package:dialog_flowtter/dialog_flowtter.dart';
// import 'package:flutter_application_1/util/colors.dart';
import 'package:deliveryx/util/colors.dart';
import 'Messages.dart';
import '../eventlogger.dart';

class BotPage extends StatefulWidget {
  const BotPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BotPageState();
  }
}

class _BotPageState extends State<BotPage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final user = await _authService.getCurrentUser();
        EventLogger.logChatbotEvent(
          'low',
          DateTime.now().toString(),
          0,
          'sender',
          'ChatbotCancelled',
          'Chatbot page cancelled',
          {'senderid': user?.uid},
        );
        return true; // Return true to allow the navigation
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: AppBar(
              backgroundColor: AppColors.darkgrey,

              title: const Text('DeliveryX Bot',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22)),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
              centerTitle: true,
              // flexibleSpace: Container(
              //   decoration: BoxDecoration(
              //       image: DecorationImage(
              //           image: AssetImage('assets/mybg.jpg'),
              //           fit: BoxFit.fill
              //       )
              //   ),
              // ),
            ),
          ),
          body: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  Expanded(child: MessagesScreen(messages: messages)),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(25)),
                        color: AppColors.lightwhite.withOpacity(0.8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    // color: AppColors.lightwhite,
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                              hintText: 'Enter a message'),
                          controller: _controller,
                          style: TextStyle(color: AppColors.black),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            sendMessage(_controller.text);
                            _controller.clear();
                          },
                          icon: const Icon(Icons.send))
                    ]),
                  )
                ],
              ))),
    );
  }

  sendMessage(String text) async {
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      final user = await _authService.getCurrentUser();
      EventLogger.logChatbotEvent(
        'low',
        DateTime.now().toString(),
        0,
        'text',
        'text_UserPrompt',
        'User sends prompt',
        {
          'senderid': user?.uid,
          'prompt': text,
        },
      );
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
        print('me bollo');
      });

      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));
      if (response.message == null) return;
      setState(() {
        addMessage(response.message!);
      });

      EventLogger.logChatbotEvent(
        'low',
        DateTime.now().toString(),
        0,
        'text',
        'text_ChatbotResponse',
        'Chatbot sends response',
        {
          'senderid': user?.uid,
          'response': response.message!.text?.text?.join(' ')
        },
      );
    }
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
    print('dialog bolla');
  }
}
