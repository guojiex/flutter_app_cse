import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:convert';
import 'package:expire_cache/expire_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:googleapis/customsearch/v1.dart' as customsearch;
import 'package:english_words/english_words.dart';
import 'package:async/async.dart';

/// A wrapper class for [customsearch.Result].
/// [SearchResult] will use the landing page link to measure if two results are
/// the same. This is useful for deduplicating image search result.
class SearchResult {
  final customsearch.Result result;

  SearchResult(this.result);

  SearchResult.escapeLineBreakInSnippet(this.result) {
    this.result.snippet = this.result.snippet.replaceAll("\n", "");
  }

  @override
  String toString() {
    return 'title:${this.result.title}\nsnippet:${this.result.snippet}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    // Use landing page link to see if two results are the same.
    if (this.result.image != null) {
      return other is SearchResult &&
          runtimeType == other.runtimeType &&
          result.image.contextLink == other.result.image.contextLink;
    } else {
      return other is SearchResult &&
          runtimeType == other.runtimeType &&
          result.link == other.result.link;
    }
  }

  @override
  int get hashCode =>
      result.image == null
          ? result.link.hashCode
          : result.image.contextLink.hashCode;
}

class Promotion {
  final customsearch.Promotion promotion;

  Promotion(this.promotion);
}

class NextPage {
  final customsearch.Query query;

  NextPage(this.query);
}

/// A wrapper class to aggregate all the search result fields that we need.
///
/// And deduplicate results.
class SearchResults {
  List<SearchResult> searchResults = List<SearchResult>();
  List<Promotion> promotions = List<Promotion>();

  SearchResults.empty();

  SearchResults(customsearch.Search search) {
    var results = new List<SearchResult>();
    search.items.forEach(
            (item) => results.add(SearchResult.escapeLineBreakInSnippet(item)));
    // Deduplicate search result.
    this.searchResults = Set<SearchResult>.from(results).toList();
  }
}

/// Abstract class for Search Data Source.
abstract class SearchDataSource {
  Future<SearchResults> search(String query, {String searchType});
}

class _StaticSearchResponse {
  final String assetPath;
  final String searchType;
  String searchResponseJsonString;

  _StaticSearchResponse(
      {this.assetPath, this.searchType, this.searchResponseJsonString});
}

class FakeSearchDataSource implements SearchDataSource {
  final Map<String, _StaticSearchResponse> searchResponses = {
    'web': _StaticSearchResponse(
        assetPath: 'res/sampledata/nytimes_sample_data.json'),
    'image': _StaticSearchResponse(
        assetPath: 'res/sampledata/nytimes_image_sample_data.json',
        searchType: 'image'),
    'promotion': _StaticSearchResponse(
        assetPath: 'res/sampledata/nytimes_with_promotion.json'),
  };
  final ExpireCache<SearchQuery, SearchResults> _cache =
  ExpireCache<SearchQuery, SearchResults>();
  final String cx = 'fake_cx';

  FakeSearchDataSource() {
    searchResponses.keys.forEach((key) {
      loadAssetToSearchResponse(key, searchResponses[key].assetPath);
    });
  }

  void loadAssetToSearchResponse(String searchKey, String assetPath) async {
    searchResponses[searchKey].searchResponseJsonString =
    await rootBundle.loadString(assetPath);
  }

  int count = 0;

  @override
  Future<SearchResults> search(String query, {String searchType}) async {
    if (!searchResponses.containsKey(query)) {
      return SearchResults.empty();
    }
    if (searchResponses[query].searchType != searchType) {
      return SearchResults.empty();
    }
    SearchQuery searchQuery =
    SearchQuery(query, this.cx, searchType: searchType);
    var cachedResponse = await _cache.get(searchQuery);
    if (cachedResponse != null) {
      return cachedResponse;
    }
    Map searchMap = jsonDecode(searchResponses[query].searchResponseJsonString);
    customsearch.Search search = customsearch.Search.fromJson(searchMap);

    print('count: $count');
    count++;

    var result = SearchResults(search);
    await _cache.set(searchQuery, result);
    return result;
  }
}

/// A wrapper class for search request, to make caching search request possible.
class SearchQuery {
  String q;
  String c2coff;
  String cr;
  String cx;
  String dateRestrict;
  String exactTerms;
  String excludeTerms;
  String fileType;
  String filter;
  String gl;
  String googlehost;
  String highRange;
  String hl;
  String hq;
  String imgColorType;
  String imgDominantColor;
  String imgSize;
  String imgType;
  String linkSite;
  String lowRange;
  String lr;
  int num;
  String orTerms;
  String relatedSite;
  String rights;
  String safe;
  String searchType;
  String siteSearch;
  String siteSearchFilter;
  String sort;
  int start;

  /// Used to get partial response, see:
  /// https://developers.google.com/custom-search/v1/performance#partial
  String fields;

  SearchQuery(this.q, this.cx,
      {this.c2coff,
        this.cr,
        this.dateRestrict,
        this.exactTerms,
        this.excludeTerms,
        this.fileType,
        this.filter,
        this.gl,
        this.googlehost,
        this.highRange,
        this.hl,
        this.hq,
        this.imgColorType,
        this.imgDominantColor,
        this.imgSize,
        this.imgType,
        this.linkSite,
        this.lowRange,
        this.lr,
        this.num,
        this.orTerms,
        this.relatedSite,
        this.rights,
        this.safe,
        this.searchType,
        this.siteSearch,
        this.siteSearchFilter,
        this.sort,
        this.start,
        this.fields});

  Future<SearchResults> runSearch(customsearch.CustomsearchApi api) async {
    return SearchResults(
        await api.cse.list(q, cx: cx, searchType: this.searchType));
  }

  @override
  String toString() {
    return 'SearchQuery{q: $q, c2coff: $c2coff, cr: $cr, cx: $cx, dateRestrict: $dateRestrict, exactTerms: $exactTerms, excludeTerms: $excludeTerms, fileType: $fileType, filter: $filter, gl: $gl, googlehost: $googlehost, highRange: $highRange, hl: $hl, hq: $hq, imgColorType: $imgColorType, imgDominantColor: $imgDominantColor, imgSize: $imgSize, imgType: $imgType, linkSite: $linkSite, lowRange: $lowRange, lr: $lr, num: $num, orTerms: $orTerms, relatedSite: $relatedSite, rights: $rights, safe: $safe, searchType: $searchType, siteSearch: $siteSearch, siteSearchFilter: $siteSearchFilter, sort: $sort, start: $start, fields: $fields}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SearchQuery &&
              runtimeType == other.runtimeType &&
              q == other.q &&
              c2coff == other.c2coff &&
              cr == other.cr &&
              cx == other.cx &&
              dateRestrict == other.dateRestrict &&
              exactTerms == other.exactTerms &&
              excludeTerms == other.excludeTerms &&
              fileType == other.fileType &&
              filter == other.filter &&
              gl == other.gl &&
              googlehost == other.googlehost &&
              highRange == other.highRange &&
              hl == other.hl &&
              hq == other.hq &&
              imgColorType == other.imgColorType &&
              imgDominantColor == other.imgDominantColor &&
              imgSize == other.imgSize &&
              imgType == other.imgType &&
              linkSite == other.linkSite &&
              lowRange == other.lowRange &&
              lr == other.lr &&
              num == other.num &&
              orTerms == other.orTerms &&
              relatedSite == other.relatedSite &&
              rights == other.rights &&
              safe == other.safe &&
              searchType == other.searchType &&
              siteSearch == other.siteSearch &&
              siteSearchFilter == other.siteSearchFilter &&
              sort == other.sort &&
              start == other.start &&
              fields == other.fields;

  @override
  int get hashCode =>
      q.hashCode ^
      c2coff.hashCode ^
      cr.hashCode ^
      cx.hashCode ^
      dateRestrict.hashCode ^
      exactTerms.hashCode ^
      excludeTerms.hashCode ^
      fileType.hashCode ^
      filter.hashCode ^
      gl.hashCode ^
      googlehost.hashCode ^
      highRange.hashCode ^
      hl.hashCode ^
      hq.hashCode ^
      imgColorType.hashCode ^
      imgDominantColor.hashCode ^
      imgSize.hashCode ^
      imgType.hashCode ^
      linkSite.hashCode ^
      lowRange.hashCode ^
      lr.hashCode ^
      num.hashCode ^
      orTerms.hashCode ^
      relatedSite.hashCode ^
      rights.hashCode ^
      safe.hashCode ^
      searchType.hashCode ^
      siteSearch.hashCode ^
      siteSearchFilter.hashCode ^
      sort.hashCode ^
      start.hashCode ^
      fields.hashCode;
}

/// The search data source that uses Custom Search API.
class CustomSearchDataSource implements SearchDataSource {
  final String cx;
  final String apiKey;
  customsearch.CustomsearchApi api;
  int searchCount = 0;
  final ExpireCache<SearchQuery, SearchResults> _cache =
  ExpireCache<SearchQuery, SearchResults>();

  CustomSearchDataSource({@required this.cx, @required this.apiKey}) {
    var client = auth.clientViaApiKey(apiKey);
    this.api = new customsearch.CustomsearchApi(client);
  }

  @override
  Future<SearchResults> search(String query, {String searchType}) async {
    if (query.isEmpty) {
      return SearchResults.empty();
    }
    SearchQuery searchQuery =
    SearchQuery(query, this.cx, searchType: searchType);

    final cachedResponse = await _cache.get(searchQuery);
    if (cachedResponse != null) {
      return cachedResponse;
    }

    print('count: $searchCount');
    searchCount++;

    final result = await searchQuery.runSearch(this.api);
    await _cache.set(searchQuery, result);
    return result;
  }
}

abstract class AutoCompleteDataSource {
  List<String> getAutoCompletions({String query, int resultNumber});
}

class CommonEnglishWordAutoCompleteDataSource
    implements AutoCompleteDataSource {
  const CommonEnglishWordAutoCompleteDataSource();

  @override
  List<String> getAutoCompletions({String query, int resultNumber = 10}) {
    var results = all.where((String word) => word.startsWith(query)).toList();
    return results.length > resultNumber
        ? results.sublist(0, resultNumber)
        : results;
  }
}
