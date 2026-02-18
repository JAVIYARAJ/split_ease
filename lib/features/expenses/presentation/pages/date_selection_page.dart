import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_bloc.dart';

import '../../../../injection_container.dart';

class DateSelectionPage extends StatelessWidget {
  const DateSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ExpenseBloc>(),
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final initialDate = state.date ?? DateTime.now();
          return _DateSelectionView(
            initialDate: initialDate,
          );
        },
      ),
    );
  }
}

class _DateSelectionView extends StatefulWidget {
  final DateTime initialDate;

  const _DateSelectionView({
    required this.initialDate,
  });

  @override
  State<_DateSelectionView> createState() => _DateSelectionViewState();
}

class _DateSelectionViewState extends State<_DateSelectionView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            color: AppColors.textBlack,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(DateChanged(_selectedDay));
              Navigator.pop(context);
            },
            child: Text(
              "Done",
              style: GoogleFonts.openSans(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            currentDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
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
              defaultTextStyle: GoogleFonts.openSans(color: AppColors.textBlack),
              weekendTextStyle: GoogleFonts.openSans(color: AppColors.textBlack),
            ),
          ),
           const Spacer(),
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("Repeat", style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textBlack)),
                 Row(
                   children: [
                     Text("Just this once", style: GoogleFonts.openSans(fontSize: 16, color: AppColors.textGrey)),
                     const Icon(Icons.chevron_right, color: AppColors.iconGrey),
                   ],
                 )
               ],
             ),
           ),
           const SizedBox(height: 20),
        ],
      ),
    );
  }
}
