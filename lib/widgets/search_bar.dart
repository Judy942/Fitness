import 'package:flutter/material.dart';

import '../core/utils/app_colors.dart';

class SearchBarRow extends StatelessWidget {
  const SearchBarRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              spreadRadius: 10,
              blurRadius: 15)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 64,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                  ),

                  hintText: 'Search Pancake',
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.whiteColor),
                  ),

                  // filled: true,
                  // fillColor: ColorStyles.f2f2f3,
                ),
              ),
            ),
          ),
          // HorizontalSpace(value: 16, ctx: context),
          InkWell(
            onTap: () {},
            child: Icon(
              Icons.tune,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
