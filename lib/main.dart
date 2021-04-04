import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Database database = Database(client);

  client
          .setEndpoint(
              'https://10.0.2.2/v1') // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject('606961e26fe69') // Your project ID
          .setSelfSigned() // Do not use this in production
      ;

  runApp(MaterialApp(
    home: Playground(
      client: client,
      account: account,
      storage: storage,
      database: database,
    ),
  ));
}

class Playground extends StatefulWidget {
  Playground(
      {required this.client,
      required this.account,
      required this.storage,
      required this.database});
  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";
  Map<String, dynamic>? user;
  Map<String, dynamic>? uploadedFile;

  @override
  void initState() {
    _getAccount();
    super.initState();
  }

  _getAccount() async {
    try {
      final response = await widget.account.get();
      setState(() {
        username = response.data['name'];
        user = response.data;
      });
    } on AppwriteException catch (error) {
      print(error.message);
      setState(() {
        username = 'Anonymous User';
      });
    }
  }

  _uploadFile() {
    FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false)
        .then((response) {
      if (response == null) return;
      final file = response.files.single;
      if (!kIsWeb) {
        final path = file.path;
        if (path == null) return;
        MultipartFile.fromFile(path, filename: file.name).then((response) {
          widget.storage.createFile(
              file: response,
              read: [user != null ? "user:${user!['\$id']}" : '*'],
              write: ['*']).then((response) {
            print(response);
            setState(() {
              uploadedFile = response.data;
            });
          }).catchError((error) {
            print(error.message);
          }, test: (e) => e is AppwriteException);
        }).catchError((error) {
          print(error.message);
        }, test: (e) => e is AppwriteException);
      } else {
        if (file.path == null) return;
        final uploadFile =
            MultipartFile.fromFileSync(file.path!, filename: file.name);
        widget.storage.createFile(
          file: uploadFile,
          read: [user != null ? "user:${user!['\$id']}" : '*'],
          write: ['*'],
        ).then((response) {
          print(response);
          setState(() {
            uploadedFile = response.data;
          });
        }).catchError((error) {
          print(error.message);
        }, test: (e) => e is AppwriteException);
      }
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Appwrite + Flutter = ❤️"),
          backgroundColor: Colors.pinkAccent[200]),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(20.0)),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text(
                      "Login with Email",
                      style: TextStyle(color: Colors.black, fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.account
                          .createSession(
                              email: 'user@appwrite.io', password: 'password')
                          .then((value) {
                        print(value);
                        _getAccount();
                      }).catchError((error) {
                        print(error.message);
                      }, test: (e) => e is AppwriteException);
                    }),
              ),
              Padding(padding: EdgeInsets.all(20.0)),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text(
                      "Create Doc",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.database
                          .createDocument(
                              collectionId: '5f2e3c52f03c0',
                              data: {'username': 'hello2'},
                              read: ['*'],
                              write: ['*'])
                          .then((value) {})
                          .catchError((error) {
                            print(error.message);
                          }, test: (e) => e is AppwriteException);
                    }),
              ),
              const SizedBox(height: 10.0),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text(
                      "Upload file",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      _uploadFile();
                    }),
              ),
              Padding(padding: EdgeInsets.all(20.0)),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text(
                      "Login with Facebook",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.account
                          .createOAuth2Session(provider: 'facebook')
                          ?.then((value) {
                        widget.account.get().then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        }).catchError((error) {
                          setState(() {
                            username = 'Anonymous User';
                          });
                        }, test: (e) => e is AppwriteException);
                      }).catchError((error) {
                        print(error.message);
                      }, test: (e) => e is AppwriteException);
                    }),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text(
                      "Login with GitHub",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black87,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.account
                          .createOAuth2Session(
                              provider: 'github', success: '', failure: '')
                          ?.then((value) {
                        widget.account.get().then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        }).catchError((error) {
                          print(error.message);
                          setState(() {
                            username = 'Anonymous User';
                          });
                        }, test: (e) => e is AppwriteException);
                      }).catchError((error) {
                        print(error.message);
                      }, test: (e) => e is AppwriteException);
                    }),
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text(
                      "Login with Google",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.account
                          .createOAuth2Session(provider: 'google')
                          ?.then((value) {
                        widget.account.get().then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        }).catchError((error) {
                          print(error.message);
                          setState(() {
                            username = 'Anonymous User';
                          });
                        }, test: (e) => e is AppwriteException);
                      }).catchError((error) {
                        print(error.message);
                      }, test: (e) => e is AppwriteException);
                    }),
              ),
              if (user != null && uploadedFile != null)
                FutureBuilder(
                  future: widget.storage
                      .getFileView(fileId: uploadedFile['\$id']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data.data);
                    }
                    if (snapshot.hasError) {
                      if(snapshot.error is AppwriteException) {
                        print((snapshot.error as AppwriteException).message);
                      }
                      print(snapshot.error);
                    }
                    return CircularProgressIndicator();
                  },
                ),
              Padding(padding: EdgeInsets.all(20.0)),
              Divider(),
              Padding(padding: EdgeInsets.all(20.0)),
              Text(username,
                  style: TextStyle(color: Colors.black, fontSize: 20.0)),
              Padding(padding: EdgeInsets.all(20.0)),
              Divider(),
              Padding(padding: EdgeInsets.all(20.0)),
              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: ElevatedButton(
                    child: Text('Logout',
                        style: TextStyle(color: Colors.white, fontSize: 20.0)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[700],
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.account
                          .deleteSession(sessionId: 'current')
                          .then((response) {
                        setState(() {
                          username = 'Anonymous User';
                        });
                      }).catchError((error) {
                        print(error.message);
                      }, test: (e) => e is AppwriteException);
                    }),
              ),
              Padding(padding: EdgeInsets.all(20.0)),
            ],
          ),
        ),
      ),
    );
  }
}
