import 'package:flutter/material.dart';

enum CommonButtonVariant { primary, secondary, outline, text }

enum CommonButtonSize { small, medium, large }

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CommonButtonVariant variant;
  final CommonButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = CommonButtonVariant.primary,
    this.size = CommonButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(context, theme, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isDisabled) {
    switch (variant) {
      case CommonButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getElevatedButtonStyle(context, theme),
          child: _buildButtonContent(context),
        );
      case CommonButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getSecondaryButtonStyle(context, theme),
          child: _buildButtonContent(context),
        );
      case CommonButtonVariant.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getOutlinedButtonStyle(context, theme),
          child: _buildButtonContent(context),
        );
      case CommonButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: _getTextButtonStyle(context, theme),
          child: _buildButtonContent(context),
        );
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor(context)),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.addAll([
        Icon(icon, size: _getIconSize()),
        SizedBox(width: _getSpacing()),
      ]);
    }

    children.add(Text(text, style: _getTextStyle(context)));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getElevatedButtonStyle(BuildContext context, ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      elevation: 2,
      disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
        alpha: 0.12,
      ),
      disabledForegroundColor: theme.colorScheme.onSurface.withValues(
        alpha: 0.38,
      ),
    );
  }

  ButtonStyle _getSecondaryButtonStyle(BuildContext context, ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      elevation: 1,
      disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
        alpha: 0.12,
      ),
      disabledForegroundColor: theme.colorScheme.onSurface.withValues(
        alpha: 0.38,
      ),
    );
  }

  ButtonStyle _getOutlinedButtonStyle(BuildContext context, ThemeData theme) {
    return OutlinedButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      disabledForegroundColor: theme.colorScheme.onSurface.withValues(
        alpha: 0.38,
      ),
    );
  }

  ButtonStyle _getTextButtonStyle(BuildContext context, ThemeData theme) {
    return TextButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      padding: padding ?? _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
      ),
      disabledForegroundColor: theme.colorScheme.onSurface.withValues(
        alpha: 0.38,
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = _getFontSize();
    final fontWeight = FontWeight.w600;

    switch (variant) {
      case CommonButtonVariant.primary:
      case CommonButtonVariant.secondary:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: theme.colorScheme.onPrimary,
        );
      case CommonButtonVariant.outline:
      case CommonButtonVariant.text:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: theme.colorScheme.primary,
        );
    }
  }

  Color _getLoadingColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case CommonButtonVariant.primary:
      case CommonButtonVariant.secondary:
        return theme.colorScheme.onPrimary;
      case CommonButtonVariant.outline:
      case CommonButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }

  double _getIconSize() {
    switch (size) {
      case CommonButtonSize.small:
        return 16;
      case CommonButtonSize.medium:
        return 20;
      case CommonButtonSize.large:
        return 24;
    }
  }

  double _getFontSize() {
    switch (size) {
      case CommonButtonSize.small:
        return 12;
      case CommonButtonSize.medium:
        return 14;
      case CommonButtonSize.large:
        return 16;
    }
  }

  double _getSpacing() {
    switch (size) {
      case CommonButtonSize.small:
        return 4;
      case CommonButtonSize.medium:
        return 8;
      case CommonButtonSize.large:
        return 12;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case CommonButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CommonButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case CommonButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case CommonButtonSize.small:
        return 6;
      case CommonButtonSize.medium:
        return 8;
      case CommonButtonSize.large:
        return 12;
    }
  }
}
