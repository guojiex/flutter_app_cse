import 'package:flutter/material.dart';
import 'package:flutter_app_cse/search_data_source.dart';
import 'package:flutter_app_cse/custom_search_search_delegate.dart';
import 'package:tuple/tuple.dart';

enum SearchType {
  /// Search for web.
  webSearch,

  /// Search for image.
  imageSearch
}

class CustomSearchInheritDemoPage extends InheritedWidget {
  SearchType searchType;
  CustomSearchSearchDelegate delegate;
  String hintText;

  /// used to generate display name and route to other pages, in the left drawer.
  List<Tuple2<String, String>> otherRoutes;

  CustomSearchInheritDemoPage(this.delegate, this.hintText, this.searchType);

  CustomSearchInheritDemoPage.fakeStaticSource() {
    this.delegate = CustomSearchSearchDelegate.fakeStaticSource();
    this.hintText = 'Static Google Custom Web Search';
    this.searchType = SearchType.webSearch;
    otherRoutes = [
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch')
    ];
  }

  CustomSearchInheritDemoPage.fakeStaticSourceImageSearch() {
    this.delegate = CustomSearchSearchDelegate.fakeStaticSourceImageSearch();
    this.hintText = 'Static Google Custom Image Search';
    this.searchType = SearchType.imageSearch;
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch')
    ];
  }

  CustomSearchInheritDemoPage.customImageSearch() {
    this.delegate = new CustomSearchSearchDelegate.imageSearch(
        dataSource: CustomSearchDataSource(
            cx: '',
            apiKey: ''));
    this.hintText = 'Google Custom Image Search';
    this.searchType = SearchType.imageSearch;
    otherRoutes = [
      Tuple2<String, String>('Custom Web Search Demo', '/websearch')
    ];
  }

  CustomSearchInheritDemoPage.customWebSearch() {
    this.delegate = new CustomSearchSearchDelegate(
        dataSource: CustomSearchDataSource(
            cx: '',
            apiKey: ''));
    this.hintText = 'Google Custom Web Search';
    this.searchType = SearchType.webSearch;
    otherRoutes = [
      Tuple2<String, String>('Custom Image Search Demo', '/imagesearch')
    ];
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {}
}
