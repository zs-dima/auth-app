import 'package:ui/ui.dart';

class UserListHeaderDelegate extends SliverPersistentHeaderDelegate {
  const UserListHeaderDelegate(this.title);
  final String title;

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => 35.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 35.0,
      child: Material(
        color: theme.colorScheme.surface,
        child: Row(
          crossAxisAlignment: .center,
          children: [
            Expanded(
              child: AppText.bodyLarge(
                title,
                fontWeight: .bold,
                textAlign: .right,
                overflow: .ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8.0),
            Icon(Icons.key, color: IconTheme.of(context).color?.withValues(alpha: 0.5)),
            const SizedBox(width: 28.0),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
