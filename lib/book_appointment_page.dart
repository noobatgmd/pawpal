import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_ca3/appointment_confirmation_page.dart';
import 'package:intl/intl.dart';
import 'package:mad_ca3/home.dart';

class BookAppointmentPage extends StatefulWidget {
  final Map<String, dynamic>? vetData;
  final Map<String, dynamic>? groomData;

  BookAppointmentPage({this.vetData, this.groomData});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  Future<void> _saveAppointmentToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please log in to book appointments")),
        );
        return;
      }

      final name = bookingData['name'] ?? 'Unknown';

      // Create appointment data with consistent format
      Map<String, dynamic> appointmentData = {
        'timestamp': FieldValue.serverTimestamp(),
        'appointmentDate': selectedDate
            .toIso8601String(), // Store the selected date
        'appointmentDateFormatted': DateFormat(
          'yyyy-MM-dd',
        ).format(selectedDate), // Store formatted date for easier reading
      };

      // Add vet or groom specific data
      if (widget.vetData != null) {
        appointmentData['vetName'] = name;
        appointmentData['vetTime'] =
            '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
      } else {
        appointmentData['groomName'] = name;
        appointmentData['groomTime'] =
            '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
      }

      print("Saving appointment to Firebase: $appointmentData");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .add(appointmentData);

      print("Appointment saved successfully");
    } catch (e) {
      print("Error saving appointment: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save appointment: $e")));
    }
  }

  TimeOfDay? selectedTime;
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic> get bookingData => widget.vetData ?? widget.groomData!;

  List<TimeOfDay> _getAvailableTimes() {
    bool is24H =
        (bookingData['open']?.toString().trim().toUpperCase() == '24H') &&
        (bookingData['close']?.toString().trim().toUpperCase() == '24H');

    List<TimeOfDay> slots = [];

    if (is24H) {
      for (int hour = 0; hour < 24; hour++) {
        slots.add(TimeOfDay(hour: hour, minute: 0));
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    } else {
      String? open = bookingData['open'];
      String? close = bookingData['close'];

      if (open == null || close == null) return [];

      int openHour = int.tryParse(open.split(':')[0]) ?? 9;
      int openMinute = int.tryParse(open.split(':')[1]) ?? 0;
      int closeHour = int.tryParse(close.split(':')[0]) ?? 17;
      int closeMinute = int.tryParse(close.split(':')[1]) ?? 0;

      final start = Duration(hours: openHour, minutes: openMinute);
      final end = Duration(hours: closeHour, minutes: closeMinute);

      for (var time = start; time < end; time += const Duration(minutes: 30)) {
        slots.add(
          TimeOfDay(hour: time.inHours, minute: time.inMinutes.remainder(60)),
        );
      }
    }

    return slots;
  }

  bool _isPastSlot(TimeOfDay slot) {
    final now = DateTime.now();
    final slotDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      slot.hour,
      slot.minute,
    );
    return slotDateTime.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    List<TimeOfDay> availableTimes = _getAvailableTimes();

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${bookingData['name'] ?? 'Vet'}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select a Date:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                        onDateChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select a Time:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (availableTimes.isEmpty)
                          Text(
                            'No available slots.',
                            style: TextStyle(color: Colors.red),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableTimes.map((time) {
                            final isSelected = selectedTime == time;
                            final isPast = _isPastSlot(time);

                            final formattedTime =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                            return ChoiceChip(
                              label: Text(formattedTime),
                              selected: isSelected,
                              shape: StadiumBorder(),
                              selectedColor: Colors.teal.shade300,
                              backgroundColor: isPast
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: isPast
                                    ? Colors.grey
                                    : isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onSelected: isPast
                                  ? null
                                  : (_) {
                                      setState(() {
                                        selectedTime = time;
                                      });
                                    },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AbsorbPointer(
                absorbing: selectedTime == null,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                    backgroundColor: selectedTime == null
                        ? Colors.grey
                        : Colors.teal,
                    foregroundColor: selectedTime == null
                        ? Colors.black54
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedTime == null
                      ? null
                      : () async {
                          await _saveAppointmentToFirebase();

                          lastBookedAppointment = AppointmentData(
                            vetTime: widget.vetData != null
                                ? selectedTime!
                                : null,
                            groomTime: widget.groomData != null
                                ? selectedTime!
                                : null,
                            vetName: widget.vetData != null
                                ? bookingData['name']
                                : null,
                            groomName: widget.groomData != null
                                ? bookingData['name']
                                : null,
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppointmentConfirmationPage(
                                vetTime: widget.vetData != null
                                    ? selectedTime
                                    : null,
                                groomTime: widget.groomData != null
                                    ? selectedTime
                                    : null,
                                vetName: widget.vetData != null
                                    ? bookingData['name']
                                    : null,
                                groomName: widget.groomData != null
                                    ? bookingData['name']
                                    : null,
                                appointmentDate:
                                    selectedDate, // Pass the selected date
                                shouldSave:
                                    false, // Don't save again since we already saved above
                              ),
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Appointment Booked')),
                          );
                        },

                  child: Text(
                    selectedTime == null
                        ? 'Select a Time to Continue'
                        : 'Confirm Appointment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
