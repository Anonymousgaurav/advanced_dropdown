import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drop_down/model/text_decoration_model.dart';
import 'package:flutter_advanced_drop_down/widget/text_widget.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../model/drop_down_decoration_model.dart';
import '../util/utils.dart';
import 'button_widget.dart';
import 'icon_widget.dart';


class AdvancedDropDownSelectWidget extends StatefulWidget {
  const AdvancedDropDownSelectWidget({
    required key,
    this.isReadOnly = false,
    this.initiallySelectedItem,
    this.formKey,
    required this.isMandatory,
    this.validationFailedDecoration,
    required this.itemList,
    this.mandatoryIndicatorColor,
    required this.onChanged,
    this.showLabel = false,
    this.showError = false,
    this.showErrorBorder = false,
    this.errorBorderColor,
    this.lableTextDecoration,
    this.decoration,
    this.initiallySelectedItemsList,
    this.onClear,
    this.showCloseIcon = true,
    this.dropDownButtonPadding =
    const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
    this.isMulti = true,
    this.showSelectedValueInHint = false,
    this.spaceBetweenIconAndSelectedItems = 6,
    this.dropdownStatus,
    this.hintText = "Search",
    this.showSearchIcon,
    this.isAddOnly = false,
    this.defaultLabelText = "",
    this.labelTextDecoration,
    this.showSelectAll = false,
  });

  final bool isReadOnly;
  final bool isMulti;
  final String? initiallySelectedItem;
  final GlobalKey<FormState>? formKey;
  final bool isMandatory;
  final List<String> itemList;
  final Color? mandatoryIndicatorColor;
  final Function onChanged;
  final bool showLabel;
  final bool showError;
  final bool showErrorBorder;
  final Color? errorBorderColor;
  final TextDecorationModel? lableTextDecoration;
  final TextDecorationModel? validationFailedDecoration;
  final DropDownDecorationModel? decoration;
  final List<String>? initiallySelectedItemsList;
  final Function? onClear;
  final EdgeInsets dropDownButtonPadding;
  final bool showSelectedValueInHint;
  final double spaceBetweenIconAndSelectedItems;
  final bool showCloseIcon;
  final Function(bool)? dropdownStatus;
  final String hintText;
  final bool? showSearchIcon;
  final bool isAddOnly;
  final String defaultLabelText;
  final TextDecorationModel? labelTextDecoration;
  final bool showSelectAll;

  @override
  State<AdvancedDropDownSelectWidget> createState() =>
      AdvancedDropDownSelectWidgetState();
}

class AdvancedDropDownSelectWidgetState
    extends State<AdvancedDropDownSelectWidget> with WidgetsBindingObserver {
  final RxBool _showValidationFailedWidget = false.obs;
  final RxBool _isMenuOpen = false.obs;
  final RxString _selectedItem = "".obs;
  GlobalKey dropDownKey = GlobalKey();

  RxList<String> selectedItems = <String>[].obs;
  final RxBool _hoveringClose = false.obs;
  final RxMap<String, RxBool> menuItemHoverStates = <String, RxBool>{}.obs;
  final RxBool _hoverField = false.obs;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _globalKey = GlobalKey();
  double previousScreenWidth = 0;
  double previousScreenHeight = 0;
  final GlobalKey _scrollKey = GlobalKey();
  int previousSelectedCount = 0;
  late Color canvasColor;
  List<String>? initialList;
  RxList<String> currentSelected = <String>[].obs;

  final TextEditingController _searchTextEditingController =
  TextEditingController();

  TextEditingController get getSearchTextEditingController {
    return _searchTextEditingController;
  }

  final RxList<String> _filterItemsList = <String>[].obs;

  List<String> get getFilterItemsList => _filterItemsList;

  @override
  void initState() {
    initialList = widget.itemList;
    updateFilteredItems(widget.itemList);

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getSearchTextEditingController.addListener(_onSearchChanged);
      _selectedItem(widget.initiallySelectedItem ?? "");
      canvasColor =
          widget.decoration?.fieldColor ?? Theme.of(context).canvasColor;
      if (widget.initiallySelectedItemsList != null) {
        selectedItems.value = widget.initiallySelectedItemsList!;
      }
    });
    _selectedItem.value = widget.initiallySelectedItem ?? "";
    _isMenuOpen.value = false;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void deactivate() {
    _searchTextEditingController.dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (isMenuOpen()) {
      _overlayEntry?.remove();
      _isMenuOpen.value = false;
    }
    if (_overlayEntry != null) {
      _overlayEntry?.dispose();
      _overlayEntry = null;
    }

    super.dispose();
  }

  void updateFilteredItems(List<String> items) {
    setState(() {
      _filterItemsList.clear();
      _filterItemsList.addAll(items);
    });
  }

  clearSearchText() {
    _searchTextEditingController.clear();
  }

  void _onSearchChanged() {
    String searchText = getSearchTextEditingController.text.toLowerCase();

    updateFilteredItems(widget.itemList
        .where((item) =>
    item.toLowerCase().contains(searchText) &&
        (!widget.isAddOnly || !selectedItems.contains(item)))
        .toList());
  }

  void removeSelectedItem(String item) {
    setState(() {
      selectedItems.remove(item);
      if (widget.isAddOnly) {
        _filterItemsList.clear();
        for (String item in widget.itemList) {
          if (!selectedItems.contains(item)) {
            _filterItemsList.add(item);
          }
        }
      }
    });
  }

  void _fillCurrentSelected() {
    if (widget.isAddOnly) {
      currentSelected.clear();
    } else {
      currentSelected.value = List.from(selectedItems);
    }
  }

  Widget _selectedItemBuilderSingle() {
    return Padding(
      padding: EdgeInsets.only(
        left: getSize(widget.dropDownButtonPadding.left),
      ),
      child: Text(
        _selectedItem.value,
        style: TextStyle(
          fontSize: getSize(widget.decoration?.textStyle?.fontSize ?? 14),
          fontVariations: widget.decoration?.textStyle?.fontVariations,
          color: widget.decoration?.textStyle?.color ?? Colors.black,
          fontFamily: widget.decoration?.textStyle?.fontFamily,
        ),
      ),
    );
  }

  Widget _iconWidget() {
    return Row(children: [
      Visibility(
        visible: getSearchTextEditingController.text.isNotEmpty,
        replacement: SizedBox(),
        child: Padding(
          padding: EdgeInsets.only(right: getSize(6)),
          child: Obx(
                () => InkWell(
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                clearSearchText();
                setState(() {});
                _hoveringClose(false);
              },
              onHover: (value) {
                _hoveringClose(value);
              },
              child: Icon(Icons.close,
                  size: getSize(13.5),
                  color: _hoveringClose.value
                      ? widget.decoration?.closeIconHoverColor ?? Colors.red
                      : widget.decoration?.closeIconColor ??
                      Colors.grey),
            ),
          ),
        ),
      ),
      Transform.rotate(
        angle: _isMenuOpen.value ? 3.14159 : 0,
        child: IconWidget(
          withPadding: false,
          onClick: () {
            _fillCurrentSelected();
            toggleDropDown();
          },
          data: 'assets/images/down_arrow.svg',
          color: const Color.fromARGB(182, 0, 0, 0),
          width: getSize(10),
          height: getSize(5.4),
        ),
      ),
    ]);
  }

  Widget _selectedItemsBuilderMulti() {
    return StatefulBuilder(builder: (context, chipState) {
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Visibility(
            visible: !_isMenuOpen.value,
            child: Padding(
              padding: EdgeInsets.only(
                left: getSize(widget.dropDownButtonPadding.left),
              ),
              child: TextWidget(
                data: selectedItems.isEmpty
                    ? widget.hintText
                    : "${selectedItems.length.toString()} selected",
                color: Colors.blue,
              ),
            ),
          ),
        );
      });
    });
  }

  Widget _labelWidget() {
    TextDecorationModel? labelTextDecoration =
        widget.decoration?.labelTextDecoration ?? widget.labelTextDecoration;
    return Visibility(
      visible: widget.showLabel,
      child: Container(
        padding: const EdgeInsets.only(bottom: 3.5),
        alignment: Alignment.centerLeft,
        child: TextWidget(
          data: labelTextDecoration?.text ?? widget.defaultLabelText,
          textStyle: TextStyle(
            fontSize: labelTextDecoration?.textStyle?.fontSize ?? 14,
            fontVariations: labelTextDecoration?.textStyle?.fontVariations,
            fontFamily: labelTextDecoration?.textStyle?.fontFamily,
            fontStyle: labelTextDecoration?.textStyle?.fontStyle,
            color: labelTextDecoration?.textStyle?.color ??
                Theme.of(context).primaryColor,
          ),
          isMandatory: widget.isMandatory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.isAddOnly == false || widget.isMulti);
    assert(widget.showLabel == false || widget.defaultLabelText.isNotEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMenuOpen() &&
          (previousScreenHeight != MediaQuery.of(context).size.height ||
              previousScreenWidth != MediaQuery.of(context).size.width ||
              previousSelectedCount != currentSelected.length)) {
        previousSelectedCount = currentSelected.length;

        _refreshMenu();
      }
    });

    return WillPopScope(
      onWillPop: () {
        if (isMenuOpen()) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
        return Future.value(true);
      },
      child: Column(
        children: [
          AbsorbPointer(
            absorbing: widget.isReadOnly,
            child: Form(
              key: widget.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelWidget(),
                  LayoutBuilder(builder: (context, constraints) {
                    return MouseRegion(
                      onEnter: (_) => _hoverField.value = true,
                      onExit: (_) => _hoverField.value = false,
                      child: CompositedTransformTarget(
                        key: _globalKey,
                        link: _layerLink,
                        child: GestureDetector(
                          onTap: () {
                            _fillCurrentSelected();
                            toggleDropDown();
                          },
                          child: Obx(() {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: getSize(
                                        widget.decoration?.borderWidth ?? 1),
                                    color: _isMenuOpen.value ||
                                        _hoverField.value
                                        ? widget.decoration
                                        ?.focusedBorderColor ??
                                        const Color.fromRGBO(0, 137, 255,
                                            1) // Show indigo color when both conditions are true
                                        : widget.decoration?.borderColor ??
                                        const Color.fromRGBO(
                                            207, 216, 225, 1)),
                                color: widget.decoration?.fieldColor ??
                                    Colors.white,
                                borderRadius: _isMenuOpen.value
                                    ? BorderRadius.only(
                                    topLeft: Radius.circular(getSize(
                                        widget.decoration?.borderRadius ??
                                            4)),
                                    topRight: Radius.circular(getSize(
                                        widget.decoration?.borderRadius ??
                                            4)))
                                    : BorderRadius.circular(getSize(
                                    widget.decoration?.borderRadius ?? 4)),
                              ),
                              padding: EdgeInsets.only(
                                  left: getSize(1),
                                  right: getSize(
                                      widget.dropDownButtonPadding.right),
                                  top: 1,
                                  bottom: 1),
                              width: constraints.maxWidth,
                              height:
                              getSize(widget.decoration?.fieldHeight ?? 40),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: widget.showSearchIcon ?? false,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: getSize(widget
                                              .dropDownButtonPadding.left),
                                          right: getSize(8)),
                                      child: IconWidget(
                                          withPadding: false,
                                          height: widget
                                              .decoration
                                              ?.prefixIconDecoration
                                              ?.iconHeight ??
                                              12,
                                          width: widget
                                              .decoration
                                              ?.prefixIconDecoration
                                              ?.iconWidth ??
                                              12,
                                          color: widget.decoration
                                              ?.prefixIconDecoration?.iconColor,
                                          data: 'assets/images/search.svg',
                                          onClick: () {
                                            _fillCurrentSelected();
                                            toggleDropDown(
                                              close: _isMenuOpen.value &&
                                                  _overlayEntry != null &&
                                                  _overlayEntry!.mounted,
                                            );
                                          }),
                                    ),
                                  ),
                                  Expanded(
                                    child: isMenuOpen() ||
                                        selectedItems.isEmpty &&
                                            widget.isMulti ||
                                        _selectedItem.isEmpty &&
                                            !widget.isMulti ||
                                        widget.isAddOnly
                                        ? _textFormFieldWidget()
                                        : () {
                                      if (widget.isMulti) {
                                        return _selectedItemsBuilderMulti();
                                      } else {
                                        return _selectedItemBuilderSingle();
                                      }
                                    }(),
                                  ),
                                  Visibility(
                                      visible: !widget.isReadOnly,
                                      child: _iconWidget()),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  }),
                  _errorWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFormFieldWidget() {
    return Container(
      color: widget.decoration?.fieldColor ?? Colors.white,
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        cursorColor: Colors.grey,
        onTap: () {
          if (!isMenuOpen()) {
            _fillCurrentSelected();
            toggleDropDown();
          }
        },
        controller: getSearchTextEditingController,
        style: TextStyle(
          fontSize: getSize(widget.decoration?.searchTextStyle?.fontSize ?? 13),
          fontStyle: widget.decoration?.searchTextStyle?.fontStyle,
          fontVariations: widget.decoration?.searchTextStyle?.fontVariations,
        ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          hintText: widget.decoration?.hintText ?? widget.hintText,
          fillColor: Colors.white,
          focusColor: Colors.white,
          contentPadding: EdgeInsets.only(
            bottom: getSize(20.0),
            left: widget.showSearchIcon == true
                ? getSize(5)
                : getSize(widget.dropDownButtonPadding.left),
          ),
          hintStyle: TextStyle(
            color: widget.decoration?.hintTextStyle?.color ??
                const Color.fromRGBO(132, 145, 159, 1),
            fontSize: widget.decoration?.hintTextStyle?.fontSize ?? 13,
            fontVariations: widget.decoration?.hintTextStyle?.fontVariations ??
                widget.decoration?.hintTextStyle?.fontVariations,
            fontFamily: widget.decoration?.hintTextStyle?.fontFamily ??
                widget.decoration?.textStyle?.fontFamily,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Visibility(
      visible: _showValidationFailedWidget.value && widget.showError,
      child: Container(
        padding: const EdgeInsets.only(top: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          IconWidget(
            withPadding: false,
            data: 'AppIcons.error.name',
            color: widget.validationFailedDecoration?.textStyle?.color ??
                Colors.red,
            height: widget.validationFailedDecoration?.textStyle?.fontSize ??
                getSize(16),
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            widget.validationFailedDecoration?.text ?? "Select Field",
            style: TextStyle(
              fontSize:
              widget.validationFailedDecoration?.textStyle?.fontSize ??
                  getSize(14),
              fontVariations:
              widget.validationFailedDecoration?.textStyle?.fontVariations,
              color: widget.validationFailedDecoration?.textStyle?.color ??
                  Colors.red,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _multiSelectItemBuilder(String item) {
    bool isHovered = false;
    return StatefulBuilder(builder: (context, menuSetState) {
      final isSelected = currentSelected.contains(item);
      return Material(
        child: InkWell(
          splashColor: Colors.transparent,
          hoverColor: widget.decoration?.itemHoverColor ??
              const Color.fromRGBO(237, 242, 254, 1),
          onHover: (value) {
            isHovered = value;
            menuSetState(() {});
          },
          onTap: () {
            if (!isSelected) {
              currentSelected.add(item);
            } else {
              currentSelected.remove(item);
            }
            menuSetState(() {});
            setState(() {});
          },
          child: Container(
              alignment: Alignment.center,
              color: isSelected || isHovered
                  ? widget.decoration?.itemHoverColor ??
                  const Color.fromRGBO(237, 242, 254, 1)
                  : widget.decoration?.menuBackgroundColor ?? Colors.white,
              height: getSize(widget.decoration?.fieldHeight ?? 40),
              padding: EdgeInsets.symmetric(horizontal: getSize(10)),
              child: Row(
                children: [
                  if (isSelected)
                    Icon(Icons.check_box_rounded,
                        color: widget.decoration?.checkboxIconColor ??
                            Color.fromRGBO(0, 137, 255, 1),
                        size: getSize(16))
                  else
                    Icon(Icons.check_box_outline_blank,
                        color: Colors.black54, size: getSize(16)),
                  SizedBox(width: getSize(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (isSelected || isHovered)
                              ? widget.decoration?.checkboxIconColor ??
                              Color.fromRGBO(0, 137, 255, 1)
                              : widget.decoration?.textStyle?.color,
                          fontSize: getSize(
                              widget.decoration?.textStyle?.fontSize ?? 14),
                          fontVariations:
                          widget.decoration?.textStyle?.fontVariations,
                          fontFamily: widget.decoration?.textStyle?.fontFamily,
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ),
      );
    });
  }

  Widget _selectAllItemBuilder() {
    bool isHovered = false;
    return Obx(() {
      final isSelected = currentSelected.length == getFilterItemsList.length &&
          currentSelected.isNotEmpty;
      return InkWell(
        splashColor: Colors.transparent,
        hoverColor: widget.decoration?.itemHoverColor ??
            const Color.fromRGBO(237, 242, 254, 1),
        onHover: (value) {
          isHovered = value;
        },
        onTap: () {
          currentSelected.value = List.from(getFilterItemsList);
          setState(() {});
        },
        child: Container(
            alignment: Alignment.center,
            color: isSelected || isHovered
                ? widget.decoration?.itemHoverColor ??
                Color.fromRGBO(237, 242, 254, 1)
                : widget.decoration?.menuBackgroundColor ?? Colors.white,
            height: getSize(widget.decoration?.fieldHeight ?? 40),
            padding: EdgeInsets.symmetric(horizontal: getSize(10)),
            child: Row(
              children: [
                if (isSelected)
                  Icon(Icons.check_box_rounded,
                      color: widget.decoration?.checkboxIconColor ??
                          Color.fromRGBO(0, 137, 255, 1),
                      size: getSize(16))
                else
                  Icon(Icons.check_box_outline_blank,
                      color: Colors.black54, size: getSize(16)),
                SizedBox(width: getSize(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "All",
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: (isSelected || isHovered)
                            ? widget.decoration?.checkboxIconColor ??
                            Color.fromRGBO(0, 137, 255, 1)
                            : widget.decoration?.textStyle?.color,
                        fontSize: getSize(
                            widget.decoration?.textStyle?.fontSize ?? 14),
                        fontVariations:
                        widget.decoration?.textStyle?.fontVariations,
                        fontFamily: widget.decoration?.textStyle?.fontFamily,
                      ),
                    ),
                  ],
                )
              ],
            )),
      );
    });
  }

  Widget _singleSelectItemBuilder(String item) {
    bool isHovered = false;
    return Obx(() {
      return InkWell(
        splashColor: Colors.transparent,
        hoverColor: widget.decoration?.itemHoverColor ??
            Color.fromRGBO(237, 242, 254, 1),
        onHover: (value) {
          isHovered = value;
          //     menuSetState(() {});
        },
        onTap: () {
          widget.onChanged(item);
          _selectedItem.value = item;
          toggleDropDown(close: true);
        },
        child: Container(
            alignment: Alignment.centerLeft,
            height: getSize(widget.decoration?.fieldHeight ?? 40),
            padding: EdgeInsets.symmetric(horizontal: getSize(12)),
            color: isHovered
                ? widget.decoration?.itemHoverColor ??
                const Color.fromRGBO(237, 242, 254, 1)
                : widget.decoration?.fieldColor ?? Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isHovered
                          ? widget.decoration?.checkboxIconColor ??
                          Color.fromRGBO(0, 137, 255, 1)
                          : widget.decoration?.textStyle?.color,
                      fontSize:
                      getSize(widget.decoration?.textStyle?.fontSize ?? 14),
                      fontVariations:
                      widget.decoration?.textStyle?.fontVariations,
                      fontFamily: widget.decoration?.textStyle?.fontFamily,
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }

  OverlayEntry _createDropDownMenu() {
    RenderBox renderBox =
    _globalKey.currentContext?.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    previousScreenHeight = MediaQuery.of(context).size.height;
    previousScreenWidth = MediaQuery.of(context).size.width;

    return OverlayEntry(
      maintainState: false,
      builder: (context) => StatefulBuilder(builder: (currentContext, state) {
        return Obx(() {
          return GestureDetector(
            behavior: _hoverField.value ? null : HitTestBehavior.translucent,
            onTap: _hoverField.value
                ? null
                : () {
              toggleDropDown(close: true);
            },
            child: Obx(() {
              MenuLimits menuLimits = _getMenuItemLimits(offset, size);
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Positioned(
                      top: menuLimits.positionOffset.dy,
                      left: menuLimits.positionOffset.dx,
                      width: menuLimits.menuItemWidth,
                      child: Align(
                          alignment: Alignment.center,
                          child: _menuBuilder(
                            menuLimits.menuItemHeight,
                            menuLimits.menuItemWidth,
                            menuLimits.compositedTransformOffset,
                          )),
                    ),
                  ],
                ),
              );
            }),
          );
        });
      }),
    );
  }

  Widget _menuBuilder(menuHeight, menuWidth, compositedTransFormOffset) {
    return CompositedTransformFollower(
      offset: compositedTransFormOffset,
      link: _layerLink,
      showWhenUnlinked: false,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: getSize(widget.decoration?.borderWidth ?? 1) + 1,
            vertical: getSize(1)),
        constraints: BoxConstraints(
          maxHeight: menuHeight,
        ),
        clipBehavior: Clip.hardEdge,
        width: menuWidth,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: getSize(widget.decoration?.borderWidth ?? 1),
              color: widget.decoration?.focusedBorderColor ??
                  const Color.fromRGBO(0, 137, 255, 1),
            ),
            left: BorderSide(
              width: getSize(widget.decoration?.borderWidth ?? 1),
              color: widget.decoration?.focusedBorderColor ??
                  const Color.fromRGBO(0, 137, 255, 1),
            ),
            bottom: BorderSide(
              width: getSize(widget.decoration?.borderWidth ?? 1),
              color: widget.decoration?.focusedBorderColor ??
                  const Color.fromRGBO(0, 137, 255, 1),
            ),
            top: BorderSide(
              width: getSize(widget.decoration?.borderWidth ?? 1),
              color: widget.decoration?.focusedBorderColor ??
                  const Color.fromRGBO(0, 137, 255, 1),
            ),
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(
                  getSize(widget.decoration?.borderRadius ?? 4)),
              bottomRight: Radius.circular(
                  getSize(widget.decoration?.borderRadius ?? 4))),
          color: widget.decoration?.menuBackgroundColor ?? Colors.white,
        ),
        child: Material(
          child: Obx(
                () => Column(
              children: [
                Expanded(
                  child: Visibility(
                    visible: getFilterItemsList.isNotEmpty,
                    replacement: _noResultFoundWidget(),
                    child: _menuContentWidget(),
                  ),
                ),
                widget.isMulti ? _selectAndUnSelectWidget() : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _menuContentWidget() {
    return SingleChildScrollView(
      key: _scrollKey,
      child: Column(
        children: [
          widget.isMulti &&
              getSearchTextEditingController.text.isEmpty &&
              widget.showSelectAll
              ? _selectAllItemBuilder()
              : SizedBox(),
          ...() {
            return getFilterItemsList.map((item) {
              // Return your builder based on widget.isMulti
              return widget.isMulti
                  ? _multiSelectItemBuilder(item)
                  : _singleSelectItemBuilder(item);
            }).toList();
          }(),
        ],
      ),
    );
  }

  _noResultFoundWidget() {
    TextDecorationModel? noResultFoundTextDecoration =
        widget.decoration?.noResultFoundTextDecoration;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: TextWidget(
            data: widget.decoration?.noResultFoundTextDecoration?.text ??
                "No Results Found",
            textStyle: TextStyle(
              fontSize: noResultFoundTextDecoration?.textStyle?.fontSize ?? 14,
              fontVariations:
              noResultFoundTextDecoration?.textStyle?.fontVariations,
              fontFamily: noResultFoundTextDecoration?.textStyle?.fontFamily,
              fontStyle: noResultFoundTextDecoration?.textStyle?.fontStyle,
              color: noResultFoundTextDecoration?.textStyle?.color ??
                  Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  _selectAndUnSelectWidget() {
    return InkWell(
      onTap: () {},
      hoverColor:
      widget.decoration?.fieldColor ?? Theme.of(context).canvasColor,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: getSize(12)),
        decoration: BoxDecoration(
          color: widget.decoration?.menuBackgroundColor ??
              Theme.of(context).canvasColor,
          border: Border(
              top: BorderSide(
                  width: widget.decoration?.borderWidth ?? 1,
                  color: widget.decoration?.borderColor ??
                      Colors.blueAccent)),
        ),
        height: getSize(widget.decoration?.applyAddSelectionAreaHeight ?? 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              data: "${currentSelected.length} Selected",
              textStyle: TextStyle(
                color: widget.decoration?.selectedCountTextStyle?.color ??
                    const Color.fromRGBO(0, 26, 67, 1),
                fontSize:
                widget.decoration?.selectedCountTextStyle?.fontSize ?? 12,
                fontVariations:
                widget.decoration?.selectedCountTextStyle?.fontVariations ??
                    widget.decoration?.textStyle?.fontVariations,
                fontFamily:
                widget.decoration?.selectedCountTextStyle?.fontFamily ??
                    widget.decoration?.textStyle?.fontFamily,
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    if (currentSelected.isNotEmpty) {
                      if (!widget.isAddOnly) {
                        selectedItems.clear();
                      }
                      currentSelected.clear();
                      previousSelectedCount = -1;
                      setState(() {});
                      widget.onClear!(true);
                    }
                  },
                  child: TextWidget(
                    data: "Clear all",
                    textStyle: TextStyle(
                      color: currentSelected.isEmpty
                          ? const Color.fromRGBO(163, 189, 246, 1)
                          : const Color.fromRGBO(76, 127, 240, 1),
                      fontSize: widget
                          .decoration?.selectUnSelectTextStyle?.fontSize ??
                          12,
                      fontVariations: widget.decoration?.selectUnSelectTextStyle
                          ?.fontVariations ??
                          widget.decoration?.textStyle?.fontVariations,
                      fontFamily: widget.decoration?.selectUnSelectTextStyle
                          ?.fontFamily ??
                          widget.decoration?.textStyle?.fontFamily,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                ButtonWidget(
                    data: widget.isAddOnly ? 'Add' : 'Apply',
                    onClick: () {
                      if (currentSelected.isEmpty) {
                        return;
                      } else {
                        toggleDropDown(close: true);
                        if (widget.isAddOnly) {
                          for (String item in currentSelected) {
                            getFilterItemsList.remove(item);
                            selectedItems.add(item);
                          }
                        } else {
                          selectedItems.value = List.from(currentSelected);
                        }

                        widget.onChanged!(currentSelected);
                        setState(() {});
                      }
                    },
                    width: 57,
                    height: 32,
                    buttonBackgroundColor: currentSelected.isEmpty
                        ? Color.fromRGBO(163, 189, 246, 1)
                        : Color.fromRGBO(76, 127, 240, 1),
                    borderRadius: 4,
                    textColor: Colors.white),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _refreshMenu() {
    toggleDropDown(close: true);
    toggleDropDown();
  }

  bool isMenuOpen() {
    return _overlayEntry != null && _overlayEntry!.mounted && _isMenuOpen.value;
  }

  MenuLimits _getMenuItemLimits(Offset offset, Size size) {
    double dropDownButtonHeight = size.height;

    double topOffset = offset.dy +
        dropDownButtonHeight -
        (widget.decoration?.borderWidth ?? 1);
    double leftOffset = offset.dx;

    double viewPortHeight = MediaQuery.of(context).size.height;
    double viewPortWidth = MediaQuery.of(context).size.width;

    double minMenuHeight = (widget.decoration?.fieldHeight ?? 40) +
        (widget.isMulti
            ? widget.decoration?.applyAddSelectionAreaHeight ?? 48
            : 0) +
        4;

    double actualMenuHeight = max(
      minMenuHeight,
      getFilterItemsList.length * (widget.decoration?.fieldHeight ?? 40) +
          4 +
          (widget.isMulti &&
              getSearchTextEditingController.text.isEmpty &&
              widget.showSelectAll
              ? (widget.decoration?.fieldHeight ?? 40)
              : 0) +
          (widget.isMulti
              ? widget.decoration?.applyAddSelectionAreaHeight ?? 48
              : 0),
    );

    double menuWidth = size.width;
    double menuHeight =
    min(actualMenuHeight, widget.decoration?.dropdownMaxHeight ?? 350);

    double compositedTransFormTopOffset = dropDownButtonHeight;
    double compositedTransFormLeftOffset = 0;

    if (viewPortHeight <= menuHeight + 4) {
      menuHeight = viewPortHeight - 4;
    } else if (viewPortHeight > menuHeight + 4) {
      menuHeight =
          min(actualMenuHeight, widget.decoration?.dropdownMaxHeight ?? 350);
    }

    if (viewPortHeight <= topOffset + menuHeight + 4) {
      topOffset -= (topOffset + menuHeight + 4 - viewPortHeight);
      compositedTransFormTopOffset = topOffset - offset.dy;
    } else if (viewPortHeight > topOffset + menuHeight + 4) {
      topOffset = offset.dy +
          dropDownButtonHeight -
          (widget.decoration?.borderWidth ?? 1);
      compositedTransFormTopOffset =
          dropDownButtonHeight - (widget.decoration?.borderWidth ?? 1);
    }

    if (viewPortWidth <= offset.dx + menuWidth + 2) {
      menuWidth = viewPortWidth - 4;
      // leftOffset = 2;                                        use this to change left offset
      // compositedTransFormLeftOffset = 2 - offset.dx;         use this to change left offset
    } else if (viewPortWidth > offset.dx + menuWidth + 2) {
      menuWidth = size.width;
      //  compositedTransFormLeftOffset = 0;                    use this to change left offset
    }

    return MenuLimits(
      positionOffset: Offset(leftOffset, topOffset),
      compositedTransformOffset:
      Offset(compositedTransFormLeftOffset, compositedTransFormTopOffset),
      menuItemHeight: menuHeight,
      menuItemWidth: menuWidth,
    );
  }

  void toggleDropDown({bool close = false}) {
    if (isMenuOpen()) {
      try {
        _overlayEntry?.remove();
        setState(() {
          _isMenuOpen.value = false;
        });
        widget.dropdownStatus != null ? widget.dropdownStatus!(false) : null;
      } catch (e) {
        print(e);
      }
    } else if (!close) {
      try {
        _overlayEntry = _createDropDownMenu();
        Overlay.of(context).insert(_overlayEntry!);
        widget.dropdownStatus != null ? widget.dropdownStatus!(true) : null;

        setState(() {
          _isMenuOpen.value = true;
        });
      } catch (e) {
        print(e);
      }
    }
  }
}

class MenuLimits {
  MenuLimits({
    required this.positionOffset,
    required this.compositedTransformOffset,
    required this.menuItemHeight,
    required this.menuItemWidth,
  });

  Offset positionOffset;
  Offset compositedTransformOffset;
  double menuItemHeight;
  double menuItemWidth;
}