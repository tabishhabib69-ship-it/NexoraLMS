// ===== FILE GUIDE: lib/screens/timetable/timetable_screen.dart
// WHAT IT DOES : Timetable (PDF page 5) for students and faculty.
// MANAGES      : Day/Week view, Done/Now/Next status, personal study events (add with clash check, delete), upcoming exam card.
// USED BY      : Dashboard, + quick actions, faculty dashboard/profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/academics.dart';
import '../../models/timetable.dart';
import '../../services/academic_service.dart';
import '../../services/my_data.dart';
import '../../services/schedule_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/time_util.dart';
import '../../widgets/ui_kit.dart';
import '../../widgets/uni_widgets.dart';
import '../student/planner/exam_planner_screen.dart';

/// Daily / weekly timetable (PDF page 5) with live class status, personal
/// study events and upcoming exams. Used by students and faculty.
class TimetableScreen extends StatefulWidget {
  final DateTime? initialDay;
  final bool openAddEvent;
  final bool faculty;

  const TimetableScreen({super.key, this.initialDay, this.openAddEvent = false, this.faculty = false});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late DateTime _day = widget.initialDay ?? DateTime.now();
  bool _week = false;

  @override
  void initState() {
    super.initState();
    if (widget.openAddEvent) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addEvent());
    }
  }

  Future<void> _addEvent() async {
    final created = await showModalBottomSheet<CalendarEvent>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddEventSheet(initialDay: _day),
    );
    if (created != null && mounted) {
      setState(() {
        DummyData.events.add(created);
        _day = created.date;
        _week = false;
      });
      showSnack(context, 'Added "${created.title}" to your timetable');
    }
  }

  Future<void> _deleteEvent(CalendarEvent e) async {
    final ok = await confirmAction(
      context,
      title: 'Delete event?',
      message: '"${e.title}" will be removed from your timetable.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok && mounted) {
      setState(() => DummyData.events.removeWhere((x) => x.id == e.id));
      showSnack(context, 'Event deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = DummyData.semesters.firstWhere((s) => s.isActive).name;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.faculty
          ? null
          : FloatingActionButton.extended(
              onPressed: _addEvent,
              icon: Icon(Icons.add_rounded),
              label: Text('Add event', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Row(children: [CircleBackButton(), Spacer()]),
            SizedBox(height: 14),
            AdminPageHeader(
              eyebrow: term,
              title: 'Timetable',
              actions: [_ViewToggle(week: _week, onChanged: (w) => setState(() => _week = w))],
            ),
            SizedBox(height: 18),
            WeekStrip(
              selected: _day,
              onSelect: (d) => setState(() {
                _day = d;
                _week = false;
              }),
            ),
            SizedBox(height: 22),
            if (_week) _WeekView(day: _day, faculty: widget.faculty) else ..._dayView(),
            SizedBox(height: 18),
            if (!widget.faculty) _ExamCard(),
          ],
        ),
      ),
    );
  }

  List<Widget> _dayView() {
    final classes = ScheduleService.classesOn(_day);
    final events = widget.faculty ? <CalendarEvent>[] : ScheduleService.eventsOn(_day);
    final now = DateTime.now();
    final isToday = _day.year == now.year && _day.month == now.month && _day.day == now.day;
    final slots = <(int, Widget)>[
      for (final c in classes)
        (ScheduleService.minutesOf(c.start), _ClassSlot(entry: c, status: ScheduleService.statusOf(c, _day, classes))),
      for (final e in events) (e.startMinutes, _EventSlot(event: e, onDelete: () => _deleteEvent(e))),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    return [
      SectionTitle(
        isToday ? "Today's Schedule" : formatLongDay(_day),
        trailing: Text(
          '${classes.length} class${classes.length == 1 ? '' : 'es'}',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      if (slots.isEmpty)
        SoftCard(
          child: EmptyState(
            icon: Icons.free_breakfast_outlined,
            title: 'No classes',
            message: widget.faculty ? 'No teaching on this day.' : 'A free day — add a study event to plan it.',
          ),
        ),
      for (final s in slots) Padding(padding: EdgeInsets.only(bottom: 14), child: s.$2),
    ];
  }
}

class _ViewToggle extends StatelessWidget {
  final bool week;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.week, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
        foregroundColor: AppColors.textSecondary,
        side: BorderSide(color: AppColors.border),
      ),
      segments: [
        ButtonSegment(value: false, label: Text('Day')),
        ButtonSegment(value: true, label: Text('Week')),
      ],
      selected: {week},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _ClassSlot extends StatelessWidget {
  final TimetableEntry entry;
  final SlotStatus status;

  const _ClassSlot({required this.entry, required this.status});

  @override
  Widget build(BuildContext context) {
    final course = DummyData.courseById(entry.courseId);
    final done = status == SlotStatus.done;
    final now = status == SlotStatus.now;
    final pill = switch (status) {
      SlotStatus.done => StatusPill(label: 'Done', foreground: AppColors.textMuted, background: AppColors.surfaceAlt),
      SlotStatus.now => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(gradient: AppColors.wineGradient, borderRadius: BorderRadius.circular(20)),
        child: Text(
          'Now',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      ),
      SlotStatus.next => StatusPill(label: 'Next', foreground: AppColors.sandDeep, background: AppColors.mintSoft),
      SlotStatus.later => StatusPill(
        label: entry.type,
        foreground: AppColors.textSecondary,
        background: AppColors.surfaceAlt,
      ),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Text(
                  entry.start.replaceAll(' AM', '').replaceAll(' PM', ''),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: now ? AppColors.primary : AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                Text(
                  entry.start.endsWith('PM') ? 'PM' : 'AM',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                SizedBox(height: 6),
                Expanded(
                  child: Container(width: 2, color: now ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border),
                ),
              ],
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: done ? 0.6 : 1,
              child: Container(
                decoration: BoxDecoration(
                  color: done ? AppColors.surfaceAlt : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: now ? Border(left: BorderSide(color: AppColors.primary, width: 4)) : null,
                  boxShadow: done ? null : AppColors.softShadow,
                ),
                padding: EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course?.title ?? entry.courseId,
                            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(width: 8),
                        pill,
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${entry.room} · ${course?.facultyName ?? ''}',
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${entry.start} – ${entry.end} · ${entry.type}',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventSlot extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onDelete;

  const _EventSlot({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            ScheduleService.formatMinutes(event.startMinutes).replaceAll(' ', '\n'),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.sand, fontSize: 13),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 14, 6, 14),
            decoration: BoxDecoration(
              color: AppColors.sandSoft,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.sand.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note_rounded, color: AppColors.sandDeep),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${ScheduleService.formatMinutes(event.startMinutes)} – ${ScheduleService.formatMinutes(event.endMinutes)}'
                        '${event.note.isEmpty ? '' : ' · ${event.note}'}',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete event',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  final DateTime day;
  final bool faculty;

  const _WeekView({required this.day, required this.faculty});

  @override
  Widget build(BuildContext context) {
    final monday = DateTime(day.year, day.month, day.day).subtract(Duration(days: day.weekday - 1));
    return Column(
      children: [
        for (var i = 0; i < 7; i++)
          Builder(
            builder: (_) {
              final d = monday.add(Duration(days: i));
              final classes = ScheduleService.classesOn(d);
              final events = faculty ? <CalendarEvent>[] : ScheduleService.eventsOn(d);
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        child: Column(
                          children: [
                            Text(
                              ScheduleService.dayKey(d).toUpperCase(),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            Text(
                              '${d.day}',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: classes.isEmpty && events.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text('Free day', style: TextStyle(color: AppColors.textMuted)),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final c in classes)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 3),
                                      child: Text(
                                        '${c.start}  ${DummyData.courseById(c.courseId)?.code ?? ''} · ${c.type} · ${c.room}',
                                        style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  for (final e in events)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 3),
                                      child: Text(
                                        '${ScheduleService.formatMinutes(e.startMinutes)}  ${e.title}',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          color: AppColors.sandDeep,
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
              );
            },
          ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final exam = AcademicService.upcomingExams.firstOrNull;
    if (exam == null) return SizedBox.shrink();
    return SoftCard(
      color: AppColors.surfaceAlt,
      outlined: true,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamPlannerScreen())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: EyebrowLabel('Upcoming exam', color: AppColors.textPrimary)),
              StatusPill(
                label: '${AcademicService.countdown(exam.date)} left',
                foreground: AppColors.primary,
                background: AppColors.primarySoft,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              GradientIconTile(icon: Icons.calendar_month_outlined, size: 54),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${formatShortDate(exam.date)} · ${exam.venue} · ${exam.seat}',
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                'Prep',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- add event --

class _AddEventSheet extends StatefulWidget {
  final DateTime initialDay;

  const _AddEventSheet({required this.initialDay});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  late DateTime _date = DateTime(widget.initialDay.year, widget.initialDay.month, widget.initialDay.day);
  TimeOfDay _start = TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _end = TimeOfDay(hour: 17, minute: 0);
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  int _m(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(Duration(days: 180)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime(bool start) async {
    final t = await showTimePicker(context: context, initialTime: start ? _start : _end);
    if (t != null) setState(() => start ? _start = t : _end = t);
  }

  void _save() {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (_m(_end) <= _m(_start)) {
      setState(() => _error = 'End time must be after the start time.');
      return;
    }
    final clash = ScheduleService.clashFor(_date, _m(_start), _m(_end));
    if (clash != null) {
      setState(() => _error = 'This overlaps with $clash. Pick another time.');
      return;
    }
    Navigator.pop(
      context,
      CalendarEvent(
        id: 'ev${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim(),
        date: _date,
        startMinutes: _m(_start),
        endMinutes: _m(_end),
        note: _note.text.trim(),
        ownerId: MyData.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, MediaQuery.of(context).viewInsets.bottom + 22),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add study event',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: 'Title', hintText: 'e.g. Revise BST traversals'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Give the event a title' : null,
              ),
              SizedBox(height: 12),
              _PickerTile(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: formatLongDay(_date),
                onTap: _pickDate,
              ),
              Row(
                children: [
                  Expanded(
                    child: _PickerTile(
                      icon: Icons.schedule_rounded,
                      label: 'Start',
                      value: _start.format(context),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _PickerTile(
                      icon: Icons.schedule_rounded,
                      label: 'End',
                      value: _end.format(context),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _note,
                decoration: InputDecoration(labelText: 'Location / note (optional)'),
              ),
              if (_error != null) ...[
                SizedBox(height: 12),
                InfoBanner(tone: BannerTone.danger, icon: Icons.error_outline_rounded, text: _error!),
              ],
              SizedBox(height: 18),
              GradientButton(label: 'Save Event', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                SizedBox(width: 10),
                Text('$label: ', style: TextStyle(color: AppColors.textSecondary)),
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
