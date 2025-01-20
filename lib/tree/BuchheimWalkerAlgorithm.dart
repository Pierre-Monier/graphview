part of graphview;

class BuchheimWalkerAlgorithm extends Algorithm {
  Map<Node, BuchheimWalkerNodeData> nodeData = {};
  double minNodeHeight = double.infinity;
  double minNodeWidth = double.infinity;
  double maxNodeWidth = double.negativeInfinity;
  double maxNodeHeight = double.negativeInfinity;
  BuchheimWalkerConfiguration configuration;
  @override
  final Size nodeSize;

  late final EdgeRenderer _edgeRenderer;

  bool isVertical() {
    var orientation = configuration.orientation;
    return orientation == BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  bool needReverseOrder() {
    return false;
  }

  @override
  Size run(Graph graph) {
    nodeData.clear();
    initData(graph);

    var rootGeneration = graph.getFirstNode() as GenerationNode;
    for (final node in rootGeneration.nodes) {
      if (node is HouseholdNode) {
        node.husband.isARelativeDescendant = true;
        node.wife.isARelativeDescendant = true;
      } else {
        node.isARelativeDescendant = true;
      }
    }
    firstWalk(graph, rootGeneration, 0, 0);
    secondWalk(graph, rootGeneration, 0.0);
    checkUnconnectedNotes(graph);

    final graphSize = calculateGraphSize(graph);

    alignFirstGeneration(rootGeneration, graphSize);
    alignNodes(graph);

    final newGraphSize = calculateGraphSize(graph);

    return newGraphSize;
  }

  void alignFirstGeneration(GenerationNode firstGeneration, Size graphSize) {
    // Center the first generation in the middle of the graph
    final centerOfTheGraph = graphSize.width / 2;
    final newFirstGenerationPosition = Offset(
      centerOfTheGraph - firstGeneration.width / 2,
      firstGeneration.y,
    );

    _setNewNodePosition(firstGeneration, newFirstGenerationPosition);
  }

  void alignNodes(Graph graph) {
    // Align each descendant to the center of its ancestors
    for (final edge in graph.edges) {
      final centerOfAncestors =
          edge.relativeAncestor.position.dx + (edge.relativeAncestor.width / 2);
      final newDescendantPosition = Offset(
        centerOfAncestors - edge.descendants.width / 2,
        edge.descendants.position.dy,
      );

      _setNewNodePosition(edge.descendants, newDescendantPosition);
    }
  }

  void checkUnconnectedNotes(Graph graph) {
    graph.generations.forEach((element) {
      if (getNodeData(element) == null) {
        if (!kReleaseMode) {
          print('$element is not connected to primary ancestor');
        }
      }
    });
  }

  int compare(int x, int y) {
    return x < y ? -1 : (x == y ? 0 : 1);
  }

  void firstWalk(Graph graph, Node node, int depth, int number) {
    if (node is! GenerationNode) {
      throw Exception(
        'You somehow manage to create an edge with a node that is not a GenerationNode',
      );
    }

    final nodeData = getNodeData(node)!;
    nodeData.depth = depth;
    nodeData.number = number;
    minNodeHeight = min(minNodeHeight, node.height);
    minNodeWidth = min(minNodeWidth, node.width);
    maxNodeWidth = max(maxNodeWidth, node.width);
    maxNodeHeight = max(maxNodeHeight, node.height);

    if (!isLeaf(graph, node)) {
      final leftMost = getLeftMostChild(graph, node);
      var defaultAncestor = leftMost;

      Node? next = leftMost;
      var i = 1;
      while (next != null) {
        firstWalk(graph, next, depth + 1, i++);
        defaultAncestor = apportion(graph, next, defaultAncestor);

        next = getRightSibling(graph, next);
      }

      executeShifts(graph, node);
    }
  }

  void secondWalk(Graph graph, Node node, double modifier) {
    if (node is! GenerationNode) {
      throw Exception(
          'You somehow manage to create an edge with a node that is not a GenerationNode');
    }

    var nodeData = getNodeData(node)!;
    var depth = nodeData.depth;
    var vertical = isVertical();

    final newNodePosition = Offset(
        (nodeData.prelim + modifier),
        (depth * (vertical ? minNodeHeight : minNodeWidth) +
                depth * configuration.levelSeparation)
            .ceilToDouble());

    _setNewNodePosition(node, newNodePosition);

    graph.successorsOf(node).forEach((w) {
      secondWalk(graph, w, modifier + nodeData.modifier);
    });
  }

  Size calculateGraphSize(Graph graph) {
    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;

    graph.generations.forEach((node) {
      left = min(left, node.x);
      top = min(top, node.y);
      right = max(right, node.x + node.width);
      bottom = max(bottom, node.y + node.height);
    });

    return Size(right - left, bottom - top);
  }

  void executeShifts(Graph graph, Node node) {
    var shift = 0.0;
    var change = 0.0;

    var w = getRightMostChild(graph, node);
    while (w != null) {
      final nodeData = getNodeData(w) ?? BuchheimWalkerNodeData();

      nodeData.prelim = nodeData.prelim + shift;
      nodeData.modifier = nodeData.modifier + shift;
      change += nodeData.change;
      shift += nodeData.shift + change;

      w = getLeftSibling(graph, w);
    }
  }

  Node apportion(Graph graph, Node node, Node defaultAncestor) {
    var ancestor = defaultAncestor;
    if (hasLeftSibling(graph, node)) {
      var leftSibling = getLeftSibling(graph, node);
      Node? vop = node;
      Node? vom = getLeftMostChild(graph, graph.predecessorsOf(node).first);
      var sip = getModifier(node);

      var sop = getModifier(node);

      var sim = getModifier(leftSibling);

      var som = getModifier(vom);
      var nextRight = this.nextRight(graph, leftSibling);

      Node? nextLeft;
      for (nextLeft = this.nextLeft(graph, node);
          nextRight != null && nextLeft != null;
          nextLeft = this.nextLeft(graph, nextLeft)) {
        vom = this.nextLeft(graph, vom);
        vop = this.nextRight(graph, vop);

        setAncestor(vop, node);
        var shift = getPrelim(nextRight) +
            sim -
            (getPrelim(nextLeft) + sip) +
            getSpacing(graph, nextRight, node);
        if (shift > 0) {
          moveSubtree(
              this.ancestor(graph, nextRight, node, ancestor), node, shift);
          sip += shift;
          sop += shift;
        }

        sim += getModifier(nextRight);
        sip += getModifier(nextLeft);

        som += getModifier(vom);
        sop += getModifier(vop);
        nextRight = this.nextRight(graph, nextRight);
      }

      if (nextRight != null && this.nextRight(graph, vop) == null) {
        setThread(vop, nextRight);
        setModifier(vop, getModifier(vop) + sim - sop);
      }

      if (nextLeft != null && this.nextLeft(graph, vom) == null) {
        setThread(vom, nextLeft);
        setModifier(vom, getModifier(vom) + sip - som);
        ancestor = node;
      }
    }

    return ancestor;
  }

  void setAncestor(Node? v, Node ancestor) {
    getNodeData(v)?.ancestor = ancestor;
  }

  void setModifier(Node? v, double modifier) {
    getNodeData(v)?.modifier = modifier;
  }

  void setThread(Node? v, Node thread) {
    getNodeData(v)?.thread = thread;
  }

  double getPrelim(Node? v) {
    return getNodeData(v)?.prelim ?? 0;
  }

  double getModifier(Node? vip) {
    return getNodeData(vip)?.modifier ?? 0;
  }

  void moveSubtree(Node? wm, Node wp, double shift) {
    var wpNodeData = getNodeData(wp)!;
    var wmNodeData = getNodeData(wm)!;
    var subtrees = wpNodeData.number - wmNodeData.number;
    wpNodeData.change = (wpNodeData.change - shift / subtrees);
    wpNodeData.shift = (wpNodeData.shift + shift);
    wmNodeData.change = (wmNodeData.change + shift / subtrees);
    wpNodeData.prelim = (wpNodeData.prelim + shift);
    wpNodeData.modifier = (wpNodeData.modifier + shift);
  }

  Node? ancestor(Graph graph, Node vim, Node node, Node defaultAncestor) {
    var vipNodeData = getNodeData(vim)!;
    return predecessorsOf(vipNodeData.ancestor).first ==
            predecessorsOf(node).first
        ? vipNodeData.ancestor
        : defaultAncestor;
  }

  Node? nextRight(Graph graph, Node? node) {
    return graph.hasSuccessor(node)
        ? getRightMostChild(graph, node)
        : getNodeData(node)?.thread;
  }

  Node? nextLeft(Graph graph, Node? node) {
    return hasSuccessor(node)
        ? getLeftMostChild(graph, node)
        : getNodeData(node)?.thread;
  }

  num getSpacing(Graph graph, Node? leftNode, Node rightNode) {
    var separation = configuration.getSubtreeSeparation();
    if (isSibling(graph, leftNode, rightNode)) {
      separation = configuration.getSiblingSeparation();
    }

    num length = isVertical() ? leftNode!.width : leftNode!.height;

    return separation + length;
  }

  bool isSibling(Graph graph, Node? leftNode, Node rightNode) {
    var leftParent = predecessorsOf(leftNode).first;
    return successorsOf(leftParent).contains(rightNode);
  }

  bool isLeaf(Graph graph, Node node) {
    return successorsOf(node).isEmpty;
  }

  Node? getLeftSibling(Graph graph, Node node) {
    if (!hasLeftSibling(graph, node)) {
      return null;
    } else {
      var parent = predecessorsOf(node).first;
      var children = successorsOf(parent);
      var nodeIndex = children.indexOf(node);
      return children[nodeIndex - 1];
    }
  }

  bool hasLeftSibling(Graph graph, Node node) {
    var parents = predecessorsOf(node);
    if (parents.isEmpty) {
      return false;
    } else {
      var parent = parents.first;
      var nodeIndex = successorsOf(parent).indexOf(node);
      return nodeIndex > 0;
    }
  }

  Node? getRightSibling(Graph graph, Node node) {
    if (!hasRightSibling(graph, node)) {
      return null;
    } else {
      var parent = predecessorsOf(node).first;
      var children = successorsOf(parent);
      var nodeIndex = children.indexOf(node);
      return children[nodeIndex + 1];
    }
  }

  bool hasRightSibling(Graph graph, Node node) {
    var parents = predecessorsOf(node);
    if (parents.isEmpty) {
      return false;
    } else {
      var parent = parents[0];
      List children = successorsOf(parent);
      var nodeIndex = children.indexOf(node);
      return nodeIndex < children.length - 1;
    }
  }

  Node getLeftMostChild(Graph graph, Node? node) {
    return successorsOf(node).first;
  }

  Node? getRightMostChild(Graph graph, Node? node) {
    var children = successorsOf(node);
    return children.isEmpty ? null : children.last;
  }

  void positionNodes(Graph graph) {
    var doesNeedReverseOrder = needReverseOrder();

    var offset = getOffset(graph, doesNeedReverseOrder);
    var nodes = sortByLevel(graph, doesNeedReverseOrder);
    var firstLevel = getNodeData(nodes.first)?.depth ?? 0;
    var currentLevel = doesNeedReverseOrder ? firstLevel : 0;

    var globalPadding = 0.0;
    var localPadding = 0.0;
    nodes.forEach((node) {
      if (node is! GenerationNode) {
        throw Exception(
            'You somehow manage to create an edge with a node that is not a GenerationNode');
      }

      final depth = getNodeData(node)?.depth ?? 0;
      if (depth != currentLevel) {
        if (doesNeedReverseOrder) {
          globalPadding -= localPadding;
        } else {
          globalPadding += localPadding;
        }
        localPadding = 0.0;
        currentLevel = depth;
      }

      final height = node.height;
      switch (configuration.orientation) {
        case BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM:
          if (height > minNodeHeight) {
            final diff = height - minNodeHeight;
            localPadding = max(localPadding, diff);
          }
          break;
      }

      final newNodePosition = getPosition(node, globalPadding, offset);
      _setNewNodePosition(node, newNodePosition);
    });
  }

  Offset getOffset(Graph graph, bool needReverseOrder) {
    var offsetX = double.infinity;
    var offsetY = double.infinity;

    if (needReverseOrder) {
      offsetY = double.minPositive;
    }

    graph.generations.forEach((node) {
      if (needReverseOrder) {
        offsetX = min(offsetX, node.x);
        offsetY = max(offsetY, node.y);
      } else {
        offsetX = min(offsetX, node.x);
        offsetY = min(offsetY, node.y);
      }
    });

    return Offset(offsetX, offsetY);
  }

  Offset getPosition(Node node, double globalPadding, Offset offset) {
    Offset finalOffset;
    switch (configuration.orientation) {
      case 1:
        finalOffset = Offset(node.x - offset.dx, node.y + globalPadding);
        break;
      case 2:
        finalOffset =
            Offset(node.x - offset.dx, offset.dy - node.y - globalPadding);
        break;
      case 3:
        finalOffset = Offset(node.y + globalPadding, node.x - offset.dx);
        break;
      case 4:
        finalOffset =
            Offset(offset.dy - node.y - globalPadding, node.x - offset.dx);
        break;
      default:
        finalOffset = Offset(0, 0);
        break;
    }

    return finalOffset;
  }

  List<Node> sortByLevel(Graph graph, bool descending) {
    var nodes = <Node>[...graph.generations];
    if (descending) {
      nodes.reversed;
    }
    nodes.sort((data1, data2) => compare(
        getNodeData(data1)?.depth ?? 0, getNodeData(data2)?.depth ?? 0));

    return nodes;
  }

  List<Node> filterByLevel(List<Node> nodes, int? level) {
    return nodes.where((node) => getNodeData(node)?.depth == level).toList();
  }

  void initData(Graph graph) {
    HouseholdNode.householdSeparation =
        configuration.houseHoldSeparation.toDouble();
    GenerationNode.siblingSeparation =
        configuration.siblingSeparation.toDouble();

    graph.generations.forEach((generation) {
      var nodeDatab = BuchheimWalkerNodeData();
      nodeDatab.ancestor = generation;

      nodeData[generation] = nodeDatab;

      setNodesSize(generation);
    });

    graph.edges.forEach((edge) {
      nodeData[edge.ancestors]?.successorNodes.add(edge.descendants);
      nodeData[edge.descendants]?.predecessorNodes.add(edge.ancestors);
    });
  }

  void setNodesSize(GenerationNode generation) {
    for (final node in generation.nodes) {
      if (node is HouseholdNode) {
        node.husband.size = nodeSize;
        node.wife.size = nodeSize;
      } else {
        node.size = nodeSize;
      }
    }
  }

  BuchheimWalkerNodeData? getNodeData(Node? node) {
    return node == null ? null : nodeData[node];
  }

  bool hasSuccessor(Node? node) => successorsOf(node).isNotEmpty;

  bool hasPredecessor(Node node) => predecessorsOf(node).isNotEmpty;

  List<Node> successorsOf(Node? node) {
    return (nodeData[node]?.successorNodes ?? []).toSet().toList();
  }

  List<Node> predecessorsOf(Node? node) {
    return nodeData[node]?.predecessorNodes ?? [];
  }

  BuchheimWalkerAlgorithm(
    this.configuration,
    this.nodeSize,
    EdgeRenderer? renderer,
  ) {
    _edgeRenderer = renderer ?? TreeEdgeRenderer(configuration);
  }

  @override
  void setFocusedNode(Node node) {}

  @override
  void init(Graph? graph) {
    // TODO remove this, not used
  }

  @override
  void step(Graph? graph) {
    var firstNode = graph!.getFirstNode();
    firstWalk(graph, firstNode, 0, 0);
    secondWalk(graph, firstNode, 0.0);
    checkUnconnectedNotes(graph);
    positionNodes(graph);
  }

  @override
  void setDimensions(double width, double height) {
    // graphWidth = width;
    // graphHeight = height;
  }

  @override
  EdgeRenderer get renderer => _edgeRenderer;

  void _setNewNodePosition(GenerationNode node, Offset newNodePosition) {
    node.position = newNodePosition;

    for (final innerNode in node.nodes) {
      newNodePosition = _setNewInnerNodesPosition(innerNode, newNodePosition);
    }
  }

  Offset _setNewInnerNodesPosition(Node node, Offset newNodePosition) {
    node.position = newNodePosition;

    if (node is HouseholdNode) {
      // updating internal nodes for household node
      node.husband.position = newNodePosition;

      newNodePosition = Offset(
          newNodePosition.dx +
              configuration.houseHoldSeparation +
              node.husband.width,
          newNodePosition.dy);
      node.wife.position = newNodePosition;

      return Offset(
        node.wife.x + node.wife.width + configuration.siblingSeparation,
        node.wife.y,
      );
    }

    return Offset(
      newNodePosition.dx + node.width + configuration.siblingSeparation,
      newNodePosition.dy,
    );
  }
}
