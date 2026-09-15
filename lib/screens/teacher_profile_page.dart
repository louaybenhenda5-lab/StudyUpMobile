import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/SessionViewModel.dart';
import '../providers/UserViewModel.dart';

/// Teacher profile with real `GET /api/auth/me` data.
///
/// Supported: display info, classes-taught count, logout (client token discard).
/// Missing in backend (shown disabled, never faked): profile-picture update,
/// username update, password update, server-side logout.
class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureStats());
  }

  Future<void> _ensureStats() async {
    final userVm = context.read<UserViewModel>();
    final sessionVm = context.read<SessionViewModel>();
    final token = userVm.token;
    if (token == null || token.isEmpty) return;
    if (sessionVm.mySessions.isEmpty && !sessionVm.isLoading) {
      await sessionVm.loadMySessions(token);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<UserViewModel>().logout();
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _unsupported(String missing) {
    debugPrint('[TeacherProfile] unsupported action: $missing');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('This functionality is missing from the backend: $missing.')),
    );
  }

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Birthday shown as Day / Month / Year only (e.g. "5 Sep 2000").
  String _formatBirthday(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '—';
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return trimmed;
    final month = _monthNames[parsed.month.clamp(1, 12)];
    return '${parsed.day} $month ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final user = context.watch<UserViewModel>().currentUser;
    final sessions = context.watch<SessionViewModel>().mySessions;
    final classCount =
        sessions.map((s) => s.classroomId ?? '').where((e) => e.isNotEmpty).toSet().length;
    final textPrimary = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1B2233);

    final hasPhoto =
        user?.profilePictureURL.isNotEmpty == true;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _ensureStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textPrimary)),
              const SizedBox(height: 4),
              Text('Manage your account',
                  style: TextStyle(fontSize: 14, color: colors.subtitleText)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.inputBorder),
                ),
                child: Row(
                  children: [
                    hasPhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              user!.profilePictureURL,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  _initialsAvatar(colors, user.initials),
                            ),
                          )
                        : _initialsAvatar(
                            colors,
                            user?.initials.isNotEmpty == true
                                ? user!.initials
                                : '?'),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName.trim().isNotEmpty == true
                                ? user!.displayName
                                : 'Teacher',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textPrimary),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email.isNotEmpty == true ? user!.email : '—',
                            style: TextStyle(
                                fontSize: 13, color: colors.subtitleText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.inputBorder),
                ),
                child: Column(
                  children: [
                    _ProfileRow(
                        label: 'First Name',
                        value: user?.firstName.isNotEmpty == true
                            ? user!.firstName
                            : '—',
                        colors: colors,
                        textPrimary: textPrimary),
                    Divider(height: 1, color: colors.inputBorder),
                    _ProfileRow(
                        label: 'Last Name',
                        value: user?.lastName.isNotEmpty == true
                            ? user!.lastName
                            : '—',
                        colors: colors,
                        textPrimary: textPrimary),
                    Divider(height: 1, color: colors.inputBorder),
                    _ProfileRow(
                        label: 'Email',
                        value: user?.email.isNotEmpty == true
                            ? user!.email
                            : '—',
                        colors: colors,
                        textPrimary: textPrimary),
                    Divider(height: 1, color: colors.inputBorder),
                    _ProfileRow(
                        label: 'Classes taught',
                        value: '$classCount',
                        colors: colors,
                        textPrimary: textPrimary),
                    Divider(height: 1, color: colors.inputBorder),
                    _ProfileRow(
                        label: 'Birthday',
                        value: user?.birthday.isNotEmpty == true
                            ? _formatBirthday(user!.birthday)
                            : '—',
                        colors: colors,
                        textPrimary: textPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.inputBorder),
                ),
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.photo_camera_outlined,
                      label: 'Change profile picture',
                      trailing: 'Not available',
                      colors: colors,
                      textPrimary: textPrimary,
                      onTap: () => _unsupported('profile-picture update'),
                    ),
                    Divider(height: 1, color: colors.inputBorder),
                    _ActionRow(
                      icon: Icons.person_outline,
                      label: 'Change username',
                      trailing: 'Not available',
                      colors: colors,
                      textPrimary: textPrimary,
                      onTap: () => _unsupported('username update'),
                    ),
                    Divider(height: 1, color: colors.inputBorder),
                    _ActionRow(
                      icon: Icons.lock_outline,
                      label: 'Change password',
                      trailing: 'Not available',
                      colors: colors,
                      textPrimary: textPrimary,
                      onTap: () => _unsupported('password update'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _logout(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFE53935),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Logout',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsAvatar(AppColors colors, String initials) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors.buttonGradient),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColors colors;
  final Color textPrimary;

  const _ProfileRow(
      {required this.label,
      required this.value,
      required this.colors,
      required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: colors.subtitleText)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailing;
  final AppColors colors;
  final Color textPrimary;
  final VoidCallback onTap;

  const _ActionRow(
      {required this.icon,
      required this.label,
      required this.trailing,
      required this.colors,
      required this.textPrimary,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.subtitleText),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary))),
            Text(trailing,
                style: TextStyle(fontSize: 12, color: colors.subtitleText)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right,
                size: 18, color: colors.subtitleText),
          ],
        ),
      ),
    );
  }
}
