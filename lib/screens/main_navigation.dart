import 'package:flutter/material.dart';
import 'projects/projects_list_page.dart';
import 'contacts/contacts_list_page.dart';
import 'documents/documents_list_page.dart';
import 'search/search_page.dart';
import 'projects/create_project_page.dart';
import 'settings/settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<ProjectsListPageState> _projectsKey = GlobalKey<ProjectsListPageState>();
  final GlobalKey<ContactsListPageState> _contactsKey = GlobalKey<ContactsListPageState>();
  final GlobalKey<DocumentsListPageState> _documentsKey = GlobalKey<DocumentsListPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ProjectsListPage(key: _projectsKey),
      ContactsListPage(key: _contactsKey),
      DocumentsListPage(key: _documentsKey),
      const SearchPage(),
    ];
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Projects';
      case 1:
        return 'Contacts';
      case 2:
        return 'Documents';
      case 3:
        return 'Search';
      default:
        return 'HomeApp';
    }
  }

  void _refreshCurrentPage() {
    switch (_currentIndex) {
      case 0:
        _projectsKey.currentState?.refreshProjects();
        break;
      case 1:
        // Add refresh method to contacts if needed
        break;
      case 2:
        // Add refresh method to documents if needed
        break;
      case 3:
        // Search page doesn't need refresh
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              ).then((_) {
                // Refresh current page after returning from settings
                _refreshCurrentPage();
              });
            },
            tooltip: 'Settings & Demo Data',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateProjectPage(),
                  ),
                );
                // Refresh the projects list after returning from create project page
                _projectsKey.currentState?.refreshProjects();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
            )
          : null,
    );
  }
}