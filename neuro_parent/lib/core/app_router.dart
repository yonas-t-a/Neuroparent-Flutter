import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/home_page.dart';
import 'package:neuro_parent/user/events/event_list.dart';
import 'package:neuro_parent/user/events/registered_events.dart';
import 'package:neuro_parent/user/articles/tip_list.dart';
import 'package:neuro_parent/user/profile/profile_page.dart';
import 'package:neuro_parent/user/profile/profile_detail.dart';
import 'package:neuro_parent/user/events/event_detail.dart';
import 'package:neuro_parent/user/articles/article_detail.dart';
import 'package:flutter/material.dart';
import 'package:neuro_parent/admin/add_page.dart';
import 'package:neuro_parent/admin/articles/create_article.dart';
import 'package:neuro_parent/admin/articles/edit_article.dart';
import 'package:neuro_parent/admin/events/create_event.dart';
import 'package:neuro_parent/admin/events/edit_event.dart';
import '../auth/auth_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/admin/articles/my_created_articles.dart';
import 'package:neuro_parent/admin/events/edit_my_events.dart';
import '../auth/login_page.dart';
import '../auth/signup_page.dart';

enum AdminRoute {
  home,
  articles,
  events,
  registeredEvents,
  profile,
  add,
  createArticle,
  editArticle,
  createEvent,
  editEvent,
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        name: 'eventDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(body: Center(child: Text('Invalid event id.')));
          }
          return EventDetailsScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/registered',
        name: 'registered',
        builder: (context, state) => const RegisteredEventsScreen(),
      ),
      GoRoute(
        path: '/articles',
        name: 'articles',
        builder: (context, state) => const TipsScreen(),
      ),
      GoRoute(
        path: '/articles/:id',
        name: 'articleDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(body: Center(child: Text('Invalid article id.')));
          }
          return ArticleDetailScreen(articleId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profileEdit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/admin/add',
        name: 'adminAdd',
        builder:
            (context, state) =>
                AddPage(key: state.extra is Key ? state.extra as Key : null),
      ),
      GoRoute(
        path: '/admin/create-article',
        name: 'adminCreateArticle',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authProvider);
              final token =
                  authState is AuthSuccess ? authState.token ?? '' : '';
              return CreateArticlePage(jwtToken: token);
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-article',
        name: 'adminEditArticle',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authProvider);
              final token =
                  authState is AuthSuccess ? authState.token ?? '' : '';
              return EditArticlePage(jwtToken: token);
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/edit-article/:id',
        name: 'adminEditArticleDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(body: Center(child: Text('Invalid article id.')));
          }
          return Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authProvider);
              final token =
                  authState is AuthSuccess ? authState.token ?? '' : '';
              return MyCreatedArticlesPage(jwtToken: token, articleId: id);
            },
          );
        },
      ),
      GoRoute(
        path: '/admin/create-event',
        name: 'adminCreateEvent',
        builder: (context, state) => const CreateEventPage(),
      ),
      GoRoute(
        path: '/admin/edit-event',
        name: 'adminEditEvent',
        builder: (context, state) => const EditEventPage(),
      ),
      GoRoute(
        path: '/admin/edit-event/:id',
        name: 'adminEditEventDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(body: Center(child: Text('Invalid event id.')));
          }
          return Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authProvider);
              final token =
                  authState is AuthSuccess ? authState.token ?? '' : '';
              return EditMyEventPage(eventId: id);
            },
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authState is AuthSuccess;
      final loggingIn = state.uri.path == '/login';
      final signingUp = state.uri.path == '/signup';

      // If not logged in, but not on login/signup page, go to login.
      if (!loggedIn && !loggingIn && !signingUp) return '/login';

      // If logged in, but on login/signup page, go to home.
      if (loggedIn && (loggingIn || signingUp)) return '/home';

      // No redirect needed
      return null;
    },
  );
});
