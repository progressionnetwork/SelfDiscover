import 'dart:typed_data';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:self_discover/widgets/markdown_view.dart';
import 'package:self_discover/screens/chat_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/insight.dart';
import 'package:flutter/services.dart';

class OverallResultScreen extends StatelessWidget {
  final String result;
  final String apiKey;
  final bool useVpn;
  final String proxy;

  OverallResultScreen(
      {required this.result, required this.apiKey, required this.proxy, required this.useVpn});

  final TextEditingController _controller = TextEditingController();

  Future<void> _generatePdf() async {
    final pdfData = await generatePdfFromMarkdown(result);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'report.pdf',
    );
  }

  Future<void> _generateAndSharePdf() async {
    try {
      final pdfData = await generatePdfFromMarkdown(result);
      await Printing.sharePdf(bytes: pdfData, filename: 'report.pdf');
    } catch (e) {
      // Handle error
      print('Error generating or sharing PDF: $e');
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<Uint8List> generatePdfFromMarkdown(String markdownContent) async {
    final pdf = pw.Document();

    // Load the font
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final markdownLines = markdownContent.split('\n');
    final pdfWidgets = markdownLines.map((line) => pw.Text(line, style: pw.TextStyle(font: ttf))).toList();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: pdfWidgets,
          );
        },
      ),
    );

    return await pdf.save();
  }

  void sharePdf(Uint8List pdfData) {
    Printing.sharePdf(bytes: pdfData, filename: 'report.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Final Answer'),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            tooltip: 'Copy to clipboard',
            onPressed: () {
              copyToClipboard(result);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Save as PDF',
            onPressed: _generateAndSharePdf,
          ),
          IconButton(
            icon: Icon(Icons.share),
            tooltip: 'Share as PDF',
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: MarkdownView(
                data: result,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                    ),
                    onSubmitted: (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(
                            insight: Insight(title: 'Overall', content: result),
                            initialQuestion: result + _controller.text,
                            apiKey: apiKey,
                            proxy: proxy,
                            useVpn: useVpn,)),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatScreen(
                          insight: Insight(title: 'Overall', content: result),
                          initialQuestion: result + _controller.text,
                          apiKey: apiKey,
                          proxy: proxy,
                          useVpn: useVpn,)
                            ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
