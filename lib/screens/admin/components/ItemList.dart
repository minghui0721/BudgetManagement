import 'package:flutter/material.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/screens/admin/components/TableCard.dart';

class ItemList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) getTitle;
  final String Function(T)? getImagePath;
  final List<Widget> Function(T) getDetails;
  final Function(T) onEdit;
  final Function(T) onDelete;
  final Function(T) onView;

  const ItemList({
    Key? key,
    required this.items,
    required this.getTitle,
    this.getImagePath,
    required this.getDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imagePath = getImagePath != null ? getImagePath!(item) : '';
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == items.length - 1 ? AppTheme.listBottomSpacing : 0.0,
          ),
          child: TableCard(
            imagePath: imagePath,
            title: Text(getTitle(item)),
            details: getDetails(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
            onView: () => onView(item),
            hasImage: imagePath.isNotEmpty,
          ),
        );
      },
    );
  }
}
