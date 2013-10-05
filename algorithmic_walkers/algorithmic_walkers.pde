  
  //import libraries
  import unlekker.util.*;
  import unlekker.modelbuilder.*;
  import unlekker.modelbuilder.filter.*;
  import ec.util.*;
  
  //ALL UNITS IN INCHES
  
  //globalVariables
  int fileIter = 0;//filename number
  
  //geometric parameters
  int resolution = 64;//increase this to increase the density of the mesh, must be divisible by 4
  //float legSpacing = 5;//space between the legs
  float legWidth = 0.5;//width of leg
  int numLegs = 3;
  float spacing = 0.01;
  float innerRad = 0.05;
  float outerRad = 0.08;
  float hingeWidth = 0.08;
  float jointRad = innerRad-spacing;
  float jointBevelRad = outerRad;
  float jointBevelWidth = 0.01;
  float jointWidth = hingeWidth+2*spacing;
  float linkCrossbeamSpacing = 0.1;
  float legSpacing = jointBevelWidth;//extra spacing between legs in a leg group
  
  //LEG PARAMETERS
  //which vertices are connected to each other
  byte[][] vertexPairs = {//{index of vertex1, index of vertex2, 
    {0,1},
    {0,3},
    {1,2},
    {1,4},
    {2,4},
    {2,5},
    {5,4},
    {5,6},
    {6,3},
    {3,2}
  };
  
  //length of each link in mechanism
  int[] linkageLengths = {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  };
  
  byte crankVertIndex = 0;
  byte footVertIndex = 6;
  byte fixedHingeIndex = 2;
  byte numVertices = 7;
  
  LegCalculator calculator = new LegCalculator();

void setup(){
  
  UGeometry globalGeo = new UGeometry();
  
//  LinkHinge hinge = new LinkHinge(new PVector(0,0,0), 0);
//  globalGeo.add(hinge.getGeometry());
  
  
//  Link link1 = new Link(new PVector(0,0,0), new PVector(0,2,0), 0.5, 1, true, true);
//  globalGeo.add(link1.getGeometry());
//  
//  Link link2 = new Link(new PVector(0,0,0), new PVector(0,-2,0), 0.5, 2, true, true);
//  globalGeo.add(link2.getGeometry());
//  writeSTL(globalGeo);

//  JointSection joint2 = new JointSection(new UVertexList(), new PVector(-jointBevelWidth-jointWidth,0,0));
//  JointSection joint = new JointSection(joint2.getConnectingVertices(), new PVector(0,0,0));
//  globalGeo.add(joint.getGeometry());
  
//  Joint joint1 = new Joint(new PVector(0,0,0), 2, 0, 2);
//  Joint joint2 = new Joint(new PVector(0,2,0), 2, 0.5, 2);
//  Joint joint3 = new Joint(new PVector(0,-2,0), 2, 0.5, 2);
//  globalGeo.add(joint1.getGeometry());
//  globalGeo.add(joint2.getGeometry());
//  globalGeo.add(joint3.getGeometry());
  
//  LegGroup legGroup = new LegGroup(new PVector(0,0,0));
//  globalGeo.add(legGroup.getGeometry());
  
  //parameters for all legs
  byte[] numConnections = calculator.numConnections;//num connections at each vertex
  boolean[][] linkCrossbars = calculator.linkCrossbars;//should there be a crossbar on each linkage
  float[] hingeWidths = calculator.calculateHingeWidths();
  int[][] connectionPos = calculator.connectionPos;
  
  //unique to each leg
  float theta = 0;

  Leg leg = new Leg(new PVector(0,0,0), theta, numConnections, hingeWidths, linkCrossbars, connectionPos);
  globalGeo = leg.getGeometry();
  
  writeSTL(globalGeo);

  exit();
  
}

void writeSTL(UGeometry geo){
  //generate stl
  String filename = "walker" + str(fileIter) + "spacing" + str(spacing);
  geo.writeSTL(this, filename + ".stl");//write stl file from geomtery
  fileIter ++;
  geo.reset();
}
