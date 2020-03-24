import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:handover_app/enum/view_state.dart';
// import 'package:flutter/scheduler.dart';
import 'package:handover_app/models/message_model.dart';
import 'package:handover_app/models/user_model.dart';
import 'package:handover_app/provider/image_upload_provider.dart';
import 'package:handover_app/services/database_service.dart';
import 'package:handover_app/services/firebase_repository.dart';
import 'package:handover_app/utils/utilities.dart';
import 'package:handover_app/widgets/cached_image.dart';
import 'package:handover_app/widgets/custom_tile.dart';
import 'package:handover_app/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String profileImageUrl;
  final String name;
  final String receiverUid;
  final User sender;
  final User receiver;
  final String userId;

  ChatScreen(
      {this.profileImageUrl,
      this.name,
      this.receiverUid,
      this.sender,
      this.receiver,
      this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();

  ScrollController _listScrollController = ScrollController();

  String receiverPhotoUrl,
      senderPhotoUrl,
      receiverName,
      senderName,
      profileImageUrl;

  ImageUploadProvider _imageUploadProvider;

  User sender;

  User receiver;

  String _currentUserId;

  FocusNode textFeildFocus = FocusNode();

  bool isWriting = false;

  bool showEmojiPicker = false;

  // @override
  // void initState() {
  //   super.initState();
  //   print("RCID : ${widget.receiverUid}");
  //   _repository.getCurrentUser().then((user) {
  //     setState(() {
  //       _senderuid = user.uid;
  //     });
  //     _repository.fetchUserDetailsById(_senderuid).then((user) {
  //       setState(() {
  //         senderPhotoUrl = user.profileImageUrl;
  //         senderName = user.name;
  //       });
  //     });
  //     _repository.fetchUserDetailsById(widget.receiverUid).then((user) {
  //       setState(() {
  //         receiverPhotoUrl = user.profileImageUrl;
  //         receiverName = user.name;
  //       });
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();

    _repository.getCurrentUser().then((user) {
      _currentUserId = user.uid;
      setState(() {
        sender = User(
            id: user.uid,
            name: user.displayName,
            profileImageUrl: user.photoUrl);
      });
    });
    _setupProfileUser();
  }

  _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      receiver = profileUser;
    });
  }

  showKeyboard() => textFeildFocus.requestFocus();

  hideKeuboard() => textFeildFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.4,
        backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 42, 0, 0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: widget.receiver.profileImageUrl.isEmpty
                          ? AssetImage(
                              'assets/images/default_profile_picture.png')
                          : CachedNetworkImageProvider(
                              widget.receiver.profileImageUrl)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.receiver.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.videocam,
              size: 40,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.phone,
              size: 35,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15),
                  child: CircularProgressIndicator(),
                )
              : Container(),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer()) : Container(),
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: Colors.white,
      indicatorColor: Colors.blue,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(_currentUserId)
          .collection(widget.receiver.id)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        // When user types a message the screen will revert back
        // to the most recent message
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //     duration: Duration(milliseconds: 250),
        //     curve: Curves.easeInOut,
        //     );
        // });

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          reverse: true,
          controller: _listScrollController,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  sendMessage() {
    var text = textFieldController.text;

    Message _message = Message(
      receiverId: widget.receiver.id,
      senderId: sender.id,
      message: text,
      timestamp: Timestamp.now(),
      type: 'text',
    );

    setState(() {
      isWriting = false;
    });

    textFieldController.text = "";

    _repository.addMessageToDb(_message, sender, widget.receiver);
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _repository.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.id,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message.message,
            style: TextStyle(color: Colors.white, fontSize: 20),
          )
        : message.photoUrl != null
            ? CachedImage(url: message.photoUrl)
            : Text("Url was null");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(padding: EdgeInsets.all(10), child: getMessage(message)),
    );
  }

  Widget chatControls() {
    setWritingTo(bool value) {
      setState(() {
        isWriting = value;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Colors.grey[700],
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content and tools",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                          title: "File",
                          subtitle: "Share files",
                          icon: Icons.tab),
                      ModalTile(
                          title: "Contact",
                          subtitle: "Share contacts",
                          icon: Icons.contacts),
                      ModalTile(
                          title: "Location",
                          subtitle: "Share a location",
                          icon: Icons.add_location),
                      ModalTile(
                          title: "Schedule Call",
                          subtitle: "Arrange a skype call and get reminders",
                          icon: Icons.schedule),
                      ModalTile(
                          title: "Create Poll",
                          subtitle: "Share polls",
                          icon: Icons.poll)
                    ],
                  ),
                ),
              ],
            );
          });
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(children: <Widget>[
        GestureDetector(
          onTap: () => addMediaModal(context),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.black),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: textFieldController,
                focusNode: textFeildFocus,
                onTap: () => hideEmojiContainer(),
                style: TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  (value.length > 0 && value.trim() != "")
                      ? setWritingTo(true)
                      : setWritingTo(false);
                },
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(50),
                      ),
                      borderSide: BorderSide.none),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  if (!showEmojiPicker) {
                    // keyboard is visable
                    hideKeuboard();
                    showEmojiContainer();
                  } else {
                    //keyboard is hidden
                    showKeyboard();
                    hideEmojiContainer();
                  }
                },
                icon: Icon(
                  Icons.face,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        isWriting
            ? Container()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.mic,
                  size: 36,
                ),
              ),
        isWriting
            ? Container()
            : GestureDetector(
                onTap: () => pickImage(source: ImageSource.camera),
                child: Icon(
                  Icons.camera_alt,
                  size: 32,
                ),
              ),
        isWriting
            ? Container(
                margin: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    size: 30,
                  ),
                  onPressed: () => sendMessage(),
                ))
            : Container()
      ]),
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: onTap,
        mini: false,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.black,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
