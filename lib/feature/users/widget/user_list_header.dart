import 'package:flutter/material.dart';

class UserListHeaderDelegate extends SliverPersistentHeaderDelegate {
  const UserListHeaderDelegate(this.title);
  final String title;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox(
        height: 35,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => 35;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
