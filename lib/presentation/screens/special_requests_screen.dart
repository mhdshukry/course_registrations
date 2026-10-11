import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';

class SpecialRequestsScreen extends StatefulWidget {
  const SpecialRequestsScreen({super.key});
  @override
  State<SpecialRequestsScreen> createState() => _SpecialRequestsScreenState();
}

class _SpecialRequestsScreenState extends State<SpecialRequestsScreen> {
  final _reason = TextEditingController();
  String _type = 'Credit Overload';
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: RuslColors.darkText,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACADEMIC SUPPORT',
                style: TextStyle(
                  color: RuslColors.accentYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Special Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Submit an academic exception request with a clear justification.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, box) {
            final form = _requestForm(app);
            final history = _history(app);
            return box.maxWidth >= 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form),
                      const SizedBox(width: 20),
                      Expanded(child: history),
                    ],
                  )
                : Column(children: [form, const SizedBox(height: 20), history]);
          },
        ),
      ],
    );
  }

  Widget _requestForm(AppService app) => _panel(
    'New request',
    'Provide the information required for review',
    Icons.note_add_outlined,
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request type',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: _type,
          items: const [
            'Credit Overload',
            'Prerequisite Waiver',
            'Late Registration',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        const SizedBox(height: 16),
        const Text(
          'Justification',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _reason,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText:
                'Explain the academic reason and include relevant details...',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              if (_reason.text.trim().length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a clear justification.'),
                  ),
                );
                return;
              }
              app.submitSpecialRequest(_type, _reason.text.trim());
              _reason.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Special request submitted.')),
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Submit request'),
          ),
        ),
      ],
    ),
  );

  Widget _history(AppService app) => _panel(
    'Request history',
    '${app.specialRequests.length} submitted requests',
    Icons.history_rounded,
    app.specialRequests.isEmpty
        ? const Text(
            'No special requests submitted.',
            style: TextStyle(color: RuslColors.textMuted),
          )
        : Column(
            children: app.specialRequests
                .map(
                  (request) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: RuslColors.cardSubtle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                request.requestType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _status(request.status),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          request.explanation,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${request.submittedAt.day.toString().padLeft(2, '0')}/${request.submittedAt.month.toString().padLeft(2, '0')}/${request.submittedAt.year}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: RuslColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
  );

  Widget _panel(String title, String subtitle, IconData icon, Widget child) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: RuslColors.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: RuslColors.accentYellow.withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: RuslColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      );

  Widget _status(SpecialRequestStatus status) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: switch (status) {
        SpecialRequestStatus.approved =>
          RuslColors.successGreen.withValues(alpha: .15),
        SpecialRequestStatus.rejected =>
          RuslColors.errorRed.withValues(alpha: .15),
        SpecialRequestStatus.pending =>
          RuslColors.accentYellow.withValues(alpha: .4),
      },
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.label.toUpperCase(),
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w900,
        color: switch (status) {
          SpecialRequestStatus.approved => RuslColors.successGreen,
          SpecialRequestStatus.rejected => RuslColors.errorRed,
          SpecialRequestStatus.pending => RuslColors.darkText,
        },
      ),
    ),
  );
}
