// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:math' show min;

/// Finds the strongly connected components of a directed graph using Tarjan's
/// algorithm.
///
/// The result will be a valid reverse topological order ordering of the
/// strongly connected components. Components further from a root will appear in
/// the result before the components which they are children of.
///
/// Nodes within a strongly connected component have no ordering guarantees,
/// except that if the first value in [nodes] is a valid root, and is contained
/// in a cycle, it will be the last element of that cycle.
///
/// [V] is the type of values in the graph nodes. [K] must be a type suitable
/// for using as a Map or Set key, and [key] must provide a consistent key for
/// every node. [children] should return the next reachable nodes.
///
/// [nodes] must contain at least a root of every tree in the graph if there are
/// disjoint subgraphs but it may contain all nodes in the graph if the roots
/// are not known.
List<List<V>> stronglyConnectedComponents<K, V>(
    Iterable<V> nodes, K Function(V) key, Iterable<V> Function(V) children) {
  final result = <List<V>>[];
  final lowLinks = <K, int>{};
  final indexes = <K, int>{};
  final onStack = new Set<K>();

  var index = 0;
  var lastVisited = new Queue<V>();

  void strongConnect(V node) {
    var nodeKey = key(node);
    indexes[nodeKey] = index;
    lowLinks[nodeKey] = index;
    index++;
    lastVisited.addLast(node);
    onStack.add(nodeKey);
    for (final V next in children(node) ?? const []) {
      var nextKey = key(next);
      if (!indexes.containsKey(nextKey)) {
        strongConnect(next);
        lowLinks[nodeKey] = min(lowLinks[nodeKey], lowLinks[nextKey]);
      } else if (onStack.contains(nextKey)) {
        lowLinks[nodeKey] = min(lowLinks[nodeKey], indexes[nextKey]);
      }
    }
    if (lowLinks[nodeKey] == indexes[nodeKey]) {
      final component = <V>[];
      K nextKey;
      do {
        var next = lastVisited.removeLast();
        nextKey = key(next);
        onStack.remove(nextKey);
        component.add(next);
      } while (nextKey != nodeKey);
      result.add(component);
    }
  }

  for (final node in nodes) {
    if (!indexes.containsKey(key(node))) strongConnect(node);
  }
  return result;
}
