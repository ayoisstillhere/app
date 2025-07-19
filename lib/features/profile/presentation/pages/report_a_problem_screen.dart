import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;

    final textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    final greyTextColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.grey[400]
        : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report A Problem",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(getProportionateScreenHeight(20)),
          child: Container(
            width: double.infinity,
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getProportionateScreenHeight(30)),

                Text(
                  "Report an Issue",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(20),
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(15)),

                Text(
                  "State your issue and we will respond or try to resolve it within 48 hours.",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    color: greyTextColor,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(30)),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _issueController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Write your issue here...",
                      hintStyle: TextStyle(
                        color: greyTextColor,
                        fontSize: getProportionateScreenHeight(16),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(
                        getProportionateScreenWidth(15),
                      ),
                      fillColor: Colors.transparent,
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: getProportionateScreenHeight(16),
                    ),
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(30)),

                SizedBox(
                  width: double.infinity,
                  height: getProportionateScreenHeight(50),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle submit report
                      if (_issueController.text.trim().isNotEmpty) {
                        // Submit logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Report submitted successfully!"),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLightPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Submit Report",
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(16),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
