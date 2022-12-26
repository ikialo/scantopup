
import 'package:flutter/material.dart';
class EsipayItem extends StatefulWidget {
  const EsipayItem({Key? key}) : super(key: key);

  @override
  State<EsipayItem> createState() => _EsipayItemState();
}

class _EsipayItemState extends State<EsipayItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListTile(
        trailing: Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
        subtitle: Text(
          'Develop the next great app idea',
          style: const TextStyle(color: Colors.black87, fontSize: 12),
        ),
        title: Text(
          'Develop amazing flutter app',
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.1)),
    );;
  }
}
