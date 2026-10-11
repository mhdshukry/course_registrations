import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../domain/models.dart';
import '../../services/app_service.dart';

class HodDashboardRedesigned extends StatefulWidget {
  final int selectedSection;
  final ValueChanged<int>? onNavigate;
  const HodDashboardRedesigned({
    super.key,
    this.selectedSection = 0,
    this.onNavigate,
  });

  @override
  State<HodDashboardRedesigned> createState() => _HodDashboardRedesignedState();
}

class _HodDashboardRedesignedState extends State<HodDashboardRedesigned> {
  late int section;
  String search = '';
  int _timetableLevelFilter = 0; // 0 = All Levels, 1..4
  String _timetableDayFilter = 'All'; // 'All', 'Monday', 'Tuesday', ...
  int _offeringsLevelFilter = 0; // 0 = All Levels, 1..4

  @override
  void initState() {
    super.initState();
    section = widget.selectedSection;
  }

  @override
  void didUpdateWidget(covariant HodDashboardRedesigned oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSection != widget.selectedSection) {
      section = widget.selectedSection;
    }
  }

  void go(int value) {
    setState(() => section = value);
    widget.onNavigate?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppService>();
    return ColoredBox(
      color: RuslColors.bgCream,
      child: switch (section) {
        0 => _overview(app),
        1 => _queue(app),
        2 => _offerings(app),
        3 => _timetable(app),
        4 => _requests(app),
        5 => _students(app),
        6 => _reports(app),
        _ => _profile(),
      },
    );
  }

  Widget _overview(AppService app) => _Page(
    title: 'Department Overview',
    subtitle: 'Information & Communication Technology • Faculty of Technology',
    badge: app.isRegistrationOpen ? 'Registration open' : 'Registration closed',
    child: Column(
      children: [
        _Grid(
          children: [
            _Metric(
              'Awaiting review',
              app.activeRegistrationStatus == RegistrationStatus.submitted
                  ? '1'
                  : '0',
              Icons.pending_actions_rounded,
              RuslColors.warningOrange,
            ),
            const _Metric(
              'Department students',
              '148',
              Icons.groups_rounded,
              RuslColors.primaryMaroon,
            ),
            _Metric(
              'Course offerings',
              '${app.courseOfferings.length}',
              Icons.menu_book_rounded,
              Colors.blue,
            ),
            _Metric(
              'Pending petitions',
              '${app.specialRequests.where((r) => r.status == SpecialRequestStatus.pending).length}',
              Icons.description_rounded,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Card(
          title: 'Priority actions',
          subtitle: 'Department tasks requiring attention',
          child: _ActionGrid(
            actions: [
              _Action(
                Icons.fact_check_rounded,
                'Registration queue',
                'Verify credits and curriculum',
                () => go(1),
              ),
              _Action(
                Icons.menu_book_rounded,
                'Course offerings',
                'Curriculum & staff allocations',
                () => go(2),
              ),
              _Action(
                Icons.calendar_month_rounded,
                'Timetable scheduler',
                'Clash-free slot assignment for all levels',
                () => go(3),
              ),
              _Action(
                Icons.description_rounded,
                'Special petitions',
                'Academic exception requests',
                () => go(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _registrationCard(app),
      ],
    ),
  );

  Widget _queue(AppService app) => _Page(
    title: 'Endorsement Queue',
    subtitle: 'Department review before faculty registry processing',
    child: _registrationCard(app),
  );

  Widget _registrationCard(AppService app) => _Card(
    title: app.activeStudent.fullName,
    subtitle:
        '${app.activeStudent.registrationNumber} • ${app.activeStudent.programmeName}',
    child: LayoutBuilder(
      builder: (context, box) {
        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${app.totalSelectedCredits} credits • ${app.selectedOfferingIds.length} subjects',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _Pill(
              app.activeRegistrationStatus.label,
              _statusColor(app.activeRegistrationStatus),
            ),
          ],
        );
        final button = FilledButton.icon(
          onPressed: () => _review(app),
          icon: const Icon(Icons.visibility_rounded),
          label: const Text('Open review'),
        );
        return box.maxWidth < 560
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [info, const SizedBox(height: 14), button],
              )
            : Row(
                children: [
                  Expanded(child: info),
                  button,
                ],
              );
      },
    ),
  );

  Widget _offerings(AppService app) {
    final filteredOfferings = _offeringsLevelFilter == 0
        ? app.courseOfferings
        : app.courseOfferings.where((o) {
            final c = app.courses.firstWhere(
              (item) => item.id == o.courseId,
              orElse: () => app.courses.first,
            );
            return c.level == _offeringsLevelFilter;
          }).toList();

    return _Page(
      title: 'Course Offerings & Lecturers',
      subtitle: 'Department course modules, capacity tracking, and assigned academic staff',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cohort Level Selector Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    Icon(Icons.layers_rounded, size: 16, color: RuslColors.textMuted),
                    Text(
                      'FILTER BY COHORT LEVEL (LEVELS 1 - 4):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: RuslColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 1, 2, 3, 4].map((lvl) {
                    final selected = _offeringsLevelFilter == lvl;
                    final count = lvl == 0
                        ? app.courseOfferings.length
                        : app.courseOfferings.where((o) {
                            final c = app.courses.firstWhere(
                              (item) => item.id == o.courseId,
                              orElse: () => app.courses.first,
                            );
                            return c.level == lvl;
                          }).length;
                    final label = lvl == 0
                        ? 'All Levels ($count Modules)'
                        : 'Level $lvl ($count Modules)';
                    final color = lvl == 0 ? RuslColors.darkText : _getHodLevelColor(lvl);
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _offeringsLevelFilter = lvl),
                      selectedColor: lvl == 0
                          ? RuslColors.accentYellow
                          : color.withValues(alpha: 0.25),
                      backgroundColor: RuslColors.cardSubtle,
                      labelStyle: TextStyle(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected && lvl != 0 ? color : RuslColors.darkText,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Policy notice card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RuslColors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: RuslColors.accentYellow.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.school_rounded, color: RuslColors.darkText, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'State University Policy: Timetable scheduling is conducted on the dedicated Timetable page to guarantee 100% clash-free sessions across all Levels 1-4. Course capacities adjust to accommodate full cohorts.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RuslColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Offerings List (Strictly without timetable putting section)
          ...filteredOfferings.map((offering) {
            final course = app.courses.firstWhere(
              (c) => c.id == offering.courseId,
              orElse: () => app.courses.first,
            );
            final isCompulsory = course.courseType == CourseType.compulsory;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _Card(
                title: '${course.code}: ${course.title}',
                subtitle:
                    '${course.creditValue} Credits • Semester ${course.semester} • ${offering.lecturerName}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildHodLevelPill(course.level),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isCompulsory
                                    ? RuslColors.darkText.withValues(alpha: 0.08)
                                    : RuslColors.accentYellow.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCompulsory ? 'COMPULSORY CORE' : 'ELECTIVE OPTION',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: RuslColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${offering.currentRegisteredCount} / ${offering.maxCapacity} Enrolled',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: offering.maxCapacity > 0
                          ? (offering.currentRegisteredCount / offering.maxCapacity).clamp(0.0, 1.0)
                          : 0.0,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: RuslColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _capacity(app, offering, course),
                          icon: const Icon(Icons.group_add_rounded, size: 16),
                          label: const Text('Adjust Capacity'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _showEnrolledRosterDialog(offering, course),
                          icon: const Icon(Icons.people_alt_outlined, size: 16),
                          label: const Text('View Enrolled Students'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _timetable(AppService app) {
    final clashes = app.getActiveTimetableClashes();

    final allSlotsWithInfo = <({CourseOffering offering, Course course, TimetableSlot slot})>[];
    for (final off in app.courseOfferings) {
      final c = app.courses.firstWhere(
        (item) => item.id == off.courseId,
        orElse: () => app.courses.first,
      );
      for (final s in off.slots) {
        allSlotsWithInfo.add((offering: off, course: c, slot: s));
      }
    }

    final distinctVenues = allSlotsWithInfo.map((e) => e.slot.venue.trim()).toSet();

    final filteredSlots = allSlotsWithInfo.where((item) {
      if (_timetableLevelFilter != 0 && item.course.level != _timetableLevelFilter) {
        return false;
      }
      if (_timetableDayFilter != 'All' && item.slot.dayOfWeek != _timetableDayFilter) {
        return false;
      }
      return true;
    }).toList();

    final daysToDisplay = _timetableDayFilter == 'All'
        ? const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
        : [_timetableDayFilter];

    return _Page(
      title: 'Timetable Scheduling & Assignment',
      subtitle: 'Conflict-free lecture, practical & tutorial slot scheduling across all Levels 1 - 4',
      badge: clashes.isEmpty ? 'Conflict-Free' : '${clashes.length} Clash Alert',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conflict Status Banner
          if (clashes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RuslColors.successGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: RuslColors.successGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: RuslColors.successGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '100% Conflict-Free Timetable Verified',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: RuslColors.successGreen,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Zero venue overlaps, zero cohort level clashes, and zero lecturer scheduling conflicts across all undergraduate Levels 1 - 4.',
                          style: TextStyle(fontSize: 12, color: RuslColors.darkText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${clashes.length} Timetable Clash(es) Detected',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...clashes.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Metrics Grid
          _Grid(
            children: [
              _Metric(
                'Total Assigned Slots',
                '${allSlotsWithInfo.length}',
                Icons.calendar_month_rounded,
                RuslColors.primaryMaroon,
              ),
              _Metric(
                'Timetable Status',
                clashes.isEmpty ? 'Conflict-Free' : '${clashes.length} Clashes',
                clashes.isEmpty ? Icons.check_circle_outline_rounded : Icons.warning_rounded,
                clashes.isEmpty ? RuslColors.successGreen : Colors.red,
              ),
              _Metric(
                'Teaching Venues',
                '${distinctVenues.length}',
                Icons.meeting_room_rounded,
                Colors.blue,
              ),
              const _Metric(
                'Academic Cohorts',
                'Levels 1 - 4 Active',
                Icons.layers_rounded,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Bar & Assign Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'TIMETABLE CONTROLS & ASSIGNMENT:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: RuslColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAssignSlotDialog(app),
                      icon: const Icon(Icons.add_alarm_rounded, size: 18),
                      label: const Text('Assign Lecture Slot'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Level Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Level Filter (Levels 1 - 4):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [0, 1, 2, 3, 4].map((lvl) {
                        final selected = _timetableLevelFilter == lvl;
                        final count = lvl == 0
                            ? allSlotsWithInfo.length
                            : allSlotsWithInfo.where((item) => item.course.level == lvl).length;
                        final label = lvl == 0 ? 'All Levels ($count)' : 'Level $lvl ($count)';
                        final color = lvl == 0 ? RuslColors.darkText : _getHodLevelColor(lvl);
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => setState(() => _timetableLevelFilter = lvl),
                          selectedColor: lvl == 0
                              ? RuslColors.accentYellow
                              : color.withValues(alpha: 0.25),
                          backgroundColor: RuslColors.cardSubtle,
                          labelStyle: TextStyle(
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected && lvl != 0 ? color : RuslColors.darkText,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Day Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Day Filter (Monday - Friday):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((d) {
                        final selected = _timetableDayFilter == d;
                        final count = d == 'All'
                            ? allSlotsWithInfo.length
                            : allSlotsWithInfo.where((item) => item.slot.dayOfWeek == d).length;
                        return ChoiceChip(
                          label: Text('$d ($count)'),
                          selected: selected,
                          onSelected: (_) => setState(() => _timetableDayFilter = d),
                          selectedColor: RuslColors.accentYellow,
                          backgroundColor: RuslColors.cardSubtle,
                          labelStyle: TextStyle(
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            color: RuslColors.darkText,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Daily Schedule Matrix
          ...daysToDisplay.map((day) {
            final daySlots = filteredSlots
                .where((item) => item.slot.dayOfWeek == day)
                .toList();

            daySlots.sort((a, b) => a.slot.startTime.compareTo(b.slot.startTime));

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RuslColors.borderGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: RuslColors.primaryMaroon.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: RuslColors.primaryMaroon,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            day.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: daySlots.isEmpty
                              ? RuslColors.cardSubtle
                              : RuslColors.accentYellow.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${daySlots.length} Sessions Scheduled',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (daySlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.event_busy_rounded, size: 32, color: RuslColors.textMuted),
                          const SizedBox(height: 6),
                          Text(
                            'No sessions scheduled on $day for selected filter.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: RuslColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...daySlots.map((item) {
                      final slot = item.slot;
                      final course = item.course;
                      final offering = item.offering;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RuslColors.cardSubtle,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: RuslColors.borderGrey.withValues(alpha: 0.8),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, box) {
                            final isNarrow = box.maxWidth < 500;

                            final timeBadge = Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: RuslColors.borderGrey),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${slot.startTime} – ${slot.endTime}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: RuslColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: slot.groupType == 'Practical'
                                          ? Colors.blue.withValues(alpha: 0.15)
                                          : Colors.teal.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      slot.groupType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: slot.groupType == 'Practical'
                                            ? Colors.blue[800]
                                            : Colors.teal[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            final mainDetails = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _buildHodLevelPill(course.level),
                                    Text(
                                      course.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isNarrow ? (box.maxWidth - 20).clamp(80.0, 500.0) : 380,
                                      ),
                                      child: Text(
                                        course.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                          color: RuslColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: isNarrow ? (box.maxWidth - 40).clamp(80.0, 400.0) : 320,
                                          ),
                                          child: Text(
                                            slot.venue,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.person_outline_rounded,
                                          size: 15,
                                          color: RuslColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: isNarrow ? (box.maxWidth - 40).clamp(80.0, 400.0) : 320,
                                          ),
                                          child: Text(
                                            offering.lecturerName,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: RuslColors.textMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );

                            final deleteButton = IconButton(
                              tooltip: 'Remove Timetable Slot',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => _deleteTimetableSlotDialog(
                                app,
                                offering,
                                slot,
                                course,
                              ),
                            );

                            if (isNarrow) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: timeBadge),
                                      deleteButton,
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  mainDetails,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                timeBadge,
                                const SizedBox(width: 14),
                                Expanded(child: mainDetails),
                                deleteButton,
                              ],
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _requests(AppService app) => _Page(
    title: 'Special Petitions & Waivers',
    subtitle: 'Department-level academic exception review',
    child: app.specialRequests.isEmpty
        ? const _Empty(
            'No petitions submitted',
            'Student requests will appear here.',
          )
        : Column(
            children: app.specialRequests
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _Card(
                      title: r.requestType,
                      subtitle: '${r.studentName} • ${r.status.label}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.explanation),
                          if (r.status == SpecialRequestStatus.pending) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => app.reviewSpecialRequest(
                                    r.id,
                                    SpecialRequestStatus.rejected,
                                  ),
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('Reject'),
                                ),
                                FilledButton.icon(
                                  onPressed: () => app.reviewSpecialRequest(
                                    r.id,
                                    SpecialRequestStatus.approved,
                                  ),
                                  icon: const Icon(Icons.check_rounded),
                                  label: const Text('Approve'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
  );

  Widget _students(AppService app) {
    final visible = _studentData
        .where(
          (s) => '${s.$1} ${s.$2}'.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();
    return _Page(
      title: 'Department Student Directory',
      subtitle: 'ICT students • department-scoped access',
      child: Column(
        children: [
          _Toolbar(
            TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Search student or registration number',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...visible.map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  backgroundColor: RuslColors.accentYellow,
                  child: Text(
                    s.$1.split(' ').map((p) => p[0]).take(2).join(),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                title: Text(
                  s.$1,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('${s.$2} • Level 3'),
                trailing: Text(
                  s.$3.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reports(AppService app) => _Page(
    title: 'Department Reports & Analytics',
    subtitle: 'Registration and curriculum compliance',
    child: Column(
      children: [
        _Grid(
          children: [
            const _Metric(
              'Endorsement rate',
              '91%',
              Icons.how_to_reg_rounded,
              RuslColors.successGreen,
            ),
            _Metric(
              'Selected credits',
              '${app.totalSelectedCredits}',
              Icons.credit_score_rounded,
              Colors.blue,
            ),
            const _Metric(
              'Average CGPA',
              '3.31',
              Icons.school_rounded,
              Colors.purple,
            ),
            const _Metric(
              'At-risk students',
              '7',
              Icons.warning_amber_rounded,
              RuslColors.warningOrange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _Card(
          title: 'Registration distribution',
          subtitle: 'Current department snapshot',
          child: Column(
            children: [
              _Progress('Department endorsed', .78, '116'),
              _Progress('Awaiting review', .14, '21'),
              _Progress('Changes requested', .05, '7'),
              _Progress('Draft', .03, '4'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _profile() => const _Page(
    title: 'HoD Profile & Authority',
    subtitle: 'Department-scoped responsibilities',
    child: Column(
      children: [
        _Card(
          title: 'Dr. Lahiru Jayasuriya',
          subtitle:
              'Head, Department of Information & Communication Technology',
          child: Column(
            children: [
              _Info('Faculty', 'Faculty of Technology'),
              _Info('Scope', 'ICT Department only'),
              _Info('Email', 'hod.ict@tec.rjt.ac.lk'),
              _Info('Authority', 'Department endorsement'),
            ],
          ),
        ),
        SizedBox(height: 14),
        _Card(
          title: 'Authorized actions',
          subtitle: 'Access outside this department is prohibited',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Review registrations')),
              Chip(label: Text('Manage offerings')),
              Chip(label: Text('Review petitions')),
              Chip(label: Text('Department reports')),
            ],
          ),
        ),
      ],
    ),
  );

  Future<void> _review(AppService app) async {
    final comments = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: RuslColors.accentYellow,
                      child: Icon(Icons.fact_check_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registration Review',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(app.activeStudent.registrationNumber),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _Info('Student', app.activeStudent.fullName),
                _Info('Credits', '${app.totalSelectedCredits}'),
                _Info('Status', app.activeRegistrationStatus.label),
                const Divider(height: 26),
                const Text(
                  'Selected subjects',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                ...app.courseOfferings
                    .where((o) => app.selectedOfferingIds.contains(o.id))
                    .map((o) {
                      final c = app.courses.firstWhere(
                        (item) => item.id == o.courseId,
                      );
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle_rounded,
                          color: RuslColors.successGreen,
                        ),
                        title: Text('${c.code} • ${c.title}'),
                        trailing: Text('${c.creditValue} Cr'),
                      );
                    }),
                TextField(
                  controller: comments,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'HoD comments'),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, box) {
                    final change = OutlinedButton.icon(
                      onPressed:
                          app.activeRegistrationStatus ==
                              RegistrationStatus.submitted
                          ? () {
                              final reviewComments = comments.text.trim();
                              Navigator.pop(ctx);
                              app.requestChangesByHod(reviewComments);
                            }
                          : null,
                      icon: const Icon(Icons.rate_review_rounded),
                      label: const Text('Request changes'),
                    );
                    final approve = FilledButton.icon(
                      onPressed:
                          app.activeRegistrationStatus ==
                              RegistrationStatus.submitted
                          ? () {
                              final reviewComments = comments.text.trim();
                              Navigator.pop(ctx);
                              app.approveByHod(reviewComments);
                            }
                          : null,
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('Endorse'),
                    );
                    return box.maxWidth < 420
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              change,
                              const SizedBox(height: 8),
                              approve,
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              change,
                              const SizedBox(width: 8),
                              approve,
                            ],
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // The dialog route is still animating after its Future completes. Its
    // TextField can therefore access the controller during the reverse
    // transition, so disposing it here causes a post-endorsement crash.
  }

  Future<void> _capacity(
    AppService app,
    CourseOffering offering,
    Course course,
  ) async {
    final input = TextEditingController(text: '5');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Increase ${course.code} capacity'),
        content: TextField(
          controller: input,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Additional seats',
            helperText: 'Current: ${offering.maxCapacity}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(input.text) ?? 0;
              if (value > 0) app.increaseOfferingCapacity(offering.id, value);
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
    input.dispose();
  }

  Future<void> _deleteTimetableSlotDialog(
    AppService app,
    CourseOffering offering,
    TimetableSlot slot,
    Course course,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Timetable Slot • ${course.code}'),
        content: Text(
          'Are you sure you want to remove the ${slot.dayOfWeek} (${slot.startTime}–${slot.endTime}) session at ${slot.venue}?\n\nThis will free up the venue and schedule slot for other courses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Slot'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      app.deleteTimetableSlot(offering.id, slot.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timetable slot for ${course.code} removed successfully.'),
          ),
        );
      }
    }
  }

  void _showEnrolledRosterDialog(CourseOffering offering, Course course) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${course.code}: ${course.title}'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Enrolled: ${offering.currentRegisteredCount} / ${offering.maxCapacity} Students (Level ${course.level})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Student Roster Sample:',
                style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
              ),
              const SizedBox(height: 6),
              ...[
                'ICT/2021/045 - M. N. Mohamed Nafis (Regular)',
                'ICT/2021/001 - Amaya Perera (Regular)',
                'ICT/2021/002 - Kasun Silva (Regular)',
                'ICT/2021/003 - Tharushi Fernando (Regular)',
                'ICT/2021/004 - Dilan Bandara (Regular)',
                'ICT/2021/005 - Nethmi Herath (Regular)',
                '... and ${offering.currentRegisteredCount > 6 ? offering.currentRegisteredCount - 6 : 0} additional students in department register.',
              ].map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(s, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignSlotDialog(AppService app) async {
    if (app.courseOfferings.isEmpty) return;

    var selectedOfferingId = app.courseOfferings.first.id;
    if (_timetableLevelFilter != 0) {
      final matching = app.courseOfferings.where((o) {
        final c = app.courses.firstWhere(
          (item) => item.id == o.courseId,
          orElse: () => app.courses.first,
        );
        return c.level == _timetableLevelFilter;
      }).toList();
      if (matching.isNotEmpty) {
        selectedOfferingId = matching.first.id;
      }
    }

    var day = _timetableDayFilter != 'All' ? _timetableDayFilter : 'Monday';
    var groupType = 'Lecture';
    final start = TextEditingController(text: '08:30');
    final end = TextEditingController(text: '10:30');
    final venue = TextEditingController(text: 'Technology Complex Hall 01');

    final standardVenues = [
      'Technology Complex Hall 01',
      'Technology Complex Hall 02',
      'Technology Complex Hall 03',
      'Faculty Main Auditorium',
      'ICT Lab 01',
      'ICT Lab 02',
      'ICT Lab 03',
      'Networking & Cloud Lab',
      'AI & Deep Learning Research Lab',
      'Embedded Systems Lab',
      'Cybersecurity Lab',
      'Mobile Computing Lab',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) {
          final clashError = app.checkTimetableClash(
            offeringId: selectedOfferingId,
            dayOfWeek: day,
            startTime: start.text.trim(),
            endTime: end.text.trim(),
            venue: venue.text.trim(),
          );

          final selectedOffering = app.courseOfferings.firstWhere(
            (o) => o.id == selectedOfferingId,
            orElse: () => app.courseOfferings.first,
          );
          final selectedCourse = app.courses.firstWhere(
            (c) => c.id == selectedOffering.courseId,
            orElse: () => app.courses.first,
          );

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: RuslColors.primaryMaroon),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Assign Timetable Slot',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                _buildHodLevelPill(selectedCourse.level),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign a weekly teaching session across Level 1 - 4 modules. Conflict-free validation actively checks venue, cohort level, and lecturer availability.',
                      style: TextStyle(fontSize: 12, color: RuslColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Course Offering Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedOfferingId,
                      decoration: const InputDecoration(
                        labelText: 'Course Module (All Levels 1 - 4)',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      isExpanded: true,
                      items: app.courseOfferings.map((offering) {
                        final course = app.courses.firstWhere(
                          (c) => c.id == offering.courseId,
                          orElse: () => app.courses.first,
                        );
                        return DropdownMenuItem(
                          value: offering.id,
                          child: Text(
                            '[L${course.level}] ${course.code} • ${course.title} (${offering.lecturerName})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => update(() => selectedOfferingId = v ?? selectedOfferingId),
                    ),
                    const SizedBox(height: 12),

                    // Day of Week & Group Type
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: day,
                            decoration: const InputDecoration(
                              labelText: 'Day of Week',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            items: const [
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                            ]
                                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) => update(() => day = v ?? day),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: groupType,
                            decoration: const InputDecoration(
                              labelText: 'Session Type',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: const ['Lecture', 'Practical', 'Tutorial']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => update(() => groupType = v ?? groupType),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Start Time & End Time
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: start,
                            decoration: const InputDecoration(
                              labelText: 'Start Time (e.g. 08:30)',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            onChanged: (_) => update(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: end,
                            decoration: const InputDecoration(
                              labelText: 'End Time (e.g. 10:30)',
                              prefixIcon: Icon(Icons.timelapse_rounded),
                            ),
                            onChanged: (_) => update(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick University Time Slots
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ('08:30', '10:30', '08:30–10:30'),
                        ('10:30', '12:30', '10:30–12:30'),
                        ('13:00', '15:00', '13:00–15:00'),
                        ('15:00', '17:00', '15:00–17:00'),
                      ].map((slot) {
                        return ActionChip(
                          label: Text(slot.$3, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            start.text = slot.$1;
                            end.text = slot.$2;
                            update(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Venue Selection
                    DropdownButtonFormField<String>(
                      initialValue: standardVenues.contains(venue.text) ? venue.text : standardVenues.first,
                      decoration: const InputDecoration(
                        labelText: 'Lecture Hall / Laboratory Venue',
                        prefixIcon: Icon(Icons.meeting_room_outlined),
                      ),
                      isExpanded: true,
                      items: standardVenues
                          .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          venue.text = v;
                          update(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Real-time Clash Indicator Box
                    if (clashError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                clashError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RuslColors.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: RuslColors.successGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_rounded, color: RuslColors.successGreen, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '✓ Conflict-Free Slot: Venue, Level cohort, and Lecturer are completely available.',
                                style: TextStyle(
                                  color: RuslColors.successGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Assign Slot'),
                onPressed: () {
                  final error = app.createTimetableSlot(
                    offeringId: selectedOfferingId,
                    dayOfWeek: day,
                    startTime: start.text.trim(),
                    endTime: end.text.trim(),
                    venue: venue.text.trim(),
                    groupType: groupType,
                  );
                  if (error == null) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Timetable slot assigned successfully without clash.'),
                        backgroundColor: RuslColors.successGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );

    start.dispose();
    end.dispose();
    venue.dispose();
  }
}

Color _getHodLevelColor(int level) => switch (level) {
  1 => const Color(0xFF2563EB),
  2 => const Color(0xFF0D9488),
  3 => const Color(0xFF7C3AED),
  4 => const Color(0xFFD97706),
  _ => RuslColors.primaryMaroon,
};

Widget _buildHodLevelPill(int level) {
  final color = _getHodLevelColor(level);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Text(
      'LEVEL $level',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _Page extends StatelessWidget {
  final String title, subtitle;
  final String? badge;
  final Widget child;
  const _Page({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final mobile = box.maxWidth < 700;
      return ListView(
        padding: EdgeInsets.fromLTRB(
          mobile ? 14 : 24,
          18,
          mobile ? 14 : 24,
          30,
        ),
        children: [
          if (mobile) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: RuslColors.textMuted)),
            if (badge != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _Pill(badge!, RuslColors.successGreen),
                ),
              ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: RuslColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (badge != null) _Pill(badge!, RuslColors.successGreen),
              ],
            ),
          const SizedBox(height: 20),
          child,
        ],
      );
    },
  );
}

class _Grid extends StatelessWidget {
  final List<Widget> children;
  const _Grid({required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final count = box.maxWidth >= 1050
          ? 4
          : box.maxWidth >= 620
          ? 2
          : 1;
      const gap = 12.0;
      final width = (box.maxWidth - gap * (count - 1)) / count;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: children
            .map((c) => SizedBox(width: width, child: c))
            .toList(),
      );
    },
  );
}

class _Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Metric(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: RuslColors.borderGrey),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: RuslColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _Card({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: RuslColors.borderGrey),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: RuslColors.textMuted),
        ),
        const Divider(height: 24),
        child,
      ],
    ),
  );
}

class _Action {
  final IconData icon;
  final String title, detail;
  final VoidCallback tap;
  const _Action(this.icon, this.title, this.detail, this.tap);
}

class _ActionGrid extends StatelessWidget {
  final List<_Action> actions;
  const _ActionGrid({required this.actions});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = box.maxWidth < 620 ? box.maxWidth : (box.maxWidth - 20) / 3;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: actions
            .map(
              (a) => SizedBox(
                width: width,
                child: Material(
                  color: RuslColors.cardSubtle,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: a.tap,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(a.icon, color: RuslColors.primaryMaroon),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  a.detail,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RuslColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class _Toolbar extends StatelessWidget {
  final Widget child;
  const _Toolbar(this.child);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RuslColors.borderGrey),
    ),
    child: child,
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
    ),
  );
}

class _Empty extends StatelessWidget {
  final String title, detail;
  const _Empty(this.title, this.detail);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: RuslColors.borderGrey),
    ),
    child: Column(
      children: [
        const Icon(Icons.inbox_rounded, size: 42, color: RuslColors.textMuted),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: RuslColors.textMuted),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  final String label, value;
  const _Info(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  final String label, count;
  final double value;
  const _Progress(this.label, this.value, this.count);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(count),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: value),
      ],
    ),
  );
}

const _studentData = [
  ('Nafis Ahamed', 'ICT/2021/045', 3.42),
  ('Amaya Perera', 'ICT/2021/012', 3.65),
  ('Kasun Silva', 'ICT/2021/028', 3.18),
  ('Tharushi Fernando', 'ICT/2021/051', 3.77),
  ('Dilan Bandara', 'ICT/2021/067', 2.91),
  ('Nethmi Herath', 'ICT/2021/083', 3.55),
];
Color _statusColor(RegistrationStatus status) => switch (status) {
  RegistrationStatus.submitted => RuslColors.warningOrange,
  RegistrationStatus.departmentApproved ||
  RegistrationStatus.facultyApproved ||
  RegistrationStatus.registered ||
  RegistrationStatus.locked => RuslColors.successGreen,
  RegistrationStatus.rejected => RuslColors.errorRed,
  RegistrationStatus.changesRequested => Colors.purple,
  RegistrationStatus.draft => RuslColors.textMuted,
};
