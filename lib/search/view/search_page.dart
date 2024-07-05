import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/search/view/search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  Box<String> searchHistory = Hive.box('search_history');

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          previousPageTitle: 'Home',
          middle: Text('Search'),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(
                  child: CupertinoTextField(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: CupertinoColors.separator, width: 2)),
                    padding: const EdgeInsets.all(10),
                    controller: _searchController,
                    placeholder: 'Search',
                    clearButtonMode: OverlayVisibilityMode.editing,
                    // prefix: Icon(CupertinoIcons.search, color: AppPallete().accentColor)
                    onSubmitted: (value) {
                      value = value.trimRight();
                      if (value.isNotEmpty) {
                        searchHistory.add(value);
                        setState(() {});
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SearchResults(query: value),
                          ),
                        );
                      }
                      _searchController.clear();
                    },
                  ),
                ),
                if (searchHistory.isNotEmpty)
                  SliverToBoxAdapter(
                      child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ListView.builder(
                      itemCount: searchHistory.length,
                      itemBuilder: (context, index) {
                        return CupertinoListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SearchResults(
                                  query: searchHistory.values.elementAt(index),
                                ),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          trailing: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                searchHistory.deleteAt(index);
                                setState(() {});
                              },
                              icon: Icon(
                                CupertinoIcons.multiply,
                                color: AppPallete().accentColor,
                              )),
                          title: Text(
                            searchHistory.values.elementAt(index),
                          ),
                        );
                      },
                    ),
                  ))
                else
                  SliverToBoxAdapter(
                      child: Container(
                        padding:const EdgeInsets.only(top: 10),
                    child: const Text('No search history found!!'),
                  ))
              ],
            ),
          ),
        ));
  }
}
