import 'package:flutter/material.dart';
import '../models/learning_activity.dart';
import '../state/app_state.dart';

Future<void> showActivityHistory(BuildContext context, AppState state) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .9,
        child: ActivityHistorySheet(state: state),
      ),
    );

class ActivityHistorySheet extends StatefulWidget {
  const ActivityHistorySheet({super.key, required this.state});
  final AppState state;
  @override
  State<ActivityHistorySheet> createState() => _ActivityHistorySheetState();
}

class _ActivityHistorySheetState extends State<ActivityHistorySheet> {
  DateTime selected = activityDay(DateTime.now());
  int period = 2;
  List<DateTime> get days {
    final first = period == 0
        ? selected
        : period == 1
        ? selected.subtract(Duration(days: selected.weekday - 1))
        : DateTime(selected.year, selected.month);
    final count = period == 0
        ? 1
        : period == 1
        ? 7
        : DateTime(selected.year, selected.month + 1, 0).day;
    return List.generate(count, (i) => first.add(Duration(days: i)));
  }

  void move(int direction) => setState(() {
    selected = period == 2
        ? DateTime(selected.year, selected.month + direction)
        : selected.add(Duration(days: direction * (period == 1 ? 7 : 1)));
    final today = activityDay(DateTime.now());
    if (selected.isAfter(today)) selected = today;
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.state,
    builder: (context, _) {
      final theme = Theme.of(context);
      final history = widget.state.activities;
      final range = days;
      final periodEvents = history
          .where(
            (event) =>
                !event.day.isBefore(range.first) &&
                !event.day.isAfter(range.last),
          )
          .toList();
      final daily = history.where((event) => event.day == selected).toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(
              'Jejak belajarmu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.state.streakDays} hari streak · Setiap sesi punya cerita.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('Hari')),
                ButtonSegment(value: 1, label: Text('Minggu')),
                ButtonSegment(value: 2, label: Text('Bulan')),
              ],
              selected: {period},
              onSelectionChanged: (value) =>
                  setState(() => period = value.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  tooltip: 'Periode sebelumnya',
                  onPressed: () => move(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    period == 2
                        ? '${_months[selected.month - 1]} ${selected.year}'
                        : period == 1
                        ? '${_date(range.first)} – ${_date(range.last)}'
                        : _date(selected),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Periode berikutnya',
                  onPressed: range.last.isBefore(activityDay(DateTime.now()))
                      ? () => move(1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            ActivityCalendar(
              days: range,
              selected: selected,
              history: history,
              onSelected: (day) => setState(() => selected = day),
            ),
            const SizedBox(height: 12),
            Text(
              '${periodEvents.length} sesi · ${periodEvents.fold<int>(0, (sum, event) => sum + event.xp)} XP dalam periode ini',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              _date(selected),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (daily.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada sesi tercatat pada hari ini.\nRiwayat mulai dicatat sejak fitur ini tersedia.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ...daily.map((event) => ActivitySessionTile(activity: event)),
            const SizedBox(height: 12),
            Text(
              'Tanggal dan jam menggunakan WIB. Ketuk kotak untuk melihat rincian. Semakin pekat, semakin banyak sesi.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    },
  );
}

const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];
String _date(DateTime day) =>
    '${day.day} ${_months[day.month - 1]} ${day.year}';

class ActivityCalendar extends StatelessWidget {
  const ActivityCalendar({
    super.key,
    required this.days,
    required this.selected,
    required this.history,
    required this.onSelected,
  });
  final List<DateTime> days;
  final DateTime selected;
  final List<LearningActivity> history;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final counts = <DateTime, int>{};
    for (final event in history) {
      counts.update(event.day, (value) => value + 1, ifAbsent: () => 1);
    }
    final offset = days.length == 1 ? 0 : days.first.weekday - 1;
    return Column(
      children: [
        if (days.length > 1)
          Row(
            children: ['S', 'S', 'R', 'K', 'J', 'S', 'M']
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offset + days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: days.length == 1 ? 1 : 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            mainAxisExtent: 42,
          ),
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox.shrink();
            final day = days[index - offset];
            final count = counts[day] ?? 0;
            final future = day.isAfter(activityDay(DateTime.now()));
            final fill = count == 0
                ? colors.surfaceContainerHighest
                : Color.lerp(
                    colors.primaryContainer,
                    colors.primary,
                    (count / 4).clamp(0, 1),
                  )!;
            return Semantics(
              label: '${_date(day)}, $count sesi',
              selected: day == selected,
              child: Material(
                color: future ? fill.withValues(alpha: .25) : fill,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: future ? null : () => onSelected(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: day == selected ? colors.onSurface : fill,
                        width: day == selected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: count >= 3 ? colors.onPrimary : colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ActivitySessionTile extends StatelessWidget {
  const ActivitySessionTile({super.key, required this.activity});
  final LearningActivity activity;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = activity.occurredAt.toUtc().add(const Duration(hours: 7));
    final clock =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Icon(
          activity.success ? Icons.task_alt_rounded : Icons.refresh_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          '${activity.practice ? 'Practice' : 'Learn'} · Level ${activity.level}',
        ),
        subtitle: Text(
          '$clock WIB · ${activity.correct}/${activity.questions} benar\n${activity.success ? 'Selesai' : 'Belum berhasil'}',
        ),
        trailing: Text('+${activity.xp} XP', style: theme.textTheme.labelLarge),
      ),
    );
  }
}
