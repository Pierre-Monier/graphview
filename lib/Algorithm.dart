part of graphview;

abstract class Algorithm {
  EdgeRenderer get renderer;

  Size get nodeSize;

  Size run(Graph graph);

  void setFocusedNode(Node node);

  void init(Graph? graph);

  void step(Graph? graph);

  void setDimensions(double width, double height);
}
