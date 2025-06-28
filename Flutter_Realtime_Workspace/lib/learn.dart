// 1. BASIC IMPLEMENTATION - Just wrap any scrollable widget
import 'package:flutter/material.dart';
import 'package:flutter_realtime_workspace/core/network/pull_refresh.dart';

// Example 1: Simple ListView with pull-to-refresh
class MyListPage extends StatefulWidget {
  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  Future<void> _onRefresh() async {
    // Your refresh logic here (API calls, data fetching, etc.)
    await Future.delayed(Duration(seconds: 2)); // Simulate API call

    setState(() {
      items = ['New Item 1', 'New Item 2', 'New Item 3'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My List')),
      body: AdvancedPullRefresh(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index]),
            );
          },
        ),
      ),
    );
  }
}

// Example 2: GridView with pull-to-refresh
class MyGridPage extends StatefulWidget {
  @override
  State<MyGridPage> createState() => _MyGridPageState();
}

class _MyGridPageState extends State<MyGridPage> {
  List<int> numbers = List.generate(20, (index) => index + 1);

  Future<void> _onRefresh() async {
    // Your refresh logic
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      numbers.shuffle(); // Just shuffle for demo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Grid')),
      body: AdvancedPullRefresh(
        onRefresh: _onRefresh,
        refreshText: 'Pull to shuffle',
        primaryColor: Colors.purple,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.blue,
              child: Center(
                child: Text(
                  '${numbers[index]}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Example 3: SingleChildScrollView with pull-to-refresh
class MyScrollPage extends StatefulWidget {
  @override
  State<MyScrollPage> createState() => _MyScrollPageState();
}

class _MyScrollPageState extends State<MyScrollPage> {
  String lastRefresh = 'Never';

  Future<void> _onRefresh() async {
    // Your refresh logic
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      lastRefresh = DateTime.now().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Scroll Page')),
      body: AdvancedPullRefresh(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Last refreshed: $lastRefresh'),
                SizedBox(height: 20),
                // Your other widgets...
                ...List.generate(
                    10,
                    (index) => Card(
                          child: ListTile(
                            title: Text('Card ${index + 1}'),
                          ),
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example 4: With pagination (load more)
class MyPaginatedPage extends StatefulWidget {
  @override
  State<MyPaginatedPage> createState() => _MyPaginatedPageState();
}

class _MyPaginatedPageState extends State<MyPaginatedPage> {
  List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
  bool hasMore = true;

  Future<void> _onRefresh() async {
    // Refresh data
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      items = List.generate(20, (index) => 'Refreshed Item ${index + 1}');
      hasMore = true;
    });
  }

  Future<void> _loadMore() async {
    // Load more data
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      int currentLength = items.length;
      items.addAll(
          List.generate(10, (index) => 'Item ${currentLength + index + 1}'));

      // Stop loading more after 50 items
      if (items.length >= 50) {
        hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paginated List')),
      body: AdvancedPullRefresh(
        onRefresh: _onRefresh,
        onLoading: hasMore ? _loadMore : null,
        enablePullUp: hasMore,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index]),
            );
          },
        ),
      ),
    );
  }
}

// Example 5: Using global refresh key (for app-wide refresh)
class MyGlobalRefreshPage extends StatefulWidget {
  @override
  State<MyGlobalRefreshPage> createState() => _MyGlobalRefreshPageState();
}

class _MyGlobalRefreshPageState extends State<MyGlobalRefreshPage> {
  String data = 'Initial Data';

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      data = 'Refreshed at ${DateTime.now()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Global Refresh'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh all pages globally
              final provider = RefreshProvider.of(context);
              provider?.controller.refreshAll();
            },
          ),
        ],
      ),
      body: AdvancedPullRefresh(
        refreshKey: 'my_page', // Global key for this page
        onRefresh: _onRefresh,
        child: Center(
          child: Text(data),
        ),
      ),
    );
  }
}

// Example 6: Network-aware refresh
class MyNetworkAwarePage extends StatefulWidget {
  @override
  State<MyNetworkAwarePage> createState() => _MyNetworkAwarePageState();
}

class _MyNetworkAwarePageState extends State<MyNetworkAwarePage> {
  String data = 'Initial Data';

  Future<void> _onRefresh() async {
    // This will automatically check network before refreshing
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      data = 'Network refreshed at ${DateTime.now()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Network Aware')),
      body: NetworkAwareRefresh(
        onRefresh: _onRefresh,
        child: Center(
          child: Text(data),
        ),
      ),
    );
  }
}

// QUICK USAGE SUMMARY:
/*

1. BASIC USAGE:
   AdvancedPullRefresh(
     onRefresh: _myRefreshFunction,
     child: ListView(...),
   )

2. WITH LOAD MORE:
   AdvancedPullRefresh(
     onRefresh: _myRefreshFunction,
     onLoading: _myLoadMoreFunction,
     enablePullUp: true,
     child: ListView(...),
   )

3. CUSTOM STYLING:
   AdvancedPullRefresh(
     onRefresh: _myRefreshFunction,
     refreshText: 'Custom refresh text',
     primaryColor: Colors.red,
     child: ListView(...),
   )

4. GLOBAL REFRESH:
   AdvancedPullRefresh(
     refreshKey: 'unique_page_key',
     onRefresh: _myRefreshFunction,
     child: ListView(...),
   )

5. NETWORK AWARE:
   NetworkAwareRefresh(
     onRefresh: _myRefreshFunction,
     child: ListView(...),
   )

IMPORTANT NOTES:
- For SingleChildScrollView, add: physics: AlwaysScrollableScrollPhysics()
- Your refresh function should be async and return Future<void>
- Use setState() to update your UI after refreshing
- The global refresh wrapper is already set up in your main.dart

*/
