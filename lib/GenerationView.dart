import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphview/GraphView.dart';
import 'package:graphview/HouseholdView.dart';

class GenerationView extends StatelessWidget {
  const GenerationView(
      {required this.generation,
      required this.builder,
      required this.graph,
      required this.algorithm,
      required this.houseHoldSeparation,
      required this.siblingSeparation,
      required this.renderer,
      required this.edgePaint,
      Key? key})
      : super(key: key);

  final GenerationNode generation;
  final Graph graph;
  final Algorithm algorithm;
  final NodeWidgetBuilder builder;
  final double houseHoldSeparation;
  final double siblingSeparation;
  final EdgeRenderer renderer;
  final Paint edgePaint;

  @override
  Widget build(BuildContext context) {
    return _GenerationView(
      generation: generation,
      builder: (node) {
        return SizedBox(
            width: algorithm.nodeSize.width,
            height: algorithm.nodeSize.height,
            child: builder(node));
      },
      graph: graph,
      algorithm: algorithm,
      edgePaint: edgePaint,
      houseHoldSeparation: houseHoldSeparation,
      siblingSeparation: siblingSeparation,
    );
  }
}

class _GenerationView extends MultiChildRenderObjectWidget {
  final Graph graph;
  final GenerationNode generation;
  final double siblingSeparation;
  _GenerationView(
      {required this.generation,
      required this.siblingSeparation,
      required NodeWidgetBuilder builder,
      required this.graph,
      required Algorithm algorithm,
      required Paint edgePaint,
      required double houseHoldSeparation,
      Key? key})
      : super(
          key: key,
          children: generation.nodes
              .map((node) => node is HouseholdNode
                  ? HouseholdView(
                      husband: node.husband,
                      wife: node.wife,
                      builder: builder,
                      graph: graph,
                      algorithm: algorithm,
                      edgePaint: edgePaint,
                      houseHoldSeparation: houseHoldSeparation,
                    )
                  : builder(node))
              .toList(),
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGeneration(
        graph: graph,
        generation: generation,
        siblingSeparation: siblingSeparation);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderGeneration renderObject) {
    renderObject
      ..graph = graph
      ..generation = generation
      ..siblingSeparation = siblingSeparation;
  }
}

class _RenderGeneration extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, NodeBoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, NodeBoxData> {
  Graph _graph;
  set graph(Graph value) {
    if (_graph == value) {
      return;
    }
    _graph = value;
    markNeedsLayout();
  }

  GenerationNode _generation;
  set generation(GenerationNode value) {
    if (_generation == value) {
      return;
    }
    _generation = value;
    markNeedsLayout();
  }

  double _siblingSeparation;
  set siblingSeparation(double value) {
    if (_siblingSeparation == value) {
      return;
    }
    _siblingSeparation = value;
    markNeedsLayout();
  }

  _RenderGeneration(
      {required Graph graph,
      required GenerationNode generation,
      required double siblingSeparation})
      : _siblingSeparation = siblingSeparation,
        _generation = generation,
        _graph = graph;

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

    final looseConstraints = BoxConstraints.loose(constraints.biggest);
    var childRenderBox = firstChild;
    var i = 0;
    var finalSize = Size.zero;

    while (childRenderBox != null) {
      final node = _generation.nodes[i];
      final childParentData = childRenderBox.parentData as NodeBoxData;

      childRenderBox.layout(looseConstraints, parentUsesSize: true);
      // node.size = childRenderBox.size;
      // Setting the y offset to 0 because the y offset is already set by
      // the GraphView parent.
      childParentData.offset = Offset(node.x - _generation.x, 0);

      i++;
      childRenderBox = childParentData.nextSibling;
      finalSize = Size(finalSize.width + node.size.width,
          max(node.size.height, finalSize.height));
    }

    size = Size(
        finalSize.width + ((i - 1) * _siblingSeparation), finalSize.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
