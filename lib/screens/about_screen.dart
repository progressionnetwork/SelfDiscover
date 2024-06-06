import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../widgets/markdown_view.dart';

class AboutScreen extends StatefulWidget {

  AboutScreen();

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: MarkdownView(data: """
![Local Image](assets/logo.png)

## [SELF-DISCOVER: Empowering LLMs with Self-Directed Reasoning](https://arxiv.org/abs/2402.03620) 

**Problem:** Large Language Models (LLMs) struggle with complex reasoning tasks, often failing to break down problems into manageable steps and apply critical thinking. Traditional prompting methods like Chain-of-Thought (CoT) rely on implicit reasoning, limiting their effectiveness.

**Solution:** SELF-DISCOVER is a novel framework that enables LLMs to self-discover and compose atomic reasoning modules, such as critical thinking and step-by-step reasoning, to tackle complex reasoning problems. This framework empowers LLMs to:

- Explicitly identify and select relevant reasoning modules.
- Compose these modules into a task-unique reasoning structure.
- Follow this structure during decoding, leading to improved reasoning performance.

### Key Features:

- **Self-Discovery:** LLMs actively identify and select relevant reasoning modules based on the task at hand.
- **Reasoning Structure Composition:** Modules are combined into a structured approach, providing a clear roadmap for the LLM's reasoning process.
- **Enhanced Reasoning Capabilities:** SELF-DISCOVER significantly improves LLMs' performance on challenging reasoning benchmarks, outperforming existing methods.
- **Compute Efficiency:** The framework requires significantly less computational resources compared to inference-intensive methods.
- **Generalization:** Reasoning structures discovered by powerful LLMs can be applied to smaller models, enhancing their reasoning abilities.

### Reasoning Modules:
1. How could I devise an experiment to help solve that problem?
2. Make a list of ideas for solving this problem, and apply them one by one to the problem to see if any progress can be made.
3. How can I simplify the problem so that it is easier to solve?
4. What are the key assumptions underlying this problem?
5. What are the potential risks and drawbacks of each solution?
6. What are the alternative perspectives or viewpoints on this problem?
7. What are the long-term implications of this problem and its solutions?
8. How can I break down this problem into smaller, more manageable parts?
9. Critical Thinking: This style involves analyzing the problem from different perspectives, questioning assumptions, and evaluating the evidence or information available. It focuses on logical reasoning, evidence-based decision-making, and identifying potential biases or flaws in thinking.
10. Try creative thinking, generate innovative and out-of-the-box ideas to solve the problem. Explore unconventional solutions, thinking beyond traditional boundaries, and encouraging imagination and originality.
11. Use systems thinking: Consider the problem as part of a larger system and understand the interconnectedness of various elements. Focus on identifying the underlying causes, feedback loops, and interdependencies that influence the problem, and developing holistic solutions that address the system as a whole.
12. Use Risk Analysis: Evaluate potential risks, uncertainties, and trade-offs associated with different solutions or approaches to a problem. Emphasize assessing the potential consequences and likelihood of success or failure, and making informed decisions based on a balanced analysis of risks and benefits.
13. What is the core issue or problem that needs to be addressed?
14. What are the underlying causes or factors contributing to the problem?
15. Are there any potential solutions or strategies that have been tried before? If yes, what were the outcomes and lessons learned?
16. What are the potential obstacles or challenges that might arise in solving this problem?
17. Are there any relevant data or information that can provide insights into the problem? If yes, what data sources are available, and how can they be analyzed?
18. Are there any stakeholders or individuals who are directly affected by the problem? What are their perspectives and needs?
19. What resources (financial, human, technological, etc.) are needed to tackle the problem effectively?
20. How can progress or success in solving the problem be measured or evaluated?
21. What indicators or metrics can be used?
22. Is the problem a technical or practical one that requires a specific expertise or skill set? Or is it more of a conceptual or theoretical problem?
23. Does the problem involve a physical constraint, such as limited resources, infrastructure, or space?
24. Is the problem related to human behavior, such as a social, cultural, or psychological issue?
25. Does the problem involve decision-making or planning, where choices need to be made under uncertainty or with competing objectives?
26. Is the problem an analytical one that requires data analysis, modeling, or optimization techniques?
27. Is the problem a design challenge that requires creative solutions and innovation?
28. Does the problem require addressing systemic or structural issues rather than just individual instances?
29. Is the problem time-sensitive or urgent, requiring immediate attention and action?
30. What kinds of solutions typically are produced for this kind of problem specification?
31. Given the problem specification and the current best solution, have a guess about other possible solutions.
32. Let’s imagine the current best solution is totally wrong, what other ways are there to think about the problem specification?
33. What is the best way to modify this current best solution, given what you know about these kinds of problem specification?
34. Ignoring the current best solution, create an entirely new solution to the problem.
35. Let’s make a step-by-step plan and implement it with good notation and explanation.

### Project Summary:

SELF-DISCOVER is a groundbreaking framework that revolutionizes LLM reasoning by enabling them to self-discover and compose reasoning modules. This project has the potential to significantly enhance the capabilities of LLMs, making them more adept at tackling complex reasoning problems.

### Application:

The SELF-DISCOVER framework can be integrated into various applications, including:

- **Reasoning-based chatbots:** Empowering chatbots to handle more complex user queries and provide more insightful responses.
- **Question answering systems:** Improving the accuracy and comprehensiveness of answers to complex questions.
- **Decision-making tools:** Assisting users in making informed decisions by providing structured reasoning and analysis.

### Impact:

SELF-DISCOVER has the potential to significantly advance the field of natural language processing by enabling LLMs to perform more complex reasoning tasks. This will lead to more sophisticated and intelligent applications that can better understand and respond to human needs.
"""),
            ),
          ],
        ),
      ),
    );
  }
}