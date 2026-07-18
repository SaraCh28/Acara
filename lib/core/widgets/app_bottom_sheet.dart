import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/app_colors.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(DesignTokens.radiusLarge),
        topRight: Radius.circular(DesignTokens.radiusLarge),
      ),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: DesignTokens.s),
              Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withAlpha((0.18 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              SizedBox(height: DesignTokens.m),
              builder(ctx),
            ],
          ),
        ),
      );
    },
  );
}


