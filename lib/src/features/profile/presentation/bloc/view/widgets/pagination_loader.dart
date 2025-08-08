import 'package:flutter/material.dart';

class PaginationLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasMoreItems;
  final bool hasReachedEnd;

  const PaginationLoader({
    super.key,
    required this.isLoading,
    required this.hasMoreItems,
    required this.hasReachedEnd,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasReachedEnd) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'You reached the end of the list',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (!hasMoreItems) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }
}
