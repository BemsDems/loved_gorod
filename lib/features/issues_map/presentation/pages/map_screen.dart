import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loved_gorod/components/app_snackbars.dart';
import 'components/creation_preview_card.dart';
import 'components/issue_preview_card.dart';

import '../../../../data/geocoding_repository.dart';
import '../../domain/entities/issue_entity.dart';
import '../bloc/issues_bloc.dart';
import 'create_issue_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _initialPosition = const LatLng(43.4853, 43.6070);
  final MapController _mapController = MapController();

  IssueEntity? _selectedIssue;
  LatLng? _creationPoint;
  String _creationAddress = "";
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  void _showIssuePreview(IssueEntity issue) {
    setState(() {
      _creationPoint = null;
      _selectedIssue = issue;
    });
    _mapController.move(
      LatLng(issue.latitude, issue.longitude),
      _mapController.camera.zoom,
    );
  }

  Future<void> _selectCreationPoint(LatLng point) async {
    setState(() {
      _selectedIssue = null;
      _creationPoint = point;
      _isLoadingAddress = true;
      _creationAddress = "Загрузка адреса...";
    });

    try {
      final address = await GeocodingRepository.getAddress(point);
      if (mounted && _creationPoint == point) {
        setState(() {
          _creationAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  void _closeAll() {
    if (_selectedIssue != null || _creationPoint != null) {
      setState(() {
        _selectedIssue = null;
        _creationPoint = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<IssuesBloc, IssuesState>(
      listenWhen: (previous, current) =>
          previous.createStatus != current.createStatus,
      listener: (context, state) {
        if (state.createStatus == IssuesCreateStatus.success) {
          AppSnackbars.showSuccess(
            context,
            'Обращение успешно создано!',
          );
          context.read<IssuesBloc>().add(const IssuesResetCreateStatus());
        }
      },
      child: BlocBuilder<IssuesBloc, IssuesState>(
        builder: (context, state) {
          List<Marker> issueMarkers = [];

          if (state.status == IssuesStatus.success) {
            issueMarkers = state.issues.map((issue) {
              final isResolved = issue.status == IssueStatus.resolved;
              final isSelected = _selectedIssue?.id == issue.id;

              return Marker(
                point: LatLng(issue.latitude, issue.longitude),
                width: 140,
                height: 90,
                child: GestureDetector(
                  onTap: () => _showIssuePreview(issue),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                isResolved
                                    ? Colors.green.shade100
                                    : colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected ? colorScheme.primary : Colors.white,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color:
                                isResolved
                                    ? Colors.green.shade700
                                    : colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                issue.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          }

      final creationMarkers =
          _creationPoint != null
              ? [
                Marker(
                  point: _creationPoint!,
                  width: 50,
                  height: 50,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(blurRadius: 10, color: Colors.black26),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
              : <Marker>[];

      return ScaffoldMessenger(
        child: Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialPosition,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (_, __) => _closeAll(),
                  onLongPress:
                      (tapPosition, point) => _selectCreationPoint(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.belovedcity.app',
                  ),
                  MarkerLayer(markers: issueMarkers),
                  MarkerLayer(markers: creationMarkers),
                  CurrentLocationLayer(
                    style: LocationMarkerStyle(
                      marker: Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade700,
                            size: 40,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Text(
                              "Я",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      markerSize: const Size(60, 60),
                      showAccuracyCircle: false,
                    ),
                    alignPositionOnUpdate: AlignOnUpdate.never,
                  ),
                ],
              ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Любимый город',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom:
                    (_selectedIssue != null || _creationPoint != null)
                        ? 24
                        : -350,
                left: 16,
                right: 16,
                child: _buildBottomContent(context),
              ),
            ],
          ),
          floatingActionButton:
              (_selectedIssue == null && _creationPoint == null)
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton.small(
                            heroTag: "locate",
                            backgroundColor: Colors.white,
                            elevation: 2,
                            onPressed: () async {
                              final pos = await Geolocator.getCurrentPosition();
                              _mapController.move(
                                LatLng(pos.latitude, pos.longitude),
                                16,
                              );
                            },
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FloatingActionButton.extended(
                            heroTag: "add",
                            elevation: 4,
                            backgroundColor: Colors.white,
                            icon: Icon(
                              Icons.add_location_alt_rounded,
                              color: colorScheme.primary,
                            ),
                            label: const Text(
                              "Сообщить",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateIssueScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomContent(BuildContext context) {
    if (_selectedIssue != null) {
      return IssuePreviewCard(issue: _selectedIssue!);
    } else if (_creationPoint != null) {
      return CreationPreviewCard(
        point: _creationPoint!,
        address: _creationAddress,
        isLoading: _isLoadingAddress,
        onClose: _closeAll,
      );
    }
    return const SizedBox.shrink();
  }
}
