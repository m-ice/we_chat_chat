import 'dart:async';
import 'package:draggable_float_widget/draggable_float_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum SlideInstantly {
  /// 滑动
  slide,

  /// 即时
  instantly,
}

class CommonDraggableFloatWidget extends StatelessWidget {
  final Widget child;
  final Widget listView;
  final double width;
  final double height;
  final double borderBottom;
  final double borderTop;
  final double borderLeft;
  final double borderRight;
  final double initPositionYMarginBorder;
  final SlideInstantly slideInstantly;
  final bool isFullScreen;
  final bool initPositionYInTop;
  final StreamController<OperateEvent> eventStreamController;
  final Function()? onTap;
  const CommonDraggableFloatWidget({
    super.key,
    required this.child,
    required this.listView,
    required this.eventStreamController,
    this.width = defaultWidgetWidth,
    this.height = defaultWidgetHeight,
    this.borderBottom = 50,
    this.borderTop = 0,
    this.borderLeft = 2,
    this.borderRight = 2,
    this.initPositionYMarginBorder = 50,
    this.slideInstantly = SlideInstantly.slide,
    this.isFullScreen = false,
    this.initPositionYInTop = false,
    this.onTap,
  });

  bool slideToTriggerInstantly(notification) {
    switch (slideInstantly) {
      case SlideInstantly.slide:
        return slide(notification);
      case SlideInstantly.instantly:
        return instantly(notification);
    }
  }

  bool slide(notification) {
    // 只处理用户手势滚动，不处理 EasyRefresh 动画
    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          // reverse = 向下滑动（内容向上走）→ 隐藏
          eventStreamController.add(OperateEvent.OPERATE_HIDE);
          break;

        case ScrollDirection.forward:
          // forward = 向上滑动（内容向下走）→ 显示
          eventStreamController.add(OperateEvent.OPERATE_SHOW);
          break;

        case ScrollDirection.idle:
          // 停止不处理也行
          break;
      }
    }
    if (notification is ScrollEndNotification) {
      // 下滑停止 → 显示
      // 注意：无需判断 direction，停止本身就意味着需要显示
      eventStreamController.add(OperateEvent.OPERATE_SHOW);
    }
    return false;
  }

  bool instantly(notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      if (direction == ScrollDirection.idle) {
        // 空闲时显示
        eventStreamController.add(OperateEvent.OPERATE_SHOW);
      } else {
        // 正在向上/向下滚动时隐藏
        eventStreamController.add(OperateEvent.OPERATE_HIDE);
      }
      return true;
    }
    // 仅响应用户手势的垂直滚动
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      eventStreamController.add(OperateEvent.OPERATE_HIDE);
    } else if (notification is ScrollEndNotification &&
        notification.dragDetails != null) {
      eventStreamController.add(OperateEvent.OPERATE_SHOW);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // 忽略横向滚动（比如 TabView）
            if (notification.metrics.axis == Axis.horizontal) return false;
            slideToTriggerInstantly(notification);
            return false;
          },
          child: listView,
        ),
        Positioned.fill(
          child: _DraggableFloatOverlay(
            width: width,
            height: height,
            borderBottom: borderBottom,
            borderTop: borderTop,
            borderLeft: borderLeft,
            borderRight: borderRight,
            initPositionYMarginBorder: initPositionYMarginBorder,
            initPositionYInTop: initPositionYInTop,
            isFullScreen: isFullScreen,
            eventStreamController: eventStreamController,
            onTap: onTap,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _DraggableFloatOverlay extends StatefulWidget {
  const _DraggableFloatOverlay({
    required this.width,
    required this.height,
    required this.borderBottom,
    required this.borderTop,
    required this.borderLeft,
    required this.borderRight,
    required this.initPositionYMarginBorder,
    required this.initPositionYInTop,
    required this.isFullScreen,
    required this.eventStreamController,
    required this.child,
    this.onTap,
  });

  final double width;
  final double height;
  final double borderBottom;
  final double borderTop;
  final double borderLeft;
  final double borderRight;
  final double initPositionYMarginBorder;
  final bool initPositionYInTop;
  final bool isFullScreen;
  final StreamController<OperateEvent> eventStreamController;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_DraggableFloatOverlay> createState() => _DraggableFloatOverlayState();
}

class _DraggableFloatOverlayState extends State<_DraggableFloatOverlay> {
  StreamSubscription<OperateEvent>? _subscription;
  Offset? _position;
  Size? _layoutSize;
  var _visible = true;
  var _dragging = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.eventStreamController.stream.listen((event) {
      final visible = event == OperateEvent.OPERATE_SHOW;
      if (visible == _visible || !mounted) return;
      setState(() => _visible = visible);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final topInset = widget.isFullScreen
            ? MediaQuery.paddingOf(context).top
            : 0.0;
        final bottomInset = widget.isFullScreen
            ? MediaQuery.paddingOf(context).bottom
            : 0.0;
        final minX = widget.borderLeft;
        final maxX = (size.width - widget.width - widget.borderRight).clamp(
          minX,
          double.infinity,
        );
        final minY = widget.borderTop + topInset;
        final maxY =
            (size.height - widget.height - widget.borderBottom - bottomInset)
                .clamp(minY, double.infinity);

        if (_position == null || _layoutSize != size) {
          _layoutSize = size;
          _position = Offset(
            _position?.dx.clamp(minX, maxX) ?? maxX,
            _position?.dy.clamp(minY, maxY) ??
                (widget.initPositionYInTop
                    ? (minY + widget.initPositionYMarginBorder).clamp(
                        minY,
                        maxY,
                      )
                    : (maxY - widget.initPositionYMarginBorder).clamp(
                        minY,
                        maxY,
                      )),
          );
        }

        final position = _position!;
        final hiddenX = position.dx <= size.width / 2
            ? -widget.width + 5
            : size.width - 5;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              left: _visible ? position.dx : hiddenX,
              top: position.dy,
              width: widget.width,
              height: widget.height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                onPanStart: (_) => setState(() => _dragging = true),
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      (position.dx + details.delta.dx).clamp(minX, maxX),
                      (position.dy + details.delta.dy).clamp(minY, maxY),
                    );
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _dragging = false;
                    _position = Offset(
                      _position!.dx + widget.width / 2 < size.width / 2
                          ? minX
                          : maxX,
                      _position!.dy,
                    );
                  });
                },
                child: Center(child: widget.child),
              ),
            ),
          ],
        );
      },
    );
  }
}
