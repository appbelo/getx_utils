import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'getx_text_controller.dart';

class GetXItemListController {
  final RxList<Map<String, String>> _items = <Map<String, String>>[].obs;
  List<Map<String, String>> get items => _items;
  set items(List<Map<String, String>> value) => _items.assignAll(value);

  final formKey = GlobalKey<FormState>();
  final GetXTextController<String> itemName = GetXTextController<String>();
  final GetXTextController<String> itemNumber = GetXTextController<String>();

  Map<String, String> addItem(String name, String item) {
    var valor = {
      'name': name,
      'item': item,
    };
    items.add(valor);
    return valor;
  }

  void resetFields() {
    itemName.setData('');
    itemNumber.setData('');
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void setData(List<Map<String, String>>? list) {
    items.addAll(list ?? []);
  }

  GetXItemListController();
}
