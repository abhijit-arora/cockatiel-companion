import 'package:flutter/material.dart';

typedef OnInviteCaregiver = void Function({
  required String email,
  required String label,
});

class InviteCaregiverDialog extends StatefulWidget {
  final OnInviteCaregiver onInvite;
  const InviteCaregiverDialog({super.key, required this.onInvite});

  @override
  State<InviteCaregiverDialog> createState() => _InviteCaregiverDialogState();
}

class _InviteCaregiverDialogState extends State<InviteCaregiverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _labelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite a Caregiver'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Caregiver\'s Email*',
              ),
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Please enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Their Label*',
                hintText: 'e.g., Mama Birdie, The Flock Master',
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a label.' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Send Invite'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onInvite(
                email: _emailController.text.trim(),
                label: _labelController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}