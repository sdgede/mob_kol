import 'package:flutter/material.dart';

class BottomLoading extends StatelessWidget {
  final bool isFinish;
  const BottomLoading({Key? key, this.isFinish = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isFinish
            ? [
                Text(
                  "Semua data sudah dimuat",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).hintColor),
                ),
              ]
            : [
                SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Memuat data",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
      ),
    );
  }
}
