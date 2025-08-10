import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentConfirmationPage extends StatefulWidget {
  final TimeOfDay? vetTime;
  final TimeOfDay? groomTime;
  final String? vetName;
  final String? groomName;
  final DateTime? appointmentDate; // Add date parameter
  final bool shouldSave; // Add this parameter to control saving

  AppointmentConfirmationPage({
    this.vetTime,
    this.groomTime,
    this.vetName,
    this.groomName,
    this.appointmentDate,
    this.shouldSave = false, // Default to false to prevent duplicate saves
  });

  @override
  _AppointmentConfirmationPageState createState() =>
      _AppointmentConfirmationPageState();
}

class _AppointmentConfirmationPageState
    extends State<AppointmentConfirmationPage> {
  bool _isSaving = false;
  String _saveStatus = '';
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Only save if explicitly requested (for direct navigation scenarios)
    if (widget.shouldSave) {
      _handleNewAppointment();
    }
    _loadAllAppointments();
  }

  Future<void> _handleNewAppointment() async {
    // Only save if we have new appointment data from booking
    if ((widget.vetName != null && widget.vetTime != null) ||
        (widget.groomName != null && widget.groomTime != null)) {
      await _saveAppointmentData();
    }
  }

  Future<void> _saveAppointmentData() async {
    setState(() {
      _isSaving = true;
      _saveStatus = 'Saving appointment...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isSaving = false;
          _saveStatus = 'Error: You must be logged in to save appointments.';
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // Create a consistent data structure
      Map<String, dynamic> dataToSave = {
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Add appointment date if provided
      if (widget.appointmentDate != null) {
        dataToSave['appointmentDate'] = widget.appointmentDate!
            .toIso8601String();
        dataToSave['appointmentDateFormatted'] = DateFormat(
          'yyyy-MM-dd',
        ).format(widget.appointmentDate!);
      }

      // Add vet data if exists
      if (widget.vetName != null && widget.vetTime != null) {
        dataToSave['vetName'] = widget.vetName;
        dataToSave['vetTime'] = _formatTimeForStorage(widget.vetTime!);
        dataToSave['type'] = 'vet';
      }

      // Add groom data if exists
      if (widget.groomName != null && widget.groomTime != null) {
        dataToSave['groomName'] = widget.groomName;
        dataToSave['groomTime'] = _formatTimeForStorage(widget.groomTime!);
        dataToSave['type'] = 'groom';
      }

      print("Saving appointment data: $dataToSave");

      // Save under user's appointments subcollection
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .add(dataToSave);

      setState(() {
        _isSaving = false;
        _saveStatus = 'Appointment saved successfully!';
      });

      // Reload appointments after saving
      await _loadAllAppointments();
    } catch (e) {
      print("Error saving appointment: $e");
      setState(() {
        _isSaving = false;
        _saveStatus = 'Failed to save appointment: $e';
      });
    }
  }

  Future<void> _loadAllAppointments() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> loadedAppointments = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id; // Add document ID for deletion
        loadedAppointments.add(data);
      }

      setState(() {
        appointments = loadedAppointments;
        _isLoading = false;
      });

      print("Loaded ${appointments.length} appointments");
    } catch (e) {
      print("Error loading appointments: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAppointment(
    String appointmentId,
    String appointmentType,
  ) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel your booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Delete from Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('appointments')
            .doc(appointmentId)
            .delete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload appointments
        await _loadAllAppointments();
      } catch (e) {
        print("Error deleting appointment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Format time consistently for storage (24-hour format)
  String _formatTimeForStorage(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      print("Error parsing time string '$timeStr': $e");
    }
    return null;
  }

  DateTime? _parseAppointmentDate(Map<String, dynamic> appointment) {
    // Try to parse from appointmentDate field first
    if (appointment['appointmentDate'] != null) {
      try {
        return DateTime.parse(appointment['appointmentDate']);
      } catch (e) {
        print("Error parsing appointmentDate: $e");
      }
    }

    // Try to parse from appointmentDateFormatted field
    if (appointment['appointmentDateFormatted'] != null) {
      try {
        return DateTime.parse(appointment['appointmentDateFormatted']);
      } catch (e) {
        print("Error parsing appointmentDateFormatted: $e");
      }
    }

    return null;
  }

  String _formatAppointmentDate(DateTime? date) {
    if (date == null) return 'Date not specified';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final appointmentDate = DateTime(date.year, date.month, date.day);

    if (appointmentDate == today) {
      return 'Today, ${DateFormat('MMM dd, yyyy').format(date)}';
    } else if (appointmentDate == tomorrow) {
      return 'Tomorrow, ${DateFormat('MMM dd, yyyy').format(date)}';
    } else {
      return DateFormat('EEEE, MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'My Appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show save status if we just saved a new appointment
            if (_isSaving || _saveStatus.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _isSaving
                      ? Colors.orange.shade100
                      : _saveStatus.contains('Error')
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (_isSaving)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (!_isSaving)
                      Icon(
                        _saveStatus.contains('Error')
                            ? Icons.error
                            : Icons.check_circle,
                        color: _saveStatus.contains('Error')
                            ? Colors.red
                            : Colors.green,
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _saveStatus,
                        style: TextStyle(
                          color: _isSaving
                              ? Colors.orange.shade800
                              : _saveStatus.contains('Error')
                              ? Colors.red.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Show loading or appointments list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading appointments...'),
                        ],
                      ),
                    )
                  : appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No appointments found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Book an appointment to see it here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return _buildAppointmentCard(appointment, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, int index) {
    final isVet = appointment['vetName'] != null;
    final name = appointment[isVet ? 'vetName' : 'groomName'] ?? 'Unknown';
    final timeStr = appointment[isVet ? 'vetTime' : 'groomTime'] ?? '';
    final timeOfDay = _parseTimeString(timeStr);
    final formattedTime = timeOfDay?.format(context) ?? timeStr;
    final appointmentDate = _parseAppointmentDate(appointment);
    final formattedDate = _formatAppointmentDate(appointmentDate);

    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: isVet ? Colors.teal.shade200 : Colors.orange.shade200,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isVet ? Icons.local_hospital : Icons.content_cut,
                  size: 48,
                  color: isVet ? Colors.teal : Colors.orange,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVet ? 'Vet Appointment' : 'Groom Appointment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isVet
                              ? Colors.teal.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(isVet ? 'Vet Name:' : 'Groomer:', name),
                      SizedBox(height: 4),
                      _buildDetailRow('Date:', formattedDate),
                      SizedBox(height: 4),
                      _buildDetailRow('Time:', formattedTime),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteAppointment(
                    appointment['id'],
                    isVet ? 'vet' : 'groom',
                  ),
                  icon: Icon(Icons.delete_outline),
                  color: Colors.red,
                  iconSize: 28,
                  tooltip: 'Cancel Booking',
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isVet ? Colors.teal.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your appointment has been confirmed!',
                style: TextStyle(
                  color: isVet ? Colors.teal.shade900 : Colors.orange.shade900,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
