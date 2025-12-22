import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/widgets/dashboard/notification_overlay.dart';
import 'package:walkinsalonapp/screens/business/appointments_page.dart';
import 'package:walkinsalonapp/screens/business/reviews_page.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  late final String uid;
  List<Map<String, dynamic>> _notifications = [];
  String? _salonName;
  String? _profileImage;
  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    _listenToNotifications();
    _listenToBusinessData();
  }

  void _listenToBusinessData() {
    FirebaseFirestore.instance
        .collection('businesses')
        .doc(uid)
        .snapshots()
        .listen((doc) {
          final data = doc.data() ?? {};
          if (!mounted) return;
          setState(() {
            _salonName = data['salonName'] ?? 'Your Salon';
            _profileImage = data['profileImage'];
            _imageVersion = (data['imageVersion'] ?? 0) as int;
          });
        });
  }

  void _listenToNotifications() {
    // Appointments
    FirebaseFirestore.instance
        .collection('appointments')
        .where('businessId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snap) {
          final newAppointments = snap.docs.map((d) {
            final data = d.data();
            return {
              'type': 'Appointment',
              'title': data['customerName'] ?? 'New Appointment',
              'time': (data['createdAt'] as Timestamp?)?.toDate(),
              'meta': {'docId': d.id, 'raw': data},
            };
          }).toList();

          if (mounted) {
            setState(() {
              _notifications = [
                ...newAppointments,
                ..._notifications.where((n) => n['type'] != 'Appointment'),
              ];
            });
          }
        });

    // Reviews
    FirebaseFirestore.instance
        .collection('reviews')
        .where('businessId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snap) {
          final newReviews = snap.docs.map((d) {
            final data = d.data();
            return {
              'type': 'Review',
              'title': data['customerName'] ?? 'New Review',
              'rating': data['rating'] ?? 0,
              'time': (data['createdAt'] as Timestamp?)?.toDate(),
              'meta': {'docId': d.id, 'raw': data},
            };
          }).toList();

          if (mounted) {
            setState(() {
              _notifications = [
                ..._notifications.where((n) => n['type'] != 'Review'),
                ...newReviews,
              ];
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final iconKey = GlobalKey();
    OverlayEntry? overlayEntry;
    bool panelOpen = false;

    void closePanel() {
      overlayEntry?.remove();
      overlayEntry = null;
      panelOpen = false;
    }

    void togglePanel(GlobalKey iconKey) {
      if (panelOpen) {
        closePanel();
        return;
      }

      final overlay = Overlay.of(context);
      final renderBox =
          iconKey.currentContext?.findRenderObject() as RenderBox?;
      double top = kToolbarHeight + 12;
      double? left, right;

      if (renderBox != null) {
        final size = renderBox.size;
        final topLeft = renderBox.localToGlobal(Offset.zero);
        final screenWidth = MediaQuery.of(context).size.width;
        const panelWidth = 320.0;

        left = topLeft.dx;
        top = topLeft.dy + size.height + 8;

        if (left + panelWidth + 8 > screenWidth) {
          left = screenWidth - panelWidth - 12;
          if (left < 8) left = 8;
        }
      } else {
        right = 24;
      }

      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: closePanel,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: left,
              right: right,
              top: top,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppConstants.blurSigma * 1.5,
                    sigmaY: AppConstants.blurSigma * 1.5,
                  ),
                  child: NotificationOverlay(
                    notifications: _notifications,
                    markAllRead: () {
                      setState(() {
                        for (var n in _notifications) {
                          n['read'] = true;
                        }
                      });
                    },
                    onDismiss: (i) {
                      setState(() {
                        _notifications.removeAt(i);
                      });
                    },
                    onOpen: (n) {
                      setState(() => n['read'] = true);
                      closePanel();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => n['type'] == 'Review'
                              ? const ReviewsPage()
                              : const AppointmentsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      overlay.insert(overlayEntry!);
      panelOpen = true;
    }

    final bustedUrl = _profileImage != null && _profileImage!.isNotEmpty
        ? '$_profileImage${_profileImage!.contains('?') ? '&' : '?'}v=$_imageVersion'
        : null;

    return RepaintBoundary(
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppConstants.blurSigma,
              sigmaY: AppConstants.blurSigma,
            ),
            child: Container(
              color: AppConfig.adaptiveSurface(context).withValues(alpha: 0.07),
            ),
          ),
        ),
        title: Text(
          _salonName ?? 'Your Salon',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppConfig.adaptiveTextColor(context),
          ),
        ),
        iconTheme: IconThemeData(color: AppConfig.adaptiveTextColor(context)),
        actions: [
          Row(
            children: [
              GestureDetector(
                key: iconKey,
                onTap: () => togglePanel(iconKey),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: AppConfig.adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.8),
                      ),
                    ),
                    if (_notifications.any((n) => !(n['read'] ?? false)))
                      Positioned(
                        right: 2,
                        top: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppConfig.adaptiveSurface(context),
                  backgroundImage: bustedUrl != null
                      ? NetworkImage(bustedUrl)
                      : null,
                  onBackgroundImageError: bustedUrl != null ? (_, __) {} : null,
                  child: bustedUrl == null
                      ? Icon(
                          Icons.person,
                          color: AppConfig.adaptiveTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
