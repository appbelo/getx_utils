import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pagination/models/paginated_items_response.dart';
import '../utils/main_utils.dart';
import '../widgets/select_list_paginate.dart';
import 'getx_list_item.dart';

class GetXListSelectController<T> {
  final Future<void> Function({bool reset, bool showLoaderOnReset}) fetchPageData;

  final Rx<TextEditingController> _itemController = TextEditingController().obs;
  TextEditingController get itemController => _itemController.value;
  set itemController(TextEditingController value) => _itemController.value = value;

  final Rxn<MapEntry<String, GetXListItem<T>>> _selectEntry = Rxn<MapEntry<String, GetXListItem<T>>>();
  MapEntry<String, GetXListItem<T>>? get selectEntry => _selectEntry.value;
  set selectEntry(MapEntry<String, GetXListItem<T>>? value) => _selectEntry.value = value;

  final Rxn<PaginatedItemsResponse<MapEntry<String, GetXListItem<T>>>> response;

  final TextStyle? titleTextStyle;
  final double? imageSize;

  final Widget defaultItemImage;

  void resetFields() {
    selectEntry = null;
    itemController.text = '';
  }

  void selectItem(MapEntry<String, GetXListItem<T>> item) {
    selectEntry = item;
    itemController.text = item.value.label;
  }

  void showList() {
    Navigator.push<dynamic>(
        appContext!,
        MaterialPageRoute<dynamic>(
            builder: (context) => SelectListPaginate<MapEntry<String, GetXListItem<T>>>(
                onRefresh: () async => fetchPageData(reset: true, showLoaderOnReset: true),
                fetchPageData: (reset) => fetchPageData(reset: reset, showLoaderOnReset: reset),
                response: response,
                itemBuilder: (context, index, item) {
                  return ListTile(
                    leading: item.value.image != null
                        ? Image.asset(
                            item.value.image!,
                            height: imageSize,
                            width: imageSize,
                          )
                        : defaultItemImage,
                    title: Text(
                      item.value.label,
                      style: titleTextStyle,
                    ),
                    onTap: () {
                      selectItem(item);
                      Navigator.of(context).pop(item);
                    },
                  );
                })));
  }

  GetXListSelectController(
      {this.titleTextStyle = const TextStyle(
        fontSize: 18,
      ),
      this.defaultItemImage = const Icon(Icons.list, size: 36),
      this.imageSize = 36,
      required this.fetchPageData,
      required this.response,
      MapEntry<String, GetXListItem<T>>? value}) {
    selectEntry = value;
  }
}
