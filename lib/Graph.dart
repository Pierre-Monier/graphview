part of graphview;

class Graph {
  final List<GenerationNode> _generations = [];
  final List<Edge> _edges = [];
  List<GraphObserver> graphObserver = [];

  List<GenerationNode> get generations => _generations;
  List<Edge> get edges => _edges;

  var isTree = false;

  Graph();

  int nodeCount() => _generations.length;

  void removeNode(Node? node) {
    if (!_generations.contains(node)) {
//            throw IllegalArgumentException("Unable to find node in graph.")
    }

    if (isTree) {
      successorsOf(node).forEach((element) => removeNode(element));
    }

    _generations.remove(node);

    _edges.removeWhere(
        (edge) => edge.ancestors == node || edge.descendants == node);

    notifyGraphObserver();
  }

  void removeNodes(List<Node> nodes) => nodes.forEach((it) => removeNode(it));

  void setEdges(List<Edge> edges) {
    _edges.clear();
    _generations.clear();
    addEdges(edges);

    var rootGeneration = getFirstNode() as GenerationNode;
    for (final node in rootGeneration.nodes) {
      if (node is HouseholdNode) {
        node.husband.isARelativeDescendant = true;
        node.wife.isARelativeDescendant = true;
      } else {
        node.isARelativeDescendant = true;
      }
    }

    notifyGraphObserver();
  }

  Node getFirstNode() =>
      generations.firstWhere((node) => !hasPredecessor(node));

  Edge addEdge(GenerationNode ancestors, GenerationNode descendants,
      {Paint? paint,
      required Node relativeDescendant,
      required HouseholdNode relativeAncestor}) {
    final edge = Edge(
        ancestors: ancestors,
        descendants: descendants,
        relativeAncestor: relativeAncestor,
        relativeDescendant: relativeDescendant,
        paint: paint);
    addEdgeS(edge);

    return edge;
  }

  void addEdgeS(Edge edge) {
    var sourceSet = false;
    var destinationSet = false;
    edge.relativeDescendant.isARelativeDescendant = true;
    _generations.forEach((node) {
      if (!sourceSet && node == edge.ancestors) {
        edge.ancestors = node;
        sourceSet = true;
      } else if (!destinationSet && node == edge.descendants) {
        edge.descendants = node;
        destinationSet = true;
      }
    });
    if (!sourceSet) {
      _generations.add(edge.ancestors);
    }
    if (!destinationSet) {
      _generations.add(edge.descendants);
    }

    if (!_edges.contains(edge)) {
      _edges.add(edge);
    }
  }

  void addEdges(List<Edge> edges) => edges.forEach((it) => addEdgeS(it));

  void removeEdge(Edge edge) => _edges.remove(edge);

  void removeEdges(List<Edge> edges) => edges.forEach((it) => removeEdge(it));

  void removeEdgeFromPredecessor(Node? predecessor, Node? current) {
    _edges.removeWhere(
        (edge) => edge.ancestors == predecessor && edge.descendants == current);
  }

  bool hasNodes() => _generations.isNotEmpty;

  Iterable<Edge> getEdgesBetween(Node source, Node? destination) =>
      _edges.where((element) =>
          element.ancestors == source && element.descendants == destination);

  bool hasSuccessor(Node? node) =>
      _edges.any((element) => element.ancestors == node);

  List<Node> successorsOf(Node? node) =>
      getOutEdges(node!).map((e) => e.descendants).toList();

  List<GenerationNode> getNextGenerations(GenerationNode generation) =>
      getOutEdges(generation).map((e) => e.descendants).toSet().toList();

  bool hasPredecessor(Node node) =>
      _edges.any((element) => element.descendants == node);

  List<Node> predecessorsOf(Node? node) =>
      getInEdges(node!).map((edge) => edge.ancestors).toList();

  bool contains({Node? node, Edge? edge}) =>
      node != null && _generations.contains(node) ||
      edge != null && _edges.contains(edge);

//  bool contains(Edge edge) => _edges.contains(edge);

  Node getNodeAtPosition(int position) {
    if (position < 0) {
//            throw IllegalArgumentException("position can't be negative")
    }

    final size = _generations.length;
    if (position >= size) {
//            throw IndexOutOfBoundsException("Position: $position, Size: $size")
    }

    return _generations[position];
  }

  Node getNodeUsingKey(ValueKey key) =>
      _generations.firstWhere((element) => element.key == key);

  Node getNodeUsingId(dynamic id) =>
      _generations.firstWhere((element) => element.key == ValueKey(id));

  List<Edge> getOutEdges(Node node) =>
      _edges.where((element) => element.ancestors == node).toList();

  List<Edge> getInEdges(Node node) =>
      _edges.where((element) => element.descendants == node).toList();

  void notifyGraphObserver() => graphObserver.forEach((element) {
        element.notifyGraphInvalidated();
      });

  String toJson() {
    var jsonString = {
      'nodes': [..._generations.map((e) => e.hashCode.toString())],
      'edges': [
        ..._edges.map((e) => {
              'from': e.ancestors.hashCode.toString(),
              'to': e.descendants.hashCode.toString()
            })
      ]
    };

    return json.encode(jsonString);
  }
}

class Node {
  final ValueKey key;

  Node.Id(dynamic id) : key = ValueKey(id);

  Size size = Size(0, 0);

  Offset position = Offset(0, 0);

  double get height => size.height;

  double get width => size.width;

  double get x => position.dx;

  double get y => position.dy;

  var isARelativeDescendant = false;

  set y(double value) {
    position = Offset(position.dx, value);
  }

  set x(double value) {
    position = Offset(value, position.dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Node && hashCode == other.hashCode;

  @override
  int get hashCode {
    return key.value.hashCode;
  }

  @override
  String toString() {
    return 'Node{position: $position, key: $key, _size: $size}';
  }
}

class HouseholdNode extends Node {
  HouseholdNode.Id(id, this.husband, this.wife) : super.Id(id);
  final Node husband;
  final Node wife;

  static double householdSeparation = 0.0;

  @override
  Size get size {
    // maybe cache this to avoid unecessary calculations
    return Size(husband.width + householdSeparation + wife.width,
        max(husband.height, wife.height));
  }
}

class GenerationNode extends Node {
  GenerationNode.Id(id, this.nodes) : super.Id(id);
  List<Node> nodes = [];
  static double siblingSeparation = 0.0;

  @override
  Size get size {
    final sizes = nodes.map((node) => node.size);
    final width = sizes.fold<double>(
            0, (previousValue, element) => previousValue + element.width) +
        (nodes.length - 1) * siblingSeparation;
    final height = sizes.fold<double>(
      0,
      (previousValue, element) => max(previousValue, element.height),
    );

    return Size(width, height);
  }
}

class Edge {
  GenerationNode ancestors;
  GenerationNode descendants;
  HouseholdNode relativeAncestor;
  Node relativeDescendant;

  Key? key;
  Paint? paint;

  Edge({
    required this.ancestors,
    required this.descendants,
    required this.relativeAncestor,
    required this.relativeDescendant,
    this.key,
    this.paint,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          hashCode == other.hashCode &&
          key == other.key &&
          ancestors == other.ancestors &&
          descendants == other.descendants &&
          relativeAncestor == other.relativeAncestor &&
          relativeDescendant == other.relativeDescendant &&
          paint == other.paint;

  @override
  int get hashCode =>
      key?.hashCode ??
      Object.hash(ancestors, descendants, relativeAncestor, relativeDescendant,
          key, paint);
}

abstract class GraphObserver {
  void notifyGraphInvalidated();
}
