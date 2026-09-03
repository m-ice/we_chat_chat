import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/home_city_picker_controller.dart';

class HomeCityPickerPage extends GetView<HomeCityPickerController> {
  const HomeCityPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.chevron_left),
        ),
        title: Text(
          'home_city_picker_title'.tr,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SearchBar(
                hintText: 'home_city_search_hint'.tr,
                onChanged: controller.search,
                onSubmitted: controller.search,
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                leading: const Icon(Icons.search),
                constraints: const BoxConstraints(minHeight: 48),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.hasError.value) {
                  return Center(child: Text('home_city_load_failed'.tr));
                }
                return ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: controller.filteredCities.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.separator),
                  itemBuilder: (context, index) {
                    final city = controller.filteredCities[index];
                    return ListTile(
                      minTileHeight: 52,
                      title: Text(
                        city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: controller.selectedCity.value == city
                          ? const Icon(Icons.check, size: 22)
                          : null,
                      onTap: () => controller.select(city),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
