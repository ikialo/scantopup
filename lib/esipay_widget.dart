import 'package:flutter/material.dart';
import 'package:scantopup/db_esipay.dart';

import 'EsiPayScreen.dart';

class TodoWidget extends StatelessWidget {
  final EsiPayModel todo;
  const TodoWidget({Key? key, required this.todo}) : super(key: key);

  void delete({required EsiPayModel todo, required BuildContext context}) async {
    DatabaseRepository.instance.delete(todo.id!).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Deleted')));
    }).catchError((e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ListTile(
        trailing: IconButton(
          onPressed: () {


            delete(todo: todo, context: context);
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EsiPayScreen(),
                ));


          },
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
        ),
        title: Text(
          todo.title,
          style: const TextStyle(color: Colors.black87, fontSize: 12),
        ),
        subtitle: Text(
          todo.Esipaynum.toString(),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(0.1)),
    );
  }
}