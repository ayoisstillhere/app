import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({super.key});

  @override
  State<TwoStepVerificationScreen> createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  String _selectedMethod = 'SMS'; // Default selection

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
          "Two-Step Verification",
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
                  "Protect your account",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(20),
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(15)),

                Text(
                  "Set Up two-factor verification and we'll send you a notification to check its you if someomne logs in from a different device",
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    color: greyTextColor,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: getProportionateScreenHeight(40)),

                // SMS Option
                _buildVerificationOption(
                  title: "SMS",
                  isSelected: _selectedMethod == 'SMS',
                  onTap: () {
                    setState(() {
                      _selectedMethod = 'SMS';
                    });
                  },
                ),

                SizedBox(height: getProportionateScreenHeight(30)),

                // WhatsApp Option
                _buildVerificationOption(
                  title: "Whatsapp",
                  isSelected: _selectedMethod == 'Whatsapp',
                  onTap: () {
                    setState(() {
                      _selectedMethod = 'Whatsapp';
                    });
                  },
                ),

                SizedBox(height: getProportionateScreenHeight(50)),

                SizedBox(
                  width: double.infinity,
                  height: getProportionateScreenHeight(50),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle setup two-step verification
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Two-step verification set up via $_selectedMethod",
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLightPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Set Up Verification",
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

  Widget _buildVerificationOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: getProportionateScreenHeight(18),
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          Container(
            width: getProportionateScreenWidth(24),
            height: getProportionateScreenWidth(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? kLightPurple : Colors.grey,
                width: 2,
              ),
              color: isSelected ? kLightPurple : Colors.transparent,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: getProportionateScreenWidth(16),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
