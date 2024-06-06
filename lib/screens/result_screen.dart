import 'package:flutter/material.dart';
import 'package:self_discover/services/api_service.dart';
import 'package:self_discover/models/insight.dart';
import 'package:self_discover/screens/overall_result_screen.dart';
import 'package:self_discover/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import '../services/proxy.dart';
import '../widgets/section_title.dart';

class ResultScreen extends StatefulWidget {
  final String model;
  final String language;
  final String apiKey;
  final String GroqapiKey;
  final bool useVpn;
  final String proxy;
  final String question;
  final String logic;

  ResultScreen({
    required this.model,
    required this.language,
    required this.apiKey,
    required this.GroqapiKey,
    required this.useVpn,
    required this.proxy,
    required this.question,
    required this.logic,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ApiService apiService;
  List<Insight> insights = [];
  String? finalResult;
  bool isLoading = true;
  String? error;
  bool isSelectedModulesExpanded = true;
  bool isAdaptedModulesExpanded = true;
  bool isReasoningStructureExpanded = true;
  List<Insight> selectedModulesInsights = [];
  List<Insight> adaptedModulesInsights = [];
  List<Insight> reasoningStructureInsights = [];
  String loadingStatus = 'Waiting for LLM...';

  @override
  void initState() {
    super.initState();
    apiService = ApiService(
      apiKey: widget.apiKey,
      GroqapiKey: widget.GroqapiKey,
      proxy: widget.proxy,
      selectedModel: widget.model,
      selectedLanguage: widget.language,
      useVpn: widget.useVpn,
    );

    // Perform action based on the selected logic
    if (widget.logic == 'Basic question') {
      performSingleQuestion(widget.question);
    } else if (widget.logic == 'Self-Discover Agent') {
      performSelfDiscovery(widget.question);
    } else if (widget.logic == 'GPT Researcher Agent') {
      // GPT Researcher Agent logic
    }
  }

  Future<void> performSingleQuestion(String question) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      try {
        setState(() {
          loadingStatus = 'Preparing...';
        });
        // Step 1: Select Reasoning Modules
        String translationStructure1;
        translationStructure1 = await apiService.querySingleQuestion(widget.question);
        selectedModulesInsights = _splitIntoInsights(translationStructure1);

        finalResult = "\n### User's request:\n${widget.question}\n### Model answer:\n$translationStructure1";

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> performSelfDiscovery(String question) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      List<String> reasoningModules = [
        // Add your reasoning modules here
        "1. How could I devise an experiment to help solve that problem?",
        "2. Make a list of ideas for solving this problem, and apply them one by one to the problem to see if any progress can be made.",
        // "3. How could I measure progress on this problem?",
        "4. How can I simplify the problem so that it is easier to solve?",
        "5. What are the key assumptions underlying this problem?",
        "6. What are the potential risks and drawbacks of each solution?",
        "7. What are the alternative perspectives or viewpoints on this problem?",
        "8. What are the long-term implications of this problem and its solutions?",
        "9. How can I break down this problem into smaller, more manageable parts?",
        "10. Critical Thinking: This style involves analyzing the problem from different perspectives, questioning assumptions, and evaluating the evidence or information available. It focuses on logical reasoning, evidence-based decision-making, and identifying potential biases or flaws in thinking.",
        "11. Try creative thinking, generate innovative and out-of-the-box ideas to solve the problem. Explore unconventional solutions, thinking beyond traditional boundaries, and encouraging imagination and originality.",
        // "12. Seek input and collaboration from others to solve the problem. Emphasize teamwork, open communication, and leveraging the diverse perspectives and expertise of a group to come up with effective solutions.",
        "13. Use systems thinking: Consider the problem as part of a larger system and understanding the interconnectedness of various elements. Focuses on identifying the underlying causes, feedback loops, and interdependencies that influence the problem, and developing holistic solutions that address the system as a whole.",
        "14. Use Risk Analysis: Evaluate potential risks, uncertainties, and tradeoffs associated with different solutions or approaches to a problem. Emphasize assessing the potential consequences and likelihood of success or failure, and making informed decisions based on making informed decisions based on a balanced analysis of risks and benefits.",
        // "15. Use Reflective Thinking: Step back from the problem, take the time for introspection and self-reflection. Examine personal biases, assumptions, and mental models that may influence problem-solving, and being open to learning from past experiences to improve future approaches.",
        "16. What is the core issue or problem that needs to be addressed?",
        "17. What are the underlying causes or factors contributing to the problem?",
        "18. Are there any potential solutions or strategies that have been tried before? If yes, what were the outcomes and lessons learned?",
        "19. What are the potential obstacles or challenges that might arise in solving this problem?",
        "20. Are there any relevant data or information that can provide insights into the problem? If yes, what data sources are available, and how can they be analyzed?",
        "21. Are there any stakeholders or individuals who are directly affected by the problem? What are their perspectives and needs?",
        "22. What resources (financial, human, technological, etc.) are needed to tackle the problem effectively?",
        "23. How can progress or success in solving the problem be measured or evaluated?",
        "24. What indicators or metrics can be used?",
        "25. Is the problem a technical or practical one that requires a specific expertise or skill set? Or is it more of a conceptual or theoretical problem?",
        "26. Does the problem involve a physical constraint, such as limited resources, infrastructure, or space?",
        "27. Is the problem related to human behavior, such as a social, cultural, or psychological issue?",
        "28. Does the problem involve decision-making or planning, where choices need to be made under uncertainty or with competing objectives?",
        "29. Is the problem an analytical one that requires data analysis, modeling, or optimization techniques?",
        "30. Is the problem a design challenge that requires creative solutions and innovation?",
        "31. Does the problem require addressing systemic or structural issues rather than just individual instances?",
        "32. Is the problem time-sensitive or urgent, requiring immediate attention and action?",
        "33. What kinds of solution typically are produced for this kind of problem specification?",
        "34. Given the problem specification and the current best solution, have a guess about other possible solutions.",
        "35. Let’s imagine the current best solution is totally wrong, what other ways are there to think about the problem specification?",
        "36. What is the best way to modify this current best solution, given what you know about these kinds of problem specification?",
        "37. Ignoring the current best solution, create an entirely new solution to the problem.",
        // "38. Let’s think step by step.",
        "39. Let’s make a step by step plan and implement it with good notation and explanation."
      ];

      // Fetching insights step-by-step
      try {
        setState(() {
          loadingStatus = 'Selecting Reasoning Modules...';
        });
        // Step 1: Select Reasoning Modules
        String selectedModules = await apiService.selectReasoningModules(widget.question, reasoningModules) as String;
        String translationStructure = selectedModules;
        if (widget.language == 'Russian' || widget.language == 'Chinese') {
          translationStructure = await apiService.executeTranslationStructure(selectedModules, widget.question);
        }
        String translationStructure1 = translationStructure.replaceAll("**", "").replaceAll("*", "").replaceAll("#", "");
        selectedModulesInsights = _splitIntoInsights(translationStructure1);

        setState(() {
          loadingStatus = 'Adapting Reasoning Modules...';
        });
        // Step 2: Adapt Reasoning Modules
        String adaptedModules = await apiService.adaptReasoningModules(selectedModules, widget.question) as String;
        String translationStructure2 = adaptedModules;
        if (widget.language == 'Russian' || widget.language == 'Chinese') {
          String translationStructure2 = await apiService.executeTranslationStructure(adaptedModules, widget.question);
        }
        adaptedModulesInsights = _splitIntoInsights(translationStructure2);

        setState(() {
          loadingStatus = 'Implementing Reasoning Structure...';
        });
        // Step 3: Implement Reasoning Structure
        String reasoningStructure = await apiService.implementReasoningStructure(adaptedModules, widget.question) as String;
        String translationStructure3 = reasoningStructure;
        if (widget.language == 'Russian' || widget.language == 'Chinese') {
          String translationStructure3 = await apiService.executeTranslationStructure(reasoningStructure, widget.question);
        }
        reasoningStructureInsights = _splitIntoInsights(translationStructure3);

        setState(() {
          loadingStatus = 'Executing Reasoning Structure...';
        });
        // Step 4: Execute Reasoning Structure
        finalResult = await apiService.executeReasoningStructure(reasoningStructure, widget.question);

        finalResult = "\n### User's request:\n${widget.question}\n### Selected Reasoning Modules:\n$translationStructure1\n\n### Adapted Reasoning Modules:\n$translationStructure2\n\n### Implemented Reasoning Structure:\n$translationStructure3\n\n### Final Reasoning:\n${finalResult!}";

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<Insight> _splitIntoInsights(String content) {
    List<Insight> insights = [];
    List<String> lines = content.split('\n');
    for (var line in lines) {
      if (line.trim().isNotEmpty) {
        insights.add(Insight(title: '', content: line.trim()));
      }
    }
    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    insight: Insight(
                        title: 'Overall', content: finalResult ?? 'No result'),
                    initialQuestion: '',
                    apiKey: widget.apiKey,
                    proxy: widget.proxy,
                    useVpn: widget.useVpn,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ?  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(loadingStatus),
              ],
            ),
          )
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (finalResult != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OverallResultScreen(
                                    result: finalResult!,
                                    apiKey: widget.apiKey,
                                    proxy: widget.proxy,
                                    useVpn: widget.useVpn,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Final Result',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SectionTitle(title: 'User\'s Query:'),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        widget.question,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    buildSection('Selected Modules', isSelectedModulesExpanded,
                        () {
                      setState(() {
                        isSelectedModulesExpanded = !isSelectedModulesExpanded;
                      });
                    }, selectedModulesInsights),
                    buildSection('Adapted Modules', isAdaptedModulesExpanded,
                        () {
                      setState(() {
                        isAdaptedModulesExpanded = !isAdaptedModulesExpanded;
                      });
                    }, adaptedModulesInsights),
                    buildSection(
                        'Reasoning Structure', isReasoningStructureExpanded,
                        () {
                      setState(() {
                        isReasoningStructureExpanded =
                            !isReasoningStructureExpanded;
                      });
                    }, reasoningStructureInsights),
                    _buildTokenInformationSection(),
                  ],
                ),
    );
  }

  Widget buildSection(String title, bool isExpanded, VoidCallback toggleExpand, List<Insight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleExpand,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: insights.map((insight) => ListTile(
                title: Text(insight.content),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              )).toList(),
            ),
          ),
      ],
    );
  }
}

Widget _buildTokenInformationSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 10),
      Text(
        'Cumulative Token Information',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text('Total Prompt Tokens: $totalPromptTokens', style: TextStyle(fontSize: 12,  color: Colors.indigo,  ),),
      Text('Total Completion Tokens: $totalCompletionTokens', style: TextStyle(fontSize: 12,  color: Colors.indigo,  ),),
      Text('Total Tokens: $totalTokens', style: TextStyle(fontSize: 12,  color: Colors.indigo, fontWeight: FontWeight.bold ),),
      Text('Total Cost: \$${totalCost.toStringAsFixed(4)}', style: TextStyle(fontSize: 12,  color: Colors.indigo, fontWeight: FontWeight.bold ),),
      SizedBox(height: 16),
    ],
  );
}
