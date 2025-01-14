part of graphview;

class Graph {
  final List<Node> _nodes = [];
  final List<Edge> _edges = [];
  List<GraphObserver> graphObserver = [];

  List<Node> get nodes => _nodes; //  List<Node> nodes = _nodes;
  List<Edge> get edges => _edges;

  var isTree = false;

  int nodeCount() => _nodes.length;

  void addNode(Node node) {
    // if (!_nodes.contains(node)) {
    _nodes.add(node);
    notifyGraphObserver();
    // }
  }

  void addNodes(List<Node> nodes) => nodes.forEach((it) => addNode(it));

  void removeNode(Node? node) {
    if (!_nodes.contains(node)) {
//            throw IllegalArgumentException("Unable to find node in graph.")
    }

    if (isTree) {
      successorsOf(node).forEach((element) => removeNode(element));
    }

    _nodes.remove(node);

    _edges.removeWhere((edge) => edge.houseHold == node || edge.child == node);

    notifyGraphObserver();
  }

  void removeNodes(List<Node> nodes) => nodes.forEach((it) => removeNode(it));

  Edge addEdge(HouseholdNode houseHold, Node child, {Paint? paint}) {
    final edge = Edge(houseHold, child, paint: paint);
    addEdgeS(edge);

    return edge;
  }

  void addEdgeS(Edge edge) {
    var sourceSet = false;
    var destinationSet = false;
    _nodes.forEach((node) {
      if (!sourceSet && node == edge.houseHold && node is HouseholdNode) {
        edge.houseHold = node;
        sourceSet = true;
      } else if (!destinationSet && node == edge.child) {
        edge.child = node;
        destinationSet = true;
      }
    });
    if (!sourceSet) {
      _nodes.add(edge.houseHold);
    }
    if (!destinationSet) {
      _nodes.add(edge.child);
    }

    if (!_edges.contains(edge)) {
      _edges.add(edge);
      notifyGraphObserver();
    }
  }

  void addEdges(List<Edge> edges) => edges.forEach((it) => addEdgeS(it));

  void removeEdge(Edge edge) => _edges.remove(edge);

  void removeEdges(List<Edge> edges) => edges.forEach((it) => removeEdge(it));

  void removeEdgeFromPredecessor(Node? predecessor, Node? current) {
    _edges.removeWhere(
        (edge) => edge.houseHold == predecessor && edge.child == current);
  }

  bool hasNodes() => _nodes.isNotEmpty;

  Edge? getEdgeBetween(Node source, Node? destination) =>
      _edges.firstWhereOrNull((element) =>
          element.houseHold == source && element.child == destination);

  bool hasSuccessor(Node? node) =>
      _edges.any((element) => element.houseHold == node);

  List<Node> successorsOf(Node? node) =>
      getOutEdges(node!).map((e) => e.child).toList();

  bool hasPredecessor(Node node) =>
      _edges.any((element) => element.child == node);

  List<Node> predecessorsOf(Node? node) =>
      getInEdges(node!).map((edge) => edge.houseHold).toList();

  bool contains({Node? node, Edge? edge}) =>
      node != null && _nodes.contains(node) ||
      edge != null && _edges.contains(edge);

//  bool contains(Edge edge) => _edges.contains(edge);

  Node getNodeAtPosition(int position) {
    if (position < 0) {
//            throw IllegalArgumentException("position can't be negative")
    }

    final size = _nodes.length;
    if (position >= size) {
//            throw IndexOutOfBoundsException("Position: $position, Size: $size")
    }

    return _nodes[position];
  }

  Node getNodeUsingKey(ValueKey key) =>
      _nodes.firstWhere((element) => element.key == key);

  Node getNodeUsingId(dynamic id) =>
      _nodes.firstWhere((element) => element.key == ValueKey(id));

  List<Edge> getOutEdges(Node node) =>
      _edges.where((element) => element.houseHold == node).toList();

  List<Edge> getInEdges(Node node) =>
      _edges.where((element) => element.child == node).toList();

  void notifyGraphObserver() => graphObserver.forEach((element) {
        element.notifyGraphInvalidated();
      });

  String toJson() {
    var jsonString = {
      'nodes': [..._nodes.map((e) => e.hashCode.toString())],
      'edges': [
        ..._edges.map((e) => {
              'from': e.houseHold.hashCode.toString(),
              'to': e.child.hashCode.toString()
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
}

class Edge {
  HouseholdNode houseHold;
  Node child;

  Key? key;
  Paint? paint;

  Edge(this.houseHold, this.child, {this.key, this.paint});

  @override
  bool operator ==(Object? other) =>
      identical(this, other) || other is Edge && hashCode == other.hashCode;

  @override
  int get hashCode => key?.hashCode ?? Object.hash(houseHold, child);
}

abstract class GraphObserver {
  void notifyGraphInvalidated();
}
