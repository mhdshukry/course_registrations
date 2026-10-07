import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/localization.dart';
import '../../domain/models.dart';

class StatusPillBadge extends StatelessWidget {
  final RegistrationStatus status;

  const StatusPillBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (status) {
      RegistrationStatus.registered ||
      RegistrationStatus.locked ||
      RegistrationStatus.facultyApproved ||
      RegistrationStatus.departmentApproved ||
      RegistrationStatus.adviserApproved => (
        RuslColors.successGreen.withValues(alpha: 0.15),
        RuslColors.successGreen,
      ),
      RegistrationStatus.rejected => (
        RuslColors.errorRed.withValues(alpha: 0.12),
        RuslColors.errorRed,
      ),
      RegistrationStatus.changesRequested => (
        RuslColors.warningOrange.withValues(alpha: 0.15),
        RuslColors.warningOrange,
      ),
      RegistrationStatus.draft || RegistrationStatus.submitted => (
        RuslColors.accentYellow.withValues(alpha: 0.3),
        RuslColors.darkText,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class HeaderNavBar extends StatelessWidget {
  final UserRole currentRole;
  final ValueChanged<UserRole> onRoleChanged;
  final ValueChanged<String> onLanguageChanged;
  final String currentLanguage;
  final VoidCallback? onLogout;
  final String? userName;
  final String? userSubtitle;

  final int unreadNotifications;
  final VoidCallback? onNotificationTap;

  const HeaderNavBar({
    super.key,
    required this.currentRole,
    required this.onRoleChanged,
    required this.onLanguageChanged,
    required this.currentLanguage,
    this.onLogout,
    this.userName,
    this.userSubtitle,
    this.unreadNotifications = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 750;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 12,
      ),
      color: RuslColors.bgCream,
      child: Row(
        children: [
          // Logo & Brand Name
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: RuslColors.accentYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: RuslColors.darkText,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          if (!isCompact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RUSL Smart',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Rajarata University',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // Role Switcher Dropdown Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole>(
                value: currentRole,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: RuslColors.darkText,
                  size: 18,
                ),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  color: RuslColors.darkText,
                  fontSize: 12,
                ),
                onChanged: (role) {
                  if (role != null) onRoleChanged(role);
                },
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(isCompact ? role.shortLabel : role.displayName),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Language Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLanguage,
                isDense: true,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  color: RuslColors.darkText,
                  fontSize: 11,
                ),
                onChanged: (lang) {
                  if (lang != null) onLanguageChanged(lang);
                },
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(isCompact ? 'EN' : 'EN (Eng)'),
                  ),
                  DropdownMenuItem(
                    value: 'si',
                    child: Text(isCompact ? 'SI' : 'SI (සිං)'),
                  ),
                  DropdownMenuItem(
                    value: 'ta',
                    child: Text(isCompact ? 'TA' : 'TA (தமி)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Notification Bell with Red Badge
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: RuslColors.pureWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: RuslColors.borderGrey),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: RuslColors.darkText,
                  ),
                ),
                if (unreadNotifications > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: RuslColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // User Avatar Pill
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: RuslColors.pureWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: RuslColors.borderGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: RuslColors.accentYellow,
                  child: Text(
                    userName != null && userName!.isNotEmpty
                        ? userName!.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: RuslColors.darkText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName ?? 'User',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: RuslColors.darkText,
                        ),
                      ),
                      Text(
                        userSubtitle ?? 'RUSL Portal',
                        style: const TextStyle(
                          fontSize: 9,
                          color: RuslColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          if (onLogout != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: RuslColors.pureWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: RuslColors.borderGrey),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: RuslColors.errorRed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PillTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const PillTab({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? RuslColors.accentYellow : RuslColors.pureWhite,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? RuslColors.accentYellow : RuslColors.borderGrey,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: RuslColors.accentYellow.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: RuslColors.darkText,
          ),
        ),
      ),
    );
  }
}

class StatMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const StatMetricCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: RuslColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RuslColors.borderGrey.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: RuslColors.darkText,
                    height: 1.0,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 16),
                Icon(icon, color: RuslColors.accentYellow, size: 24),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: RuslColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCardItem extends StatelessWidget {
  final Course course;
  final CourseOffering offering;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool isWaiting;
  final int? waitingPosition;
  final bool isPromoted;
  final VoidCallback? onClaimPromoted;
  final VoidCallback? onLeaveWaiting;

  const CourseCardItem({
    super.key,
    required this.course,
    required this.offering,
    required this.isSelected,
    required this.onToggle,
    this.isWaiting = false,
    this.waitingPosition,
    this.isPromoted = false,
    this.onClaimPromoted,
    this.onLeaveWaiting,
  });

  @override
  Widget build(BuildContext context) {
    final double capacityProgress =
        (offering.currentRegisteredCount / offering.maxCapacity).clamp(
          0.0,
          1.0,
        );
    final isFull = offering.isFull;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected
            ? RuslColors.pureWhite
            : RuslColors.pureWhite.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPromoted
              ? RuslColors.successGreen
              : isSelected
              ? RuslColors.darkText
              : RuslColors.borderGrey.withValues(alpha: 0.6),
          width: isPromoted || isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Code badge & action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: course.courseType == CourseType.compulsory
                      ? RuslColors.accentYellow
                      : RuslColors.cardSubtle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${course.code} • ${course.creditValue} Credits',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: RuslColors.darkText,
                  ),
                ),
              ),

              // Action button depending on status
              if (isPromoted)
                ElevatedButton.icon(
                  onPressed: onClaimPromoted,
                  icon: const Icon(Icons.check_circle_rounded, size: 14),
                  label: Text(RuslLocalization.tr('claim_seat')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RuslColors.successGreen,
                    foregroundColor: RuslColors.pureWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isWaiting)
                InkWell(
                  onTap: onLeaveWaiting,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.warningOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: RuslColors.warningOrange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          size: 13,
                          color: RuslColors.warningOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Queue #$waitingPosition',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: RuslColors.warningOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isFull && !isSelected)
                InkWell(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: RuslColors.accentYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.queue_rounded,
                          size: 13,
                          color: RuslColors.darkText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          RuslLocalization.tr('join_waiting_list'),
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: RuslColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? RuslColors.darkText
                          : RuslColors.bgCream,
                      shape: BoxShape.circle,
                      border: Border.all(color: RuslColors.borderGrey),
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_rounded
                          : Icons.north_east_rounded,
                      size: 16,
                      color: isSelected
                          ? RuslColors.accentYellow
                          : RuslColors.darkText,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Course Title
          Text(
            course.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RuslColors.darkText,
            ),
          ),
          const SizedBox(height: 4),

          // Lecturer Name
          Text(
            offering.lecturerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              color: RuslColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Tags Row (Hours, Type, Level)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildSmallTag(
                '${offering.slots.firstOrNull?.dayOfWeek ?? "Mon"} ${offering.slots.firstOrNull?.startTime ?? "09:00"}',
              ),
              _buildSmallTag(course.courseType.nameLabel),
              _buildSmallTag(
                'Cap: ${offering.currentRegisteredCount}/${offering.maxCapacity}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar with Accent Yellow Fill
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    RuslLocalization.tr('seats_filled_label'),
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RuslColors.textMuted,
                    ),
                  ),
                  Text(
                    '${(capacityProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: RuslColors.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: capacityProgress,
                  minHeight: 8,
                  backgroundColor: RuslColors.cardSubtle,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    RuslColors.accentYellow,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: RuslColors.cardSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RuslColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: RuslColors.darkText,
        ),
      ),
    );
  }
}
