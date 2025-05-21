import 'package:flutter/material.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cancel", style: TextStyle(fontSize: 16)),
                    Text("New Event",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(width: 60), // Placeholder for alignment
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField("Title"),
                SizedBox(height: 10),
                _buildTextField("Location"),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Date", enabled: false, value: selectedDate != null ? "${selectedDate!.toLocal()}".split(' ')[0] : '')),
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.blue),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Time", enabled: false, value: selectedTime?.format(context) ?? '')),
                    IconButton(
                      icon: Icon(Icons.access_time, color: Colors.blue),
                      onPressed: () => _selectTime(context),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Category"),
                  value: selectedCategory,
                  items: [ 
                    'ASD',
                    'ADHD',
                    'Dyslexia',
                    'Dyscalculia',
                    'Dyspraxia',
                    'Tourette Syndrome',
                    'OCD',
                    'Bipolar',
                    'Anxiety',]
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildTextField("Description", maxLines: 4),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Add your submit logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Add Event",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(String label,
      {bool enabled = true, String value = '', int maxLines = 1}) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
    );
  }
}
