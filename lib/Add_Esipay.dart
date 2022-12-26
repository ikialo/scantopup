import 'package:flutter/material.dart';
import 'package:scantopup/db_esipay.dart';

import 'EsiPayScreen.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({Key? key}) : super(key: key);

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  bool important = false;
  final titleController = TextEditingController();
  final subtitleControler = TextEditingController();
  @override
  void dispose() {
    titleController.dispose();
    subtitleControler.dispose();
    super.dispose();
  }

  void addTodo() async {
    EsiPayModel todo = EsiPayModel(
      id: 1,
        title: titleController.text,
        Esipaynum: int.parse(subtitleControler.text));
    await DatabaseRepository.instance.insert(todo: todo);
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 320,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 18, right: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                  label: const Text('title'),
                  hintText: 'Boroko Haus '),
            ),
            const SizedBox(
              height: 36,
            ),
            TextFormField(
              controller: subtitleControler,
              decoration: const InputDecoration(
                label: const Text('Esi pay number'),
              ),
            ),

            MaterialButton(
              color: Colors.purple,
              height: 50,
              minWidth: double.infinity,
              onPressed: () {
                addTodo();
                Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EsiPayScreen(),
                    ));

              },
              child: const Text(
                'Add Esipay #',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}