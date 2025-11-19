// import 'package:flutter/material.dart';

// class ChatbotScreen extends StatelessWidget {
//   const ChatbotScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat Box"),
//         centerTitle: true,
//         backgroundColor: Colors.amber,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final AiService aiService = AiService();
  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    String userInput = controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userInput});
      isLoading = true;
    });

    controller.clear();

    String aiReply = await aiService.sendMessage(userInput);

    setState(() {
      messages.add({"role": "ai", "text": aiReply});
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isUser = msg["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      // color: isUser ? Colors.green : Colors.grey.shade300,
                      color: isUser ? Colors.green : const Color.fromARGB(255, 174, 187, 158),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Input Box ---
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send, size: 28),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
