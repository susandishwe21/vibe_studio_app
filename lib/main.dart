import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const VibeStudioApp());
}

class VibeStudioApp extends StatelessWidget {
  const VibeStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const GeneratorScreen(),
    );
  }
}

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _generatedCode = "";
  bool _isLoading = false;
  bool _showCode = false;

  final String _apiUrl = 'https://nantsusandyshwe-vibe-studio.hf.space/generate';

  Future<void> _generateCode() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a UI description')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedCode = "";
      _showCode = true;
    });

    try {
      final request = http.Request('POST', Uri.parse(_apiUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'prompt': prompt});

      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });

        response.stream.transform(utf8.decoder).listen(
          (String chunk) {
            setState(() {
              _generatedCode += chunk;
            });
          },
          onDone: () {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(duration: Duration(seconds: 1),
                content: Text('Code generated successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          },
          onError: (error) {
            setState(() {
              _generatedCode = "Stream Error: $error";
            });
          },
        );
      } else {
        setState(() {
          _isLoading = false;
          _generatedCode = " Server Error: ${response.statusCode}\nPlease try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _generatedCode = " Network Error: $e\nMake sure the server is running.";
      });
    }
  }

  void _copyToClipboard() {
    if (_generatedCode.isNotEmpty && !_generatedCode.contains("Error")) {
      final data = ClipboardData(text: _generatedCode);
      Clipboard.setData(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Code copied to clipboard!'),
          backgroundColor: Color(0xFF8B5CF6),
        ),
      );
    }
  }

  void _clearAll() {
    setState(() {
      _promptController.clear();
      _generatedCode = "";
      _showCode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.code, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vibe Studio',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'AI Flutter Code Generator',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Transform your ideas into beautiful Flutter code instantly',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFCBD5E1),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Input Section
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF334155),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Describe Your UI Design',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _promptController,
                                decoration: InputDecoration(
                                  hintText: '',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                maxLines: 4,
                                minLines: 3,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Example Prompts
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF334155).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Color(0xFFFCD34D),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Example Prompts',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFCD34D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildExamplePrompt('Create a login screen with email and password fields'),
                              const SizedBox(height: 10),
                              _buildExamplePrompt('Create a user list screen'),
                              const SizedBox(height: 8),
                              _buildExamplePrompt('Build a product card with image, title, price, and add to cart button'),
                              const SizedBox(height: 8),
                              _buildExamplePrompt('Design a user profile page with profile picture and edit button'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Generate Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _generateCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Generating your code...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Generate Flutter Code',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Code Output Section - FULL WIDTH
                        if (_showCode)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.code, color: Color(0xFF10B981), size: 18),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Generated Code',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!_isLoading && _generatedCode.isNotEmpty)
                                    Row(
                                      children: [
                                        Tooltip(
                                          message: 'Copy code',
                                          child: IconButton(
                                            icon: const Icon(Icons.content_copy, size: 18),
                                            onPressed: _copyToClipboard,
                                            tooltip: 'Copy code',
                                          ),
                                        ),
                                        Tooltip(
                                          message: 'Clear all',
                                          child: IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18),
                                            onPressed: _clearAll,
                                            tooltip: 'Clear all',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // FULL WIDTH CODE BOX
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF334155),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                                  minHeight: 200,
                                ),
                                width: double.infinity, // FULL WIDTH
                                child: SingleChildScrollView(
                                  child: Text(
                                    _generatedCode.isEmpty
                                        ? '✨ Your generated Flutter code will appear here...'
                                        : _generatedCode,
                                    style: const TextStyle(
                                      fontFamily: 'Courier New',
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: const Color(0xFF1E293B),
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(
              //         color: const Color(0xFF334155),
              //         width: 1,
              //       ),
              //     ),
              //     padding: const EdgeInsets.all(12),
              //     child: const Row(
              //       children: [
              //         Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 18),
              //         SizedBox(width: 10),
              //         Expanded(
              //           child: Text(
              //             'Be specific with your requirements for better code generation',
              //             style: TextStyle(
              //               fontSize: 12,
              //               color: Color(0xFF94A3B8),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamplePrompt(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _promptController.text = text;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF334155).withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(const VibeApp());
// }

// class VibeApp extends StatelessWidget {
//   const VibeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Vibe AI Coder',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
//         useMaterial3: true,
//       ),
//       home: const GeneratorScreen(),
//     );
//   }
// }

// class GeneratorScreen extends StatefulWidget {
//   const GeneratorScreen({super.key});

//   @override
//   State<GeneratorScreen> createState() => _GeneratorScreenState();
// }

// class _GeneratorScreenState extends State<GeneratorScreen> {
//   final TextEditingController _promptController = TextEditingController();
//   String _generatedCode = "";
//   bool _isLoading = false;

//   // IMPORTANT:
//   // Use 10.0.2.2 for Android Emulator.
//   // Use 127.0.0.1 for iOS Simulator.
//   // Use your computer's local Wi-Fi IP (e.g. 192.168.x.x) for a physical phone.
//   final String _apiUrl = 'https://nantsusandyshwe-vibe-studio.hf.space/generate';

//   Future<void> _generateCode() async {
//     final prompt = _promptController.text.trim();
//     if (prompt.isEmpty) return;

//     setState(() {
//       _isLoading = true; // Show loading only briefly while connecting
//       _generatedCode = "";
//     });

//     try {
//       final request = http.Request('POST', Uri.parse(_apiUrl));
//       print("Sending prompt to server: $prompt"); 
//       print("API URL: $_apiUrl");
//       request.headers['Content-Type'] = 'application/json';
//       request.body = jsonEncode({'prompt': prompt});

//       // Send the request and open the stream
//       final response = await http.Client().send(request);
// print("Received response with status: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         setState(() {
//           _isLoading = false; // Turn off loader instantly!
//         });

//         // Listen to the text chunks arriving from Python
//         response.stream.transform(utf8.decoder).listen(
//           (String chunk) {
//             setState(() {
//               print("Received response with status: ${chunk}");
//               _generatedCode += chunk; // Append the text to the screen smoothly
//             });
//           },
//           onDone: () {
//             print("Finished generating code.");
//           },
//           onError: (error) {
//             setState(() {
//               _generatedCode += "\n[Stream Error: $error]";
//             });
//           },
//         );
//       } else {
//         setState(() {
//           _isLoading = false;
//           _generatedCode = "Server Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _generatedCode = "Network Error: $e\nEnsure your FastAPI server is running.";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vibe AI Coder'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _promptController,
//               decoration: const InputDecoration(
//                 labelText: 'Describe the UI you want to build',
//                 hintText: 'e.g. Create a login screen with email and password',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 2,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
//               onPressed: _isLoading ? null : _generateCode,
//               child: _isLoading
//                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                   : const Text('Generate Flutter Code', style: TextStyle(fontSize: 16)),
//             ),
//             const SizedBox(height: 24),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.black87,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Text(
//                     _generatedCode.isEmpty ? "Code will appear here" : _generatedCode,
//                     style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 13),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }