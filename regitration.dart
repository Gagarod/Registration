import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CustomShape extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 32);
    path.quadraticBezierTo(width / 2, height, width, height - 32);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

class registrationForm extends StatefulWidget {
  @override
  _registrationFormState createState() => _registrationFormState();
}

class _registrationFormState extends State<registrationForm> {
  final _formKey = GlobalKey<FormState>();
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Registration");
  TextEditingController emailController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController teamNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  User result = FirebaseAuth.instance.currentUser;
  String name = 'Loading...';
  String email = 'Loading...';
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getname();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // User result = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0.0,
        title: Text(
          'Registration',
          style: TextStyle(
            fontFamily: 'CinzelDecorative',
            fontSize: size.width * 0.095,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          children: [
            ClipPath(
              clipper:
                  CustomShape(), // this is my own class which extendsCustomClipper
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.92,
                    child: TextFormField(
                      readOnly: true,
                      // enabled: false,
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[800],
                        filled: true,
                        icon: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        hintText: name,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter User Name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.92,
                    child: TextFormField(
                      readOnly: true,
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[800],
                        filled: true,
                        icon: Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        hintText: email,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Email Address';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address!';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.92,
                    child: TextFormField(
                        enabled: true,
                        controller: phoneController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[800],
                          filled: true,
                          icon: Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          hintText: "Enter Phone Number",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          return value.length != 10
                              ? "*10 digit phone no."
                              : null;
                        }),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.92,
                    child: TextFormField(
                      enabled: true,
                      controller: teamNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.grey[800],
                        filled: true,
                        icon: Icon(
                          Icons.group_outlined,
                          color: Colors.white,
                        ),
                        hintText: "Enter Team's Name",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter Team's Name";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Container(
                            width: size.width * 0.6,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                // side: BorderSide(color: Colors.white),
                              ),
                              color: Colors.white,
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  registrationInFB();
                                }
                              },
                              child: Text('Register'),
                            ),
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  getname() async {
    await FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(result.uid)
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        name = snapshot.value["name"] as String;
        email = result.email as String;
        emailController.text = email;
        nameController.text = name;
      });
      //print(name);
    });
  }

  registrationInFB() async {
    Size size = MediaQuery.of(context).size;
    var length=size.width<size.height?size.width*0.9:size.height*0.9;
    try {
      await dbRef.child(phoneController.text).set({
        "email": email,
        "name": name,
        "phone": phoneController.text,
        "team's name": teamNameController.text,
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                insetPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                backgroundColor: Colors.transparent,
                elevation: 20,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        height: length*0.9,
                        width: length,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black87,
                                spreadRadius: 0,
                                blurRadius: 15.0,
                                offset: Offset(5.0, 5.0))
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                radius: length*0.25,
                                backgroundColor: Colors.lightBlue,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Registered',
                                        style: TextStyle(color: Colors.white,fontSize:length*0.05),
                                      ),
                                      Text('Successfully',
                                          style: TextStyle(color: Colors.white,fontSize:length*0.05))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            RaisedButton(
                              child: Text('OK',style: TextStyle(color: Colors.white),),
                              color: Colors.blue,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              );
            }).then((value){Navigator.pop(context);});
      });
    } catch (e) {
      isLoading = false;
      print(e);
    }
  }
}
