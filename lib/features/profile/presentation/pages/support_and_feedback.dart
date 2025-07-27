import 'package:app/features/profile/presentation/pages/report_a_problem_screen.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class SupportAndFeedback extends StatefulWidget {
  const SupportAndFeedback({super.key});

  @override
  State<SupportAndFeedback> createState() => _SupportAndFeedbackState();
}

class _SupportAndFeedbackState extends State<SupportAndFeedback> {
  @override
  Widget build(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Support & Feedback",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
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
              children: [
                SizedBox(height: getProportionateScreenHeight(23)),

                _buildMenuItem(title: "Terms and Conditions", onTap: () {}),

                SizedBox(height: getProportionateScreenHeight(23)),

                _buildMenuItem(
                  title: "Report a Problem",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportProblemScreen(),
                      ),
                    );
                  },
                ),

                SizedBox(height: getProportionateScreenHeight(23)),

                _buildMenuItem(title: "Rate Us", onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    final textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(18),
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
