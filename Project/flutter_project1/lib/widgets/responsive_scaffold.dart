import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// A responsive scaffold that adapts its layout based on screen size
/// Provides a sidebar for desktop and bottom navigation for mobile
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final AppBar? appBar;
  final Color? backgroundColor;
  final FloatingActionButton? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.appBar,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      drawer: isMobile ? drawer : null,
      body: body,
      bottomNavigationBar: isMobile ? bottomNavigationBar : null,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// A responsive container that centers content on large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A responsive grid that adjusts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getGridCrossAxisCount(
      context,
      mobileCount: mobileColumns,
      tabletCount: tabletColumns,
      desktopCount: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: runSpacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Responsive text that adjusts size based on screen
class ResponsiveText extends StatelessWidget {
  final String text;
  final double mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: mobileSize,
      tablet: tabletSize ?? mobileSize * 1.2,
      desktop: desktopSize ?? mobileSize * 1.5,
    );

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A responsive row/column that switches based on screen size
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool reverseOnMobile;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.reverseOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final effectiveChildren = (isMobile && reverseOnMobile) 
        ? children.reversed.toList() 
        : children;

    if (isMobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: effectiveChildren,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: effectiveChildren,
      );
    }
  }
}
