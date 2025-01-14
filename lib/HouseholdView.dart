import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class HouseholdView extends StatefulWidget {
  const HouseholdView(
      {required this.husband,
      required this.wife,
      required this.builder,
      required this.houseHoldSeparation,
      required this.renderer,
      required this.edgePaint,
      Key? key})
      : super(key: key);

  final Widget Function(Node node) builder;
  final Node husband;
  final Node wife;
  final double houseHoldSeparation;
  final EdgeRenderer renderer;
  final Paint edgePaint;

  @override
  State<HouseholdView> createState() => _HouseholdViewState();
}

class _HouseholdViewState extends State<HouseholdView> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HouseHoldPainter(
        husband: widget.husband,
        wife: widget.wife,
        houseHoldSeparation: widget.houseHoldSeparation,
        renderer: widget.renderer,
        edgePaint: widget.edgePaint,
      ),
      child: Row(
        children: [
          widget.builder(widget.husband),
          SizedBox(
            width: widget.houseHoldSeparation,
          ),
          widget.builder(widget.wife),
        ],
      ),
    );
  }
}

class _HouseHoldPainter extends CustomPainter {
  _HouseHoldPainter(
      {required this.husband,
      required this.wife,
      required this.houseHoldSeparation,
      required this.renderer,
      required this.edgePaint});

  final EdgeRenderer renderer;
  final double houseHoldSeparation;
  final Node husband;
  final Node wife;
  final Paint edgePaint;

  @override
  void paint(Canvas canvas, Size size) {
    renderer.renderHouseHoldEdge(canvas, size, edgePaint);
  }

  @override
  bool shouldRepaint(_HouseHoldPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_HouseHoldPainter oldDelegate) => true;
}
