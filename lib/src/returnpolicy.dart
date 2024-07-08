import 'package:campdavid/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReturnPolicy extends StatefulWidget {
  _ReturnPolicyState createState() => _ReturnPolicyState();
}

class _ReturnPolicyState extends State<ReturnPolicy> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: getHeight(context),
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
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
                    Text(
                      "Return Policy",
                      style: GoogleFonts.cabin(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                
                Text(
                  "Summary",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),
                const SizedBox(height: 12),
                RichText(
                    text: TextSpan(
                  text:
                      "If you are unhappy with the quality of your perishable food product, you must contact The Butchery customer representatives within 2 hours of your order delivery date. If your package arrives warm to the touch or damaged/incorrect, you must contact The Butchery Customer Service Representatives by the end of business (8pm) on the same day your package arrives via sales@campdavidbutchery.com. You will be provided a tracking number so you know what time and date the package was shipped.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                RichText(
                    text: TextSpan(
                  text:
                      "Do not return your perishable food item without specific instructions from a Customer Service Representative from The Butchery, which can be reached via sales@campdavidbutchery.com. ",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                RichText(
                    text: TextSpan(
                  text:
                      "Several types of goods are exempt from being returned. Perishable goods such as meat, food, grocery or drinks cannot be returned. We also do not accept products that are intimate or sanitary goods, hazardous materials, or flammable liquids or gases.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),

                const SizedBox(height: 20),
                Text(
                  "Additional non-returnable items:",
                  style:
                      GoogleFonts.montserrat(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  "Gift cards",
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: primaryColor),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Refunds (if applicable)",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "Once your order issue is communicated and addressed, we will send you an email to notify you that we approved your refund. We reserve the right to limit all replacements or refunds.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "f you are approved, then your refund will be processed, and a credit will automatically be applied to your credit card or original method of payment, within a certain amount of days.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Late or missing refunds (if applicable)",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "If you haven’t received a refund yet, first check your bank account again.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "Then contact your credit card company, it may take some time before your refund is officially posted.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "Next contact your bank. There is often some processing time before a refund is posted.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "If you’ve done all of this and you still have not received your refund yet, please contact us at sales@campdavidbutchery.com. ",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Sale items (if applicable)",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "Only regular priced items may be refunded, unfortunately sale items cannot be refunded.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Exchanges (if applicable)",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "We only replace items if they are defective or damaged.  If you need to exchange it for the same item, send us an email at sales@campdavidbutchery.com by the end of business (8pm) on the day your package arrives. Await for authorization before returning any item, whether perishable or non-perishable, to: camp david butchery",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Gifts",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "If the item was marked as a gift when purchased and shipped directly to you, you’ll receive a gift credit for the value of your return. Once the returned item is received, a gift certificate will be mailed to you.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "If the item wasn’t marked as a gift when purchased, or the gift giver had the order shipped to themselves to give to you later, we will send a refund to the gift giver and he will find out about your return.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Shipping",
                        style: GoogleFonts.cabin(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "You must be authorized by a Customer Service Representative to return any product from The Butchery, whether it be perishable or non-perishable. If approved, to return your product you should mail your product to:Camp David butchery warehouse ",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "You will be responsible for paying for your own shipping costs for returning your item. Shipping costs are non-refundable. If you receive a refund, the cost of return shipping will be deducted from your refund.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "Depending on where you live, the time it may take for your exchanged product to reach you, may vary.",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                const SizedBox(height: 8),
                RichText(
                    text: TextSpan(
                  text:
                      "If you are shipping an item over 75, you should consider using a trackable shipping service or purchasing shipping insurance. We don’t guarantee that we will receive your returned item",
                  style: GoogleFonts.montserrat(
                      fontSize: 14, color: Colors.black87),
                )),
                
                const SizedBox(height: 20),
              
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
