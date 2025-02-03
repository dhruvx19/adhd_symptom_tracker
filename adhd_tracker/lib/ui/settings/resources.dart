import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Popular Collections',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CollectionsGrid(searchQuery: _searchQuery),
              const SizedBox(height: 24),
              const Text(
                'Featured Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FeaturedResourcesList(searchQuery: _searchQuery),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const SearchBar({
    Key? key,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Search resources',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class FeaturedResourcesList extends StatelessWidget {
  final String searchQuery;

  const FeaturedResourcesList({
    Key? key,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resources = [
      {
        'title': 'Understanding ADHD',
        'author': 'CDC',
        'url': 'https://www.cdc.gov/ncbddd/adhd/facts.html'
      },
      {
        'title': 'ADHD in Women and Girls',
        'author': 'CHADD',
        'url': 'https://chadd.org/for-adults/women-and-girls/'
      },
      {
        'title': 'Managing Adult ADHD',
        'author': 'National Institute of Mental Health',
        'url':
            'https://www.nimh.nih.gov/health/publications/attention-deficit-hyperactivity-disorder-in-adults'
      },
      {
        'title': 'ADHD Treatment Guidelines',
        'author': 'American Academy of Pediatrics',
        'url': 'https://www.aap.org/adhd'
      },
      {
        'title': 'ADHD and Executive Function',
        'author': 'ADDitude Magazine',
        'url': 'https://www.additudemag.com/category/adhd-add/adhd-essentials/'
      },
    ];

    final filteredResources = resources.where((resource) {
      final titleMatch = resource['title']!.toLowerCase().contains(searchQuery);
      final authorMatch =
          resource['author']!.toLowerCase().contains(searchQuery);
      return titleMatch || authorMatch;
    }).toList();

    return filteredResources.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No resources found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredResources.length,
            itemBuilder: (context, index) {
              return ResourceListItem(
                title: filteredResources[index]['title']!,
                author: filteredResources[index]['author']!,
                url: filteredResources[index]['url']!,
              );
            },
          );
  }
}

class ResourceListItem extends StatelessWidget {
  final String title;
  final String author;
  final String url;

  const ResourceListItem({
    Key? key,
    required this.title,
    required this.author,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: url, title: title),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: $author',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(url: url, title: title),
                  ),
                );
              },
              child: const Text('Read Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionsGrid extends StatelessWidget {
  final String searchQuery;

  const CollectionsGrid({
    Key? key, 
    this.searchQuery = '',
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final collections = [
      {
        'title': 'ADHD and Relationships',
        'imageUrl':
            'https://images.unsplash.com/photo-1529156069898-49953e39b3ac',
        'url':
            'https://www.helpguide.org/articles/add-adhd/adult-adhd-attention-deficit-disorder-and-relationships.htm'
      },
      {
        'title': 'ADHD at Work',
        'imageUrl':
            'https://images.unsplash.com/photo-1529156069898-49953e39b3ac',
        'url':
            'https://www.nami.org/Blogs/NAMI-Blog/January-2019/How-to-Manage-the-Impact-of-ADHD-on-Your-Work-Life'
      },
      {
        'title': 'ADHD and Education',
        'imageUrl':
            'https://images.unsplash.com/photo-1529156069898-49953e39b3ac',
        'url':
            'https://childmind.org/article/teachers-guide-to-adhd-in-the-classroom/'
      },
    ];

    final filteredCollections = collections.where((collection) {
      return collection['title']!.toLowerCase().contains(searchQuery);
    }).toList();

    return filteredCollections.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredCollections.length,
              itemBuilder: (context, index) {
                return CollectionCard(
                  title: filteredCollections[index]['title']!,
                  imageUrl: filteredCollections[index]['imageUrl']!,
                  url: filteredCollections[index]['url']!,
                );
              },
            ),
          );
  }
}
class CollectionCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String url;

  const CollectionCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: url, title: title),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 120,
                    width: 180,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 120,
                    width: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isLoading = true;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED);
            },
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                clearCache: true,

                preferredContentMode: UserPreferredContentMode.MOBILE,
                supportZoom: false,
                useOnLoadResource: true,
                javaScriptEnabled: true,
                // clearSessionCache: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
                allowsLinkPreview: false,
                isFraudulentWebsiteWarningEnabled: true,
                disableLongPressContextMenuOnLinks: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              controller.clearCache();
              CookieManager().deleteAllCookies();
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading page: $message'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('HTTP Error $statusCode: $description'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text('Loading... ${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
