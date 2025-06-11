import 'package:flutter/material.dart';
import 'package:neuro_parent/user/articles/tip_list.dart';
import 'package:neuro_parent/user/events/event_list.dart';
import 'package:neuro_parent/user/events/registered_events.dart';
import 'package:neuro_parent/user/profile/profile_page.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/user/bloc/user_article_bloc.dart';
import 'package:neuro_parent/user/bloc/user_event_bloc.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/models/event.dart';
import 'dart:math';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userArticleProvider.notifier).fetchArticles();
      ref.read(userEventProvider.notifier).fetchEvents();
    });
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/registered')) return 2;
    if (location.startsWith('/articles')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    final articleState = ref.watch(userArticleProvider);
    final articles = articleState.articles;

    final eventState = ref.watch(userEventProvider);
    final events = eventState.events;

    final isLoading = articleState.isLoading || eventState.isLoading;
    final error = articleState.error ?? eventState.error;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: _buildCurrentScreen(context, isLoading, error, articles, events),
      bottomNavigationBar: UserBottomNav(currentIndex: currentIndex),
    );
  }

  Widget _buildCurrentScreen(
    BuildContext context,
    bool isLoading,
    String? error,
    List<Article> articles,
    List<Event> events,
  ) {
    switch (_getCurrentIndex(context)) {
      case 0:
        return _buildHomeScreenContent(
          context,
          isLoading,
          error,
          articles,
          events,
        );
      case 1:
        return const EventsScreen();
      case 2:
        return const RegisteredEventsScreen();
      case 3:
        return const TipsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeScreenContent(
          context,
          isLoading,
          error,
          articles,
          events,
        );
    }
  }

  Widget _buildHomeScreenContent(
    BuildContext context,
    bool isLoading,
    String? error,
    List<Article> articles,
    List<Event> events,
  ) {
    // Select a random article if available
    Article? randomArticle;
    if (articles.isNotEmpty) {
      final random = Random();
      randomArticle = articles[random.nextInt(articles.length)];
    }

    // Select a random event if available
    Event? randomEvent;
    if (events.isNotEmpty) {
      final random = Random();
      randomEvent = events[random.nextInt(events.length)];
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            const Text(
              'Welcome to NeuroParent',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Improving neurodiversity, preventing therapy community and support',
              style: TextStyle(fontSize: 24, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              context,
              title: 'Explore Tips',
              description: 'Explore Tips',
              icon: Icons.sunny,
              onTap: () => context.go('/articles'),
            ),
            const SizedBox(height: 12),
            _buildEventItem(
              context,
              title: 'Find an Event',
              description: 'Find an Event',
              icon: Icons.calendar_month_outlined,
              onTap: () => context.go('/events'),
            ),
            const Text(
              'Community Highlihtts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (error != null) ...[
              Center(child: Text('Error: $error')),
            ] else if (randomArticle != null) ...[
              _buildCommunityHighlightCard(
                context,
                title: randomArticle.articleTitle,
                description:
                    '${randomArticle.articleContent.split(' ').take(10).join(' ')}...',
                icon: Icons.sunny,
                onTap:
                    () => context.go('/articles/${randomArticle!.articleId}'),
              ),
            ] else ...[
              _buildCommunityHighlightCard(
                context,
                title: 'No articles found',
                description: 'Check back later for new tips.',
                icon: Icons.sunny,
                onTap: () {}, // No navigation if no article
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (error != null) ...[
              Center(child: Text('Error: $error')),
            ] else if (randomEvent != null) ...[
              _buildEventItem(
                context,
                title: randomEvent.eventTitle,
                description: randomEvent.eventLocation,
                icon: Icons.support_agent_sharp,
                onTap: () => context.go('/events/${randomEvent!.eventId}'),
              ),
            ] else ...[
              _buildEventItem(
                context,
                title: 'No upcoming events',
                description: 'Check back later for new events.',
                icon: Icons.support_agent_sharp,
                onTap: () {}, // No navigation if no event
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventsScreen() {
    return const EventsScreen();
  }

  Widget _buildEventDetailScreen() {
    return const RegisteredEventsScreen();
  }

  Widget _buildTipsScreen() {
    return const TipsScreen();
  }

  Widget _buildProfileScreen() {
    return const ProfileScreen();
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: Text(actionText, style: const TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFFF3F6FC),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!, width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF8D1D1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: Colors.yellow),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEventItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Color(0xFFE3EBF5), width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: const Color(0xFFE3EBF5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCommunityHighlightCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFFF3F6FC),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Color(0xFFE3EBF5), width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
          child: Icon(icon, color: Colors.yellow),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
