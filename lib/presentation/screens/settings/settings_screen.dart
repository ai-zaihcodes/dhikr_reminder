import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/user_settings_entity.dart';
import '../../blocs/settings/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = state.settings;
          if (settings == null) {
            return const Center(child: Text('No settings available'));
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Enable/Disable Reminders
              _buildSectionHeader('General'),
              Card(
                child: SwitchListTile(
                  title: const Text('Enable Reminders'),
                  subtitle: const Text('Show dhikr when unlocking phone'),
                  value: settings.isEnabled,
                  onChanged: (value) {
                    context
                        .read<SettingsBloc>()
                        .add(ReminderToggled(value));
                  },
                ),
              ),
              SizedBox(height: 16.h),
              // Show Translation
              Card(
                child: SwitchListTile(
                  title: const Text('Show Translation'),
                  subtitle: const Text('Display English translation'),
                  value: settings.showTranslation,
                  onChanged: (value) {
                    final updated = settings.copyWith(showTranslation: value);
                    context
                        .read<SettingsBloc>()
                        .add(SettingsUpdated(updated));
                  },
                ),
              ),
              SizedBox(height: 24.h),
              // Frequency Settings
              _buildSectionHeader('Frequency'),
              Card(
                child: Column(
                  children: [
                    RadioListTile<FrequencyType>(
                      title: const Text('Every Unlock'),
                      subtitle: const Text('Show on every phone unlock'),
                      value: FrequencyType.everyUnlock,
                      groupValue: settings.frequencyType,
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<SettingsBloc>()
                              .add(FrequencyTypeChanged(value));
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<FrequencyType>(
                      title: const Text('Limited per Day'),
                      subtitle: const Text('Set a daily limit'),
                      value: FrequencyType.limitedPerDay,
                      groupValue: settings.frequencyType,
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<SettingsBloc>()
                              .add(FrequencyTypeChanged(value));
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Daily Limit Slider
              if (settings.frequencyType == FrequencyType.limitedPerDay) ...[
                SizedBox(height: 16.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Limit: ${settings.dailyLimit ?? 10}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Slider(
                          value: (settings.dailyLimit ?? 10).toDouble(),
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: (settings.dailyLimit ?? 10).toString(),
                          onChanged: (value) {
                            context
                                .read<SettingsBloc>()
                                .add(DailyLimitChanged(value.toInt()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              // Category Selection
              _buildSectionHeader('Categories'),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select categories to display',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          'morning',
                          'evening',
                          'general',
                          'forgiveness',
                          'gratitude',
                          'protection',
                        ].map((category) {
                          final isSelected = settings.selectedCategories.isEmpty ||
                              settings.selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(
                              category[0].toUpperCase() +
                                  category.substring(1),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              List<String> newCategories =
                                  List.from(settings.selectedCategories);
                              if (selected) {
                                newCategories.add(category);
                              } else {
                                newCategories.remove(category);
                              }
                              context.read<SettingsBloc>().add(
                                    SelectedCategoriesChanged(newCategories),
                                  );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Stats
              _buildSectionHeader('Statistics'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.format_quote),
                      title: const Text('Reminders Shown Today'),
                      trailing: Text(
                        '${settings.remindersShownToday}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (settings.lastReminderTime != null)
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Last Reminder'),
                        subtitle: Text(
                          _formatDateTime(settings.lastReminderTime!),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String prefix;
    if (date == today) {
      prefix = 'Today';
    } else if (date == today.subtract(const Duration(days: 1))) {
      prefix = 'Yesterday';
    } else {
      prefix = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$prefix at $time';
  }
}
