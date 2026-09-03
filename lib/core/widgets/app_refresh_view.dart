import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef AppLoadMore = Future<bool> Function();

/// The package default is under-damped (damping 16 for mass 2.2 and
/// stiffness 150), which makes the content overshoot after a refresh ends.
/// This value is just above the corresponding critical damping threshold.
const _refreshSpring = SpringDescription(
  mass: 2.2,
  stiffness: 150,
  damping: 36.4,
);

/// Shared pull-to-refresh boundary for scrollable feature content.
///
/// Feature controllers retain ownership of data fetching. This widget only
/// coordinates the refresh controller's visual lifecycle.
class AppRefreshView extends StatefulWidget {
  const AppRefreshView({
    required this.child,
    required this.onRefresh,
    super.key,
    this.onLoading,
    this.controller,
    this.enablePullDown = true,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final AppLoadMore? onLoading;
  final RefreshController? controller;
  final bool enablePullDown;

  @override
  State<AppRefreshView> createState() => _AppRefreshViewState();
}

class _AppRefreshViewState extends State<AppRefreshView> {
  late RefreshController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _configureController();
  }

  @override
  void didUpdateWidget(covariant AppRefreshView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _configureController();
    }
  }

  void _configureController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RefreshController();
  }

  Future<void> _refresh() async {
    try {
      await widget.onRefresh();
      // A previous load may have put the footer into `noMore`. Refreshing
      // replaces the first page, so that terminal state must not survive into
      // the new paging cycle; otherwise load-more is never requested again.
      _controller.refreshCompleted(resetFooterState: true);
    } catch (_) {
      _controller.refreshFailed();
    }
  }

  Future<void> _loadMore() async {
    try {
      final hasMore = await widget.onLoading!();
      hasMore ? _controller.loadComplete() : _controller.loadNoData();
    } catch (_) {
      _controller.loadFailed();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RefreshConfiguration(
    springDescription: _refreshSpring,
    child: SmartRefresher(
      controller: _controller,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.onLoading != null,
      header: ClassicHeader(
        completeText: 'refresh_complete'.tr,
        failedText: 'refresh_failed'.tr,
        refreshingText: 'refresh_refreshing'.tr,
        releaseText: 'refresh_release'.tr,
        idleText: 'refresh_idle'.tr,
      ),
      footer: ClassicFooter(
        loadingText: 'refresh_loading'.tr,
        noDataText: 'refresh_no_more'.tr,
        failedText: 'refresh_load_failed'.tr,
        idleText: 'refresh_load_more'.tr,
      ),
      onRefresh: _refresh,
      onLoading: widget.onLoading == null ? null : _loadMore,
      child: widget.child,
    ),
  );
}
