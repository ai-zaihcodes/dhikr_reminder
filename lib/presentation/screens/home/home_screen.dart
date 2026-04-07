import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/quote/quote_bloc.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../widgets/quote_card.dart';
import '../quotes/quotes_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsRequested());
    context.read<QuoteBloc>().add(const RandomQuoteRequested());
  }

  void _showNewQuote() {
    final settingsState = context.read<SettingsBloc>().state;
    
    if (settingsState.hasReachedLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily limit reached. Come back tomorrow!'),
        ),
      );
      return;
    }

    context.read<QuoteBloc>().add(RandomQuoteRequested(
      categories: settingsState.settings?.selectedCategories.isEmpty ?? true
          ? null
          : settingsState.settings?.selectedCategories,
    ));
    
    // Increment counter
    context.read<SettingsBloc>().add(const ReminderShown());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikr Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Daily progress
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state.status == SettingsStatus.loaded && state.isLimitedMode) {
                  return Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Progress',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${state.remindersShown} / ${state.dailyLimit ?? 0}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        LinearProgressIndicator(
                          value: state.hasReachedLimit
                              ? 1.0
                              : (state.remindersShown / (state.dailyLimit ?? 1)),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            state.hasReachedLimit
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Quote display
            Expanded(
              child: BlocConsumer<QuoteBloc, QuoteState>(
                listener: (context, state) {
                  if (state.status == QuoteStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage ?? 'Error')),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == QuoteStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.selectedQuote != null) {
                    final settingsState = context.watch<SettingsBloc>().state;
                    return QuoteCard(
                      quote: state.selectedQuote!,
                      showTranslation: settingsState.settings?.showTranslation ?? true,
                      onDismiss: _showNewQuote,
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Tap below to get a Dhikr',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom actions
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _showNewQuote,
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Dhikr'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const QuotesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('All'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
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
  }
}
