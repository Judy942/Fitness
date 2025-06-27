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
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                ),
                hintText: 'Search Pancake',
                hintStyle: TextStyle(
                  color: AppColors.blackColor.withOpacity(0.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.whiteColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.whiteColor),
                ),
              ),
            ),
          ),
          // HorizontalSpace(value: 16, ctx: context),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () {},
              child: const Icon(
                Icons.tune,
                color: AppColors.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
