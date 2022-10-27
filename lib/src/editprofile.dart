import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfile extends StatefulWidget {
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: primaryColor,
      body: SizedBox(
        height: getHeight(context),
        width: getWidth(context),
        child: SafeArea(child: Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 30, color: Colors.white,)),
                const SizedBox(width: 10,),
                Text(
                  "Edit User Profile",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                color: Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Name",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10).copyWith(top: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  child: TextFormField(
                    cursorColor: primaryColor,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                    ),
                    maxLength: 10,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: "eg John Doe",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Phone Number",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10).copyWith(top: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  child: TextFormField(
                    cursorColor: primaryColor,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                    ),
                    maxLength: 10,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: " 0*********",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Home Location",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10).copyWith(top: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  child: TextFormField(
                    cursorColor: primaryColor,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                    ),
                    maxLength: 10,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: "eg Nairobi",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Nearest Landmark",
                    style: GoogleFonts.montserrat(),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(10).copyWith(top: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  child: TextFormField(
                    cursorColor: primaryColor,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                    ),
                    maxLength: 10,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(32))),
                      prefixIcon: const Icon(
                        Icons.location_history_rounded,
                        color: Colors.black87,
                      ),
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: "",
                      contentPadding: const EdgeInsets.all(12),
                      hintText: " Landmark",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
              height: 100,
              child: Center(
                child: SizedBox(
                  width: getWidth(context),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: primaryColor,
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Submit",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
                ],
              ),
            ))
          ],
        )),
      ),
    );
  }
}
