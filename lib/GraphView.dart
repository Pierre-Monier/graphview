library graphview;

import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:graphview/GenerationView.dart';
import 'package:graphview/HouseholdView.dart';

part 'Graph.dart';

part 'Algorithm.dart';

part 'edgerenderer/EdgeRenderer.dart';

part 'tree/BuchheimWalkerAlgorithm.dart';

part 'tree/BuchheimWalkerConfiguration.dart';

part 'tree/BuchheimWalkerNodeData.dart';

part 'tree/TreeEdgeRenderer.dart';

typedef NodeWidgetBuilder = Widget Function(Node node);

class GraphView extends StatefulWidget {
  final Graph graph;
  final BuchheimWalkerConfiguration configuration;
  late final Algorithm algorithm;
  final Paint? paint;
  final NodeWidgetBuilder builder;
  final bool animated;

  GraphView(
      {Key? key,
      required this.graph,
      required this.configuration,
      this.paint,
      required this.builder,
      this.animated = true})
      : super(key: key) {
    algorithm =
        BuchheimWalkerAlgorithm(configuration, TreeEdgeRenderer(configuration));
  }

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  late final Size graphSize;
  @override
  void initState() {
    super.initState();
    graphSize = widget.algorithm.run(widget.graph, 10, 10);
  }

  @override
  Widget build(BuildContext context) {
    return _GraphView(
      key: widget.key,
      graph: widget.graph,
      algorithm: widget.algorithm,
      configuration: widget.configuration,
      paint: widget.paint ?? Paint()
        ..color = Colors.amber
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
      builder: widget.builder,
      graphSize: graphSize,
    );
  }
}

class _GraphView extends MultiChildRenderObjectWidget {
  final Graph graph;
  final BuchheimWalkerConfiguration configuration;
  final Algorithm algorithm;
  final Paint paint;
  final Size graphSize;

  _GraphView(
      {Key? key,
      required this.graph,
      required this.configuration,
      required this.algorithm,
      required this.paint,
      required this.graphSize,
      required NodeWidgetBuilder builder})
      : super(
            key: key,
            children: _extractChildren(
                graph,
                algorithm,
                builder,
                configuration.houseHoldSeparation.toDouble(),
                configuration.siblingSeparation.toDouble(),
                algorithm.renderer,
                paint)) {
    assert(() {
      if (children.isEmpty) {
        throw FlutterError(
          'Children must not be empty, ensure you are overriding the builder',
        );
      }

      return true;
    }());
  }

  // Traverses the nodes depth-first collects the list of child widgets that are created.
  static List<Widget> _extractChildren(
      Graph graph,
      Algorithm algorithm,
      NodeWidgetBuilder builder,
      double houseHoldSeparation,
      double siblingSeparation,
      EdgeRenderer renderer,
      Paint edgePaint) {
    final result = <Widget>[];

    graph.generations.forEach((generation) {
      result.add(GenerationView(
        nodes: generation.nodes,
        builder: builder,
        graph: graph,
        algorithm: algorithm,
        houseHoldSeparation: houseHoldSeparation,
        siblingSeparation: siblingSeparation,
        renderer: renderer,
        edgePaint: edgePaint,
      ));
    });

    return result;
  }

  @override
  RenderCustomLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomLayoutBox(graphSize, graph, algorithm, paint);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomLayoutBox renderObject) {
    renderObject
      ..graph = graph
      ..algorithm = algorithm
      ..edgePaint = paint;
  }
}

class RenderCustomLayoutBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, NodeBoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, NodeBoxData> {
  late Graph _graph;
  late Algorithm _algorithm;
  late Paint _paint;
  final Size graphSize;

  RenderCustomLayoutBox(
    this.graphSize,
    Graph graph,
    Algorithm algorithm,
    Paint? paint, {
    List<RenderBox>? children,
  }) {
    _algorithm = algorithm;
    _graph = graph;
    edgePaint = paint;
    addAll(children);
  }

  Paint get edgePaint => _paint;

  set edgePaint(Paint? value) {
    _paint = value ??
        (Paint()
          ..color = Colors.amber
          ..strokeWidth = 3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    markNeedsPaint();
  }

  Graph get graph => _graph;

  set graph(Graph value) {
    _graph = value;
    markNeedsLayout();
  }

  Algorithm get algorithm => _algorithm;

  set algorithm(Algorithm value) {
    _algorithm = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! NodeBoxData) {
      child.parentData = NodeBoxData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.biggest;
      assert(size.isFinite);
      return;
    }

    var child = firstChild;
    var position = 0;
    var looseConstraints = BoxConstraints.loose(constraints.biggest);
    while (child != null) {
      final nodeBox = child.parentData as NodeBoxData;

      child.layout(looseConstraints, parentUsesSize: true);
      final node = graph.getNodeAtPosition(position);
      node.size = child.size;

      child = nodeBox.nextSibling;
      position++;
    }

    size = graphSize;

    child = firstChild;
    position = 0;
    while (child != null) {
      final node = child.parentData as NodeBoxData;

      node.offset = graph.getNodeAtPosition(position).position;

      child = node.nextSibling;
      position++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    algorithm.renderer.render(context.canvas, graph, edgePaint);

    context.canvas.restore();

    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Graph>('graph', graph));
    properties.add(DiagnosticsProperty<Algorithm>('algorithm', algorithm));
    properties.add(DiagnosticsProperty<Paint>('paint', edgePaint));
  }
}

class NodeBoxData extends ContainerBoxParentData<RenderBox> {}
