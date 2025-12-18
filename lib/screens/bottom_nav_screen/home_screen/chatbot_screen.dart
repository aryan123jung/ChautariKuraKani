import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback onClose;

  const ChatbotScreen({super.key, required this.onClose});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        height: 600,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Text(
                    "Chat Bot",
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: "OpenSans Bold",
                    ),
                  ),
                ),
                Positioned(
                  top: -7,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            const Divider(),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Center(
                  child: Text("Chat messages"),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: const InputDecoration(
                      hintText: "Ask questions freely...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:chautari_kurakani/services/chatbot_model.dart';
// import 'package:flutter/material.dart';

// class ChatbotScreen extends StatefulWidget {
//   final VoidCallback onClose;

//   const ChatbotScreen({super.key, required this.onClose});

//   @override
//   State<ChatbotScreen> createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends State<ChatbotScreen> {
//   final AiService aiService = AiService();
//   final TextEditingController controller = TextEditingController();

//   List<Map<String, String>> messages = [];
//   bool isLoading = false;

//   void sendMessage() async {
//     String userInput = controller.text.trim();
//     if(userInput.isEmpty) return;

//     setState(() {
//       messages.add({"role": "user", "text": userInput});
//       isLoading = true;
//     });

//     controller.clear();

//     String aiReply = await aiService.sendMessage(userInput);

//     setState(() {
//       messages.add({"role": "ai", "text": aiReply});
//       isLoading = false;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomRight,
//       child: Container(
//         height: 600,
//         width: double.infinity,
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Stack(
//                 children: [
//                   Center(
//                     child: Text(
//                       "Chat Bot",
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontFamily: "OpenSans Bold",
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 0,
//                     right: 0,
//                     child: IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: widget.onClose,
//                     ),
//                   ),
//                 ],
//               ),

//             SizedBox(height: 10,),
//             const Divider(),

//             const Expanded(
//               child: Center(
//                 child: Text("Chatbot content goes here"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
