import 'package:flutter/material.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:split_ease/features/expenses/presentation/bloc/date/date_bloc.dart';

import '../../../../injection_container.dart';

class DateSelectionPage extends StatelessWidget {
  const DateSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final initialDate = args['initialDate'] as DateTime?;

    return BlocProvider(
      create: (context) => sl<DateBloc>()..add(InitializeDateEvent(initialDate: initialDate)),
      child: const _DateSelectionView(),
    );
  }
}

class _DateSelectionView extends StatefulWidget {
  const _DateSelectionView();

  @override
  State<_DateSelectionView> createState() => _DateSelectionViewState();
}

class _DateSelectionViewState extends State<_DateSelectionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).ext.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Theme.of(context).ext.scaffoldBg,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.openSans(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          "Choose date",
          style: GoogleFonts.openSans(
            color: Theme.of(context).ext.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<DateBloc, DateState>(
            builder: (context, state) {
              return TextButton(
                onPressed: () {
                  Navigator.pop(context, state.selectedDate);
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DateBloc, DateState>(
        builder: (context, state) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: state.focusedDay,
                currentDay: state.selectedDate,
                selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  context.read<DateBloc>().add(DateSelectedEvent(selectedDate: selectedDay, focusedDay: focusedDay));
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).ext.textPrimary,
                  ),
                ),
                rowHeight: 52,
                daysOfWeekHeight: 30, // Added for more vertical space
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: GoogleFonts.openSans(
                      color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                  defaultTextStyle: GoogleFonts.openSans(color: Theme.of(context).ext.textPrimary),
                  weekendTextStyle: GoogleFonts.openSans(color: Theme.of(context).ext.textPrimary),
                ),
              ),
               const Spacer(),
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text("Repeat", style: GoogleFonts.openSans(fontSize: 16, color: Theme.of(context).ext.textPrimary)),
                     Row(
                       children: [
                         Text("Just this once", style: GoogleFonts.openSans(fontSize: 16, color: Theme.of(context).ext.textSecondary)),
                         Icon(Icons.chevron_right, color: Theme.of(context).ext.textTertiary),
                       ],
                     )
                   ],
                 ),
               ),
               const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
