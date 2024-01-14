import 'package:flutter/material.dart';

class UserListHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => 35;

  const UserListHeaderDelegate(this.title);
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 35,
      child: Material(
        color: theme.colorScheme.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.key, color: IconTheme.of(context).color?.withOpacity(0.5)),
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
