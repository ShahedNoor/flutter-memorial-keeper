import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../imports/core_imports.dart';
import '../../domain/entities/memorial.dart';
import '../providers/memorial_bloc.dart';
import '../widgets/delete_memorial_sheet.dart';
import '../widgets/memorial_share_card.dart';
import '../widgets/profile/profile.dart';
import '../widgets/share_privacy_sheet.dart';

/// Modern Facebook-style profile view for a departed loved one.
class MemorialProfileScreen extends StatefulWidget {
  const MemorialProfileScreen({
    super.key,
    required this.memorial,
  });

  final Memorial memorial;

  @override
  State<MemorialProfileScreen> createState() => _MemorialProfileScreenState();
}

class _MemorialProfileScreenState extends State<MemorialProfileScreen> {
  final GlobalKey _shareCardKey = GlobalKey();
  bool _isSharing = false;
  SharePrivacyOptions _sharePrivacyOptions = const SharePrivacyOptions();

  void _openSharePrivacySheet(Memorial memorial) {
    HapticFeedback.lightImpact();
    showSharePrivacySheet(
      context: context,
      memorial: memorial,
      onShareConfirmed: (options) => _shareTributeImage(memorial, options),
    );
  }

  Future<void> _shareTributeImage(
    Memorial memorial,
    SharePrivacyOptions options,
  ) async {
    if (_isSharing) return;
    setState(() {
      _sharePrivacyOptions = options;
      _isSharing = true;
    });
    HapticFeedback.mediumImpact();

    try {
      // Allow off-screen widget to repaint with updated privacy options
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final boundary = _shareCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        showGlobalToast(
          message: 'Failed to generate tribute image',
          status: 'error',
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        showGlobalToast(
          message: 'Failed to encode tribute image',
          status: 'error',
        );
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final cleanName = memorial.fullName
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');
      final filePath = '${tempDir.path}/tribute_$cleanName.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? (box.localToGlobal(Offset.zero) & box.size)
          : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Remembering ${memorial.fullName} • Preserved on Memorial Keeper',
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to share memorial tribute',
          error: e, category: LogCategory.app);
      showGlobalToast(
        message: 'Could not share tribute card',
        status: 'error',
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _onToggleFavorite(Memorial memorial) {
    HapticFeedback.lightImpact();
    context.read<MemorialBloc>().add(ToggleFavoriteEvent(memorial.id));
    showGlobalToast(
      message: memorial.isFavorite
          ? 'Removed from favorites'
          : 'Added to favorites',
      status: 'info',
    );
  }

  Future<void> _onDeleteMemorial(Memorial memorial) async {
    final confirmed = await showDeleteMemorialSheet(
      context,
      fullName: memorial.fullName,
    );

    if (confirmed && mounted) {
      context.read<MemorialBloc>().add(DeleteMemorialEvent(memorial.id));
      showGlobalToast(
        message: 'Deleted record for ${memorial.fullName}',
        status: 'info',
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemorialBloc, MemorialState>(
      builder: (context, state) {
        final memorial = state.memorials.firstWhere(
          (m) => m.id == widget.memorial.id,
          orElse: () => widget.memorial,
        );

        final birthStr = memorial.dateOfBirth != null
            ? formatMemorialDate(memorial.dateOfBirth)
            : (memorial.birthYear != null ? '${memorial.birthYear}' : null);

        final passStr = memorial.dateOfDeath != null
            ? formatMemorialDate(memorial.dateOfDeath)
            : (memorial.passingYear != null ? '${memorial.passingYear}' : null);

        final timePassed =
            formatTimeSincePassing(memorial.dateOfDeath, memorial.passingYear);

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. Facebook-Style Profile Header (Cover, Centered Avatar, Details & Actions)
                  SliverToBoxAdapter(
                    child: MemorialProfileHeader(
                      memorial: memorial,
                      birthStr: birthStr,
                      passStr: passStr,
                      timePassed: timePassed,
                      isSharing: _isSharing,
                      onShare: () => _openSharePrivacySheet(memorial),
                      onToggleFavorite: () => _onToggleFavorite(memorial),
                      onDelete: () => _onDeleteMemorial(memorial),
                    ),
                  ),

                  // 2. Profile Content Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 40.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resting Place & Satellite Map
                          MemorialRestingPlaceCard(memorial: memorial),
                          SizedBox(height: 14.h),

                          // Dua & Remembrance Card
                          MemorialDuaNotesCard(memorial: memorial),
                          SizedBox(height: 14.h),

                          // Memory Photos Gallery (hidden when no distinct photos)
                          MemorialPhotoGalleryCard(memorial: memorial),

                          // Personal Record Details
                          MemorialRecordDetailsCard(
                            memorial: memorial,
                            birthStr: birthStr,
                            passStr: passStr,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Hidden Off-Screen Tribute Card for PNG image capture
              Transform.translate(
                offset: const Offset(-9999, -9999),
                child: RepaintBoundary(
                  key: _shareCardKey,
                  child: MemorialShareCard(
                    memorial: memorial,
                    privacyOptions: _sharePrivacyOptions,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
