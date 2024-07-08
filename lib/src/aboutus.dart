import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUs extends StatefulWidget {
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: getHeight(context),
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(8.0).copyWith(bottom: 0),
                  child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 30,
                      )),
                ),

                Container(
                  height: 130,
                  width: 130,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/camp.png"))),
                ),
                Text(
                  "Camp David",
                  style: GoogleFonts.cabin(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                Text(
                  "Version: 1.0",
                  style: GoogleFonts.cabin(fontSize: 14, color: Colors.grey),
                ),
                //Divider(color: Colors.grey,),
                const SizedBox(height: 20),
                Text(
                  "Mission",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "To provide quality food products at competitive prices coupled with excellent customer service by ensuring customers get value for their money with great experience.",
                          style: GoogleFonts.cabin(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Vision",
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "To be a preferred world class meat and meat products processor and cut above the rest way because we treasure our customers and partners.",
                          style: GoogleFonts.cabin(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 8),
                // Divider(color: Colors.grey,),
                const SizedBox(height: 8),
                Text(
                  "Summary",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "           Camp David Butchery is a processor, wholesaler and retailer of meat and meat products. Camp David Butchery is a specialty butcher shop and has been in operation for over five years. The butchery sells a wide menu of meats to customers including medium- and high-income residents, cooperate sectors as well as neighboring towns via deliveries.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "           Camp David Butchery is a meat supplier to the food service catering sector, hospitals, supplying a range of discerning customers, including hotels, pubs and restaurants, nursing and residential homes, schools, universities and corporate caterers.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "           We offer the same butchery skills, standard of product and friendly service alongside the latest technology and an extensive distribution service.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),

                const SizedBox(height: 20),
                Text(
                  "Objective",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "To produce cuts and products of the highest standards with the best service provided.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "To ensure only products from selected suppliers are purchased and offered to clients.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "To meet international standards for quality assurance for our products.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "To establish long-term relationship with direct clients, the hospitality industry and local distribution channels.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Organizational Structure",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "           Camp David Butchery is established as a business company owned by Martin Wanjema Kingori who doubles as the Marketing manager and director. He is a veteran butcher with years of experience in butcher shops and, an experienced retail food-service manager.  He also serves as the CEO of the company.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 20),
                Text(
                  "Corporate Philosophy",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "           Camp David’s Butchery follows these principles in order to achieve success in its market:.",
                        style: GoogleFonts.cabin(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Maintain high quality standards for its suppliers and continuously monitor this quality.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Preserve meats in optimal conditions to maintain freshness while in the Butchery.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Maintain excellence in the skill of butchering meats through hiring, training, and supervision of staff.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Listen carefully to customer needs and respond with custom-cut products, whether in person, over the phone, or through Internet orders.",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_checked,
                        color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Use of high quality machines to package meats, cut meats ,process and delivery",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  "OUR BRANCHES",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_off, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Camp David Butchery – Carwash claycity",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_off, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Camp David Butchery – Kahawa Sukari",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_off, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Camp David Butchery – Entumoto",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_off, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Camp David Butchery – Umoja 3",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_off, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Camp David Butchery – Gumba Estate",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
