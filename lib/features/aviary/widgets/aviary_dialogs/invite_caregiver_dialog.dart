// lib/features/aviary/widgets/aviary_dialogs/invite_caregiver_dialog.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

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
    // We construct the title text using our generic constants.
    final titleText = '${ButtonLabels.invite} a ${AppStrings.secondaryUser}';

    return AlertDialog(
      title: Text(titleText),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: Labels.secondaryUserEmail,
              ),
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return AppStrings.emailValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: Labels.theirLabel,
                hintText: AppStrings.secondaryUserLabelHint,
              ),
              validator: (value) => value!.isEmpty ? AppStrings.labelValidation : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(ButtonLabels.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text(ButtonLabels.sendInvite),
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