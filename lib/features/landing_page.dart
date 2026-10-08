import 'package:flutter/material.dart';
import 'package:pdf_buddy/features/merge_pdf_page.dart';
import 'package:pdf_buddy/features/split_pdf_page.dart';
import 'package:pdf_buddy/utils/theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Widget _buildOperationCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppTheme.primaryBlue),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkBackground,
              Color(0xFF101820),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 48,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PDF Buddy',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Merge and split PDFs in your browser. Your files stay on your device.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textColor.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildOperationCard(
                      context,
                      title: 'Merge PDFs',
                      description: 'Combine files in the order you choose.',
                      icon: Icons.merge_type,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MergePDFPage(),
                            ),
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildOperationCard(
                      context,
                      title: 'Split a PDF',
                      description: 'Extract a page or range of pages.',
                      icon: Icons.call_split,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SplitPDFPage(),
                            ),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppTheme.accentBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Private by design. PDF processing happens locally.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
