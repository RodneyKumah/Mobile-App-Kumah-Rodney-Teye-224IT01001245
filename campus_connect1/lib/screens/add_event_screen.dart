import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'dart:io';


class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}


class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _image;
  Position? _currentLocation;


  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context, listen: false);
    final userId = Provider.of<AuthViewModel>(context, listen: false).user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            _SectionLabel(label: 'Event Details'),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                prefixIcon: Icon(Icons.title, color: Color(0xFF1565C0)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined, color: Color(0xFF1565C0)),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Date picker
            _SectionLabel(label: 'Date'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1565C0)),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 15, color: Color(0xFF37474F)),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF1565C0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image section
            _SectionLabel(label: 'Image (Optional)'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) setState(() => _image = File(pickedFile.path));
              },
              child: Container(
                height: _image != null ? 160 : 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBDEFB), style: BorderStyle.solid),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Color(0xFF1565C0)),
                          SizedBox(width: 8),
                          Text('Tap to take a photo', style: TextStyle(color: Color(0xFF1565C0))),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Location section
            _SectionLabel(label: 'Location (Optional)'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                }
                if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
                  final position = await Geolocator.getCurrentPosition();
                  setState(() => _currentLocation = position);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _currentLocation != null ? const Color(0xFFE3F2FD) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentLocation != null ? Icons.location_on : Icons.my_location,
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentLocation == null
                            ? 'Tap to get current location'
                            : 'Lat: ${_currentLocation!.latitude.toStringAsFixed(4)}, Lng: ${_currentLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _currentLocation != null ? const Color(0xFF1565C0) : const Color(0xFF78909C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: () async {
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an event title'), backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                final newEvent = Event(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  date: _selectedDate,
                  imageUrl: _image?.path ?? '',
                  latitude: _currentLocation?.latitude,
                  longitude: _currentLocation?.longitude,
                  createdBy: userId,
                );
                await eventVm.addEvent(newEvent);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}


class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1565C0),
        letterSpacing: 0.5,
      ),
    );
  }
}
