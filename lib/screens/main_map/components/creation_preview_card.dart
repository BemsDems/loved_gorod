import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:loved_gorod/components/app_snackbars.dart';
import 'package:loved_gorod/screens/create_issue_screen.dart';

class CreationPreviewCard extends StatelessWidget {
  final LatLng point;
  final String address;
  final bool isLoading;
  final VoidCallback onClose;

  const CreationPreviewCard({
    super.key,
    required this.point,
    required this.address,
    required this.isLoading,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_location_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Новое обращение",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    isLoading
                        ? const LinearProgressIndicator(minHeight: 2)
                        : Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed:
                  !isLoading
                      ? () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CreateIssueScreen(
                                  selectedLocation: point,
                                  initialAddress: address,
                                ),
                          ),
                        );

                        if (result == true && context.mounted) {
                          AppSnackbars.showSuccess(
                            context,
                            'Обращение успешно создано!',
                          );
                        }
                        onClose();
                      }
                      : null,
              icon: const Icon(Icons.check),
              label: const Text("Создать локацию здесь"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
