import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphview/GraphView.dart';

class HouseholdView extends StatelessWidget {
  const HouseholdView(
      {required this.husband,
      required this.wife,
      required this.builder,
      required this.edgePaint,
      required this.graph,
      required this.algorithm,
      required this.houseHoldSeparation,
      Key? key})
      : super(key: key);

  final Widget Function(Node node) builder;
  final Node husband;
  final Node wife;
  final Graph graph;
  final Paint edgePaint;
  final Algorithm algorithm;
  final double houseHoldSeparation;

  @override
  Widget build(BuildContext context) {
    return _HouseholdView(
      husband: husband,
      wife: wife,
      graph: graph,
      edgePaint: edgePaint,
      algorithm: algorithm,
      houseHoldSeparation: houseHoldSeparation,
      children: [
        builder(husband),
        builder(wife),
      ],
    );
  }
}

class _HouseholdView extends MultiChildRenderObjectWidget {
  final Node husband;
  final Node wife;
  final Graph graph;
  final Paint edgePaint;
  final Algorithm algorithm;
  final double houseHoldSeparation;

  const _HouseholdView({
    Key? key,
    required this.graph,
    required this.edgePaint,
    required this.algorithm,
    required this.husband,
    required this.wife,
    required this.houseHoldSeparation,
    required List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHouseHold(
      graph: graph,
      algorithm: algorithm,
      edgePaint: edgePaint,
      husband: husband,
      wife: wife,
      houseHoldSeparation: houseHoldSeparation,
    );
  }
}

class _RenderHouseHold extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, NodeBoxData>,
        RenderBoxContainerDefaultsMixin<RenderBox, NodeBoxData> {
  final Node husband;
  final Node wife;
  final Graph graph;
  final Algorithm algorithm;
  final Paint edgePaint;
  final double houseHoldSeparation;

  _RenderHouseHold({
    required this.graph,
    required this.algorithm,
    required this.edgePaint,
    required this.husband,
    required this.wife,
    required this.houseHoldSeparation,
  });

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! NodeBoxData) {
      child.parentData = NodeBoxData();
    }
  }

  @override
  void performLayout() {
    if (childCount != 2) {
      size = constraints.biggest;
      assert(size.isFinite);
      return;
    }

    final looseConstraints = BoxConstraints.loose(constraints.biggest);

    final husbandRenderBox = firstChild;
    final husbandParentData = husbandRenderBox?.parentData as NodeBoxData;

    final wifeRenderBox = lastChild;
    final wifeParentData = wifeRenderBox?.parentData as NodeBoxData;

    if (husbandRenderBox == null || wifeRenderBox == null) {
      return;
    }

    husbandRenderBox.layout(looseConstraints, parentUsesSize: true);
    husband.size = husbandRenderBox.size;
    husbandParentData.offset = husband.position;

    wifeRenderBox.layout(looseConstraints, parentUsesSize: true);
    wife.size = wifeRenderBox.size;
    wifeParentData.offset = wife.position;

    size = Size(
        husbandRenderBox.size.width +
            wifeRenderBox.size.width +
            houseHoldSeparation,
        max(husband.size.height, wife.size.height));

    print(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    algorithm.renderer
        .renderHouseHoldEdge(context.canvas, husband, wife, edgePaint);

    context.canvas.restore();

    defaultPaint(context, offset);
  }
}
