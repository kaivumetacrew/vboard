import 'package:flutter/cupertino.dart';
import 'package:mcboard/board_config.dart';
import 'package:mcboard/board_util.dart';
import 'package:screenshot/screenshot.dart';

import 'board_data.dart';
import 'board_item.dart';
import 'draw_controller.dart';

class BoardController extends ValueNotifier<BoardData> {
  BoardData data;
  BoardItem selectedItem = BoardItem.none;
  Function(BoardItem) onItemTap = (item) {};
  String currentDrawColor = '#000000';
  String currentTextColor = '#000000';
  String? currentFont;
  String? boardImage;
  String? boardColor;
  DrawController drawController = DrawController();
  ValueNotifier<bool> isDrawingNotifier = ValueNotifier(false);
  ScreenshotController screenshotController = ScreenshotController();
  bool get isDrawing => isDrawingNotifier.value;
  double portraitWidth = 0;
  double portraitHeight = 0;
  double landscapeWidth = 0;
  double landscapeHeight = 0;

  BoardController(this.data) : super(data);

  @override
  void dispose() {
    drawController.dispose();
    isDrawingNotifier.dispose();
    super.dispose();
  }

  void removeSelectedItem() {
    remove(selectedItem);
  }

  void remove(BoardItem item) {
    value.items.removeWhere((element) => element == selectedItem);
    notifyListeners();
  }

  void notifyItemsChanged() {
    value.items.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));
    notifyListeners();
  }

  void bringToFront() {
    int index = value.items.indexWhere((element) => element == selectedItem);
    int nextIndex = index + 1;
    if (index >= 0 && nextIndex < value.items.length) {
      BoardItem nextItem = value.items[nextIndex];
      int tempId = selectedItem.lastUpdate;
      selectedItem.lastUpdate = nextItem.lastUpdate;
      nextItem.lastUpdate = tempId;
      notifyItemsChanged();
    }
  }

  void putToBackButton() {
    int index = value.items.indexWhere((element) => element == selectedItem);
    int prevIndex = index - 1;
    if (index >= 0 && prevIndex < value.items.length) {
      final prevItem = value.items[prevIndex];
      int tempId = selectedItem.lastUpdate;
      selectedItem.lastUpdate = prevItem.lastUpdate;
      prevItem.lastUpdate = tempId;
      notifyItemsChanged();
    }
  }

  void setColor(String color) {
    if (isDrawing) {
      currentDrawColor = color;
      drawController.penColor = BoardData.fromHex(color);
      drawController.notifyListeners();
      return;
    }
    if (selectedItem is BoardItemText) {
      currentTextColor = color;
      (selectedItem as BoardItemText).textColor = color;
      notifyListeners();
    }
  }

  void setBackgroundColor(String color) {
    boardColor = color;
    boardImage = null;
notifyListeners();
  }

  void setBackgroundImage(String image) {
    boardColor = null;
    boardImage = image;
    notifyListeners();
  }

  void select(BoardItem item) {
    selectedItem = item;
    notifyListeners();
  }

  void deselectItem() {
    selectedItem = BoardItem.none;
    notifyListeners();
  }

  void startDraw() {
    isDrawingNotifier.value = true;
  }

  void stopDraw() {
    isDrawingNotifier.value = false;
  }

  void addNewItem<T extends BoardItem>(T item, Function(T) block) {
    item.id = DateTime.now().millisecond;
    item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
    item.matrix.scale(0.5);
    item.matrix.translate(
      BoardConfigs.widthDip / 2,
      BoardConfigs.heightDip / 2,
    );
    if (item is BoardItemDraw) {
      item.drawColor = currentDrawColor;
    } else {
      stopDraw();
    }
    if (item is BoardItemText) {
      item.textColor = currentTextColor;
    }
    selectedItem = item;
    block(item);
    value.items.add(item);
    notifyListeners();
  }

  void undoDraw() {
    final item =
        value.items.reversed.firstWhere((element) => element is BoardItemDraw);
    value.items.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }

  Future pickImage() async {
    final file = await BoardUtil.pickImage();
    if (file == null) return;
    addNewItem(BoardItemImage(), (item) {
      item.storagePath = file.path;
    });
  }
}