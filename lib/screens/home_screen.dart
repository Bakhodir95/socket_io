import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Socket socket;
  final textController = TextEditingController();
  final StreamController streamController = StreamController();
  bool toggleOn = false;

  @override
  void initState() {
    super.initState();
    connectTotServer();
  }

  void connectTotServer() {
    String socketUrl = "https://9920-89-236-218-41.ngrok-free.app/";

    socket = io(socketUrl, {
      "transports": ["websocket"],
      'autoConnect': false,
    });

    socket.connect();
    socket.on(
      'todos',
      (data) {
        streamController.add(data);
      },
    );
    socket.onConnect((_) {
      print('socket muvaffaqiyatli ulandi');
    });
    socket.onDisconnect((_) => print('disconnect'));
  }

  void addTodo() {
    String title = textController.text;
    if (title.isNotEmpty) {
      socket.emit(
        "add_todo",
        title,
      );
      textController.clear();
    }
  }

  void removeTodo(int index) {
    socket.emit("remove_todo", index);
  }

  void toggleTodo(int index) {
    socket.emit("toggle_todo", index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Todos"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Enter Todo"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: OutlinedButton(
                      onPressed: addTodo, child: const Text("Add ")),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("No data"),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error data"),
                    );
                  }
                  final todos = snapshot.data!;
                  print(todos);
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(todos[index]['text']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: todos[index]['completed'],
                                  onChanged: (value) {
                                    toggleTodo(index);
                                  },
                                ),
                                IconButton(
                                    onPressed: () {
                                      removeTodo(index);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )),
                              ],
                            ),
                          );
                        }),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
