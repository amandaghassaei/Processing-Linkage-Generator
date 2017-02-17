Processing-Linkage-Generator
===============

mechanical walking mechanisms designed in Processing, exported to STL for 3D Printing via ModelBuilder Library

<p>A very long time ago, I started writing an Instructable about generating a 3D printable linkage from processing.  Eventually that project grew in other directions and I abandoned all my Processing code.  I already wrote a lot about it and since it might be useful to someone, so I've included some explanation here. </p><p>The next several steps will describe the Processing sketch used to transform the information describing the geometry of a leg into a 3D printable model of the leg.  This is still very much a work in progress, but it is a nice example of how to use the <a href="https://github.com/mariuswatz/modelbuilder">Modelbuilder library</a>.</p>


##Class: LinkHinge##

<p>The first class I designed in this project is the class which deals with the geometry of something I'm calling a "LinkHinge", this is the end piece of a link that allows a link to rotate around a joint.  As you can see in the images above, the LinkHinge has a rounded edge with a hole, and a square end that connects to the rest or the link.  The dimensions of each feature on the LinkHinge is specified by the variables:</p><p><strong>  float innerRad = 0.05;<br>
  float outerRad = 0.08;<br>
  float hingeWidth = 0.08;</strong></p><p>whose units are in inches.  The number of points defined around the circular portion of the LinkHinge is given by the following variable:</p><p>  <strong> int resolution = 64;</strong></p><p>This number may be increased to increase the density of points on the mesh, making the rounded features less faceted, or it may be decreased to decrease the overall size of the resulting STL file.  This number must always be divisible by four.</p>
<pre>//LinkHinge class

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
*/

class LinkHinge {

  ArrayList<UVertexList> vlists;//storage for vertices
  float hingeAngle;//angle of rotation of hinge

  LinkHinge(PVector hingePos, float _hingeAngle){

    vlists = new ArrayList<UVertexList>();//data for hinge geometry is stored in 16 vertex lists
    for (int i=0;i&lt;16;i++){
      vlists.add(new UVertexList());
    }
    hingeAngle = _hingeAngle;//angle of hinge in yz plane
    calculateGeometry(hingePos);
  }</pre><p>
The LinkHinge class is initialized with an <a href="http://processing.org/reference/ArrayList.html">ArrayList</a> of 16 <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UVertexList.html">UVertexList</a>s, these lists will store all the vertices of the LinkHinge, and will be used to create the geometry of the part.  Two parameters are passed in when an instance of the class is created, "hingePos" and "hingeAngle".  hingePos is a 3 dimensional coordinate (<a href="http://processing.org/reference/PVector.html">PVector</a>) which sets the position of the hinge in space.  hingeAngle is the angle of rotation of the hinge in the yz plane (the direction of the hole cutout in the hinge is always perpendicular to the yz plane, all joints run parallel to the x axis).</p>
In all of the classes that deal directly with generating the geometry of the STL, I've broken up calculating the vertices and creating the geometry of the shape from the vertices into two functions: "calculateGeometry" and "getGeometry".  In calculateGeomerty, the vertices are calculated for two distinct sections of the LinkHinge, the outer curved portion (figs 1 and 2) and the square portion that attaches to the rest of the link (figs 3 and 4).<br>
<pre>
  void calculateGeometry(PVector hingePos){

    //draw outer curved portion
    for (int i=resolution/4;i&lt;=(3*resolution/4);i++){
      float theta = i*TWO_PI/resolution + hingeAngle;
      vlists.get(0).add(hingePos.x, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(1).add(hingePos.x, hingePos.y + outerRad*sin(theta), hingePos.z + outerRad*cos(theta));
      vlists.get(2).add(hingePos.x + hingeWidth, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(3).add(hingePos.x + hingeWidth, hingePos.y + outerRad*sin(theta), hingePos.z + outerRad*cos(theta));
    }

    //draw square inner part
    for (int i=0;i&lt;=resolution/4;i++){
      float theta = i*TWO_PI/resolution + hingeAngle;
      vlists.get(4).add(hingePos.x, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(6).add(hingePos.x + hingeWidth, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
    }
    for (int i=3*resolution/4;i&lt;=resolution;i++){
      float theta = i*TWO_PI/resolution + hingeAngle;
      vlists.get(5).add(hingePos.x, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(7).add(hingePos.x + hingeWidth, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
    }

    float squareRad = outerRad*sqrt(2);
    vlists.get(12).add(vlists.get(4));
    vlists.get(13).add(vlists.get(5));
    vlists.get(14).add(vlists.get(6));
    vlists.get(15).add(vlists.get(7));
    vlists.get(12).add(0,0,0);
    vlists.get(13).add(0,0,0);
    vlists.get(14).add(0,0,0);
    vlists.get(15).add(0,0,0);
    vlists.get(12).addAtStart(hingePos.x, hingePos.y + squareRad*sin(hingeAngle+PI/4), hingePos.z + squareRad*cos(hingeAngle+PI/4));
    vlists.get(13).addAtStart(hingePos.x, hingePos.y + squareRad*sin(hingeAngle-PI/4), hingePos.z + squareRad*cos(hingeAngle-PI/4));
    vlists.get(14).addAtStart(hingePos.x + hingeWidth, hingePos.y + squareRad*sin(hingeAngle+PI/4), hingePos.z + squareRad*cos(hingeAngle+PI/4));
    vlists.get(15).addAtStart(hingePos.x + hingeWidth, hingePos.y + squareRad*sin(hingeAngle-PI/4), hingePos.z + squareRad*cos(hingeAngle-PI/4));

    vlists.get(8).add(vlists.get(1).first());
    vlists.get(8).add(vlists.get(12).first());
    vlists.get(9).add(vlists.get(3).first());
    vlists.get(9).add(vlists.get(14).first());
    vlists.get(10).add(vlists.get(1).last());
    vlists.get(10).add(vlists.get(13).first());
    vlists.get(11).add(vlists.get(3).last());
    vlists.get(11).add(vlists.get(15).first());
  }
</pre>
<br>
When calculating the geometry, I'm creating a list of triangles and storing them in an instance of <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UGeometry.html">UGeometry</a>.  These triangles are adjacent to each other and will eventually form a watertight mesh when they are joined with the rest of the model.  The triangles are arranged differently in different sections of the hinge, you can see exactly how the triangles are arranged across the LinkHinge in figs 5 and 6.  I used a combination of the <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UGeometry.html#quadStrip%28unlekker.modelbuilder.UVertexList,%20unlekker.modelbuilder.UVertexList%29">quadStrip()</a> and <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UGeometry.html#triangleFan%28unlekker.modelbuilder.UVertexList,%20boolean%29">triangleFan()</a> functions from the modelbuilder library to build these triangles<br>
<pre>
  UGeometry getGeometry(){

    UGeometry geo = new UGeometry();

    //round edges
    geo.quadStrip(vlists.get(1),vlists.get(0));
    geo.quadStrip(vlists.get(3),vlists.get(1));
    geo.quadStrip(vlists.get(2),vlists.get(3));
    geo.quadStrip(vlists.get(0),vlists.get(2));
    geo.quadStrip(vlists.get(4),vlists.get(6));
    geo.quadStrip(vlists.get(5),vlists.get(7));

    //square edges
    geo.triangleFan(vlists.get(12), false, false);
    geo.triangleFan(vlists.get(13), false, false);
    geo.triangleFan(vlists.get(14), false, true);
    geo.triangleFan(vlists.get(15), false, true);

    //close the last triangles
    geo.add(new UFace(vlists.get(13).first(), vlists.get(12).first(), vlists.get(5).last()));
    geo.add(new UFace(vlists.get(14).first(), vlists.get(15).first(), vlists.get(7).last()));
    geo.add(new UFace(vlists.get(1).first(), vlists.get(0).first(), vlists.get(12).first()));
    geo.add(new UFace(vlists.get(0).last(), vlists.get(1).last(), vlists.get(13).first()));
    geo.add(new UFace(vlists.get(2).first(), vlists.get(3).first(), vlists.get(14).first()));
    geo.add(new UFace(vlists.get(3).last(), vlists.get(2).last(), vlists.get(15).first()));

    geo.quadStrip(vlists.get(8),vlists.get(9));
    geo.quadStrip(vlists.get(11),vlists.get(10));

    return geo;
  }
</pre>
<br>
The next functions in this class return an ArrayList containing the vertices that attach to the open end of the LinkHinge.  This ArrayList is passed into the Link class (I'll describe this class in more detail in the next step) so that the LinkHinge's can be connected to the rest of the model.  The parameters inverse and opposite dictate the order that the vertices are arranged in the ArrayList, based on the orientation of the LinkHinge with respect to the Link to which it is attached.<br>
<pre>
  ArrayList getConnectingVertices(boolean inverse, boolean opposite){

    ArrayList<UVertexList> connectingLists = new ArrayList<UVertexList>();

    UVertexList connections = new UVertexList();
    if (inverse){//need to invert the order of one side
      connections.add(vlists.get(13).first());
      connections.add(vlists.get(15).first());
      connections.add(vlists.get(14).first());
      connections.add(vlists.get(12).first());
    } else {
      connections.add(vlists.get(12).first());
      connections.add(vlists.get(14).first());
      connections.add(vlists.get(15).first());
      connections.add(vlists.get(13).first());
    }
    connections.close();
    connectingLists.add(connections);

    connectingLists.add(getSecondaryConnections(connections, linkCrossbeamSpacing));
    connectingLists.add(getSecondaryConnections(connections, linkCrossbeamSpacing + hingeWidth));

    connectingLists.add(reworkArray(connectingLists.get(1), opposite));
    connectingLists.add(reworkArray(connectingLists.get(2), opposite));
    connectingLists.add(reworkArrays(connectingLists.get(3), connectingLists.get(4), opposite));

    return connectingLists;
  }

  UVertexList getSecondaryConnections(UVertexList connections, float distance){

    UVertexList secondaryConnections = new UVertexList();
    int i = 0;
    for (UVec3 vert : connections.v){
      if (i &lt; connections.n){
        secondaryConnections.add(vert.x,vert.y+distance*sin(hingeAngle),vert.z+distance*cos(hingeAngle));
      }
    i++;
    }
    return secondaryConnections;
  }

  UVertexList reworkArray(UVertexList connections, boolean opposite){

    UVec3[] vertices = connections.getVertices();
    UVertexList secondaryConnections = new UVertexList();

    if (opposite){
      secondaryConnections.add(vertices[2]);
      secondaryConnections.add(vertices[3]);
      secondaryConnections.add(vertices[0]);
      secondaryConnections.add(vertices[1]);
    } else{
      for(int i=0;i&lt;4;i++){
        secondaryConnections.add(vertices[i]);
      }
    }

    return secondaryConnections;
  }

  UVertexList reworkArrays(UVertexList connections1, UVertexList connections2, boolean opposite){

    UVertexList secondaryConnections = new UVertexList();

    if (opposite){
       secondaryConnections.add(connections1.first());
       secondaryConnections.add(connections1.last());
       secondaryConnections.add(connections2.last());
       secondaryConnections.add(connections2.first());
    } else{
       secondaryConnections.add(connections1.last());
       secondaryConnections.add(connections1.first());
       secondaryConnections.add(connections2.first());
       secondaryConnections.add(connections2.last());
    }
    secondaryConnections.close();

    return secondaryConnections;
  }
}</pre>


##Class: Link##

<p>The Link class creates and stores a list of four LinkHinge objects and connects them to each other to form a complete, watertight mesh from specified starting an ending points.  The class receives the following parameters when it is initialized:</p><p><strong>   the <a href="http://processing.org/reference/PVector.html">PVectors</a> (positions) of its endpoints<br>
   the width of its endpoints<br>
   whether it should draw a crossbar at each end </strong>(fig 1, 3, 4 show varying combinations of crossbar possibilities, the cross beams are there to provide extra support to the linkage, but can be easily removed if they inhibit movement)</p>
Each Link determines its angle of rotation based on the position of its endpoints and passes this information (along with position information) down to four LinkHinges.  The ArrayList "connectors" contains the VertexLists returned by the LinkHinge class's   getConnectingVertices() method, these are the lists of vertices that form the open square end of each LinkHinge.  the Link uses the information stored in "connectors" to generate the geometry between the four LinkHinges.<br>
<pre>
//Link class

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
*/

class Link {

  ArrayList<LinkHinge> hinges;//storage for 4 LinkHinges
  ArrayList<ArrayList> connectors;//lists of vertices to create connections between LinkHinges and crossbars
  boolean[] crossbars = new boolean[2];//boolean values tell us if we need to draw crossbars

  Link (PVector end1, PVector end2, float width1, float width2, boolean crossbar1, boolean crossbar2){

    hinges = new ArrayList<LinkHinge>();//initialize arrayLists
    connectors = new ArrayList<ArrayList>();

    crossbars[0] = crossbar1;
    crossbars[1] = crossbar2;

    float theta = calculateTheta(end1,end2);//angle of linkage

    calculate endpoint positions
    PVector endA = end1.get();
    PVector endB = end2.get();
    PVector endC = end1.get();
    PVector endD = end2.get();

    endA.x -= width1/2;
    endC.x += width1/2 - hingeWidth;
    endB.x -= width2/2;
    endD.x += width2/2 - hingeWidth;

    create four LinkHinges
    addHinges(endA,endB,theta);
    addHinges(endC,endD,theta);

    calculateGeometry();
  }

  void calculateGeometry(){

    get connecting vertices from hinges
    connectors.add(hinges.get(0).getConnectingVertices(true, true));
    connectors.add(hinges.get(1).getConnectingVertices(false, true));
    connectors.add(hinges.get(2).getConnectingVertices(true, false));
    connectors.add(hinges.get(3).getConnectingVertices(false, false));
  }

  void addHinges(PVector end1, PVector end2, float theta){

    hinges.add(new LinkHinge(end1,-(theta+PI/2)));
    hinges.add(new LinkHinge(end2,-(theta-PI/2)));
  }

  float calculateTheta(PVector end1, PVector end2){

    //calculate angle between the ends
    float diffY = end1.y - end2.y;
    float diffZ = end1.z - end2.z;
    return atan2(diffZ, diffY);
  }
</pre><p>
As with the last class, this class is split into two main functions, calculcateGeometry() and getGeometry().  In getGeometry() the geometry of the Link is stored in a <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UGeometry.html">UGeometry</a> object in several sections.  First the Link asks each of its four LinkHinge objects to calculate their geometry (again with getGeometry()), and adds the UGeometry object returned from each of the LinkHinges to its own UGeometry object.</p><p>Next the Link draws the connections between each of the LinkHinges using the same <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UGeometry.html#quadStrip%28unlekker.modelbuilder.UVertexList,%20unlekker.modelbuilder.UVertexList%29">quadStrip()</a> method used in the last class.  Then the Link class either creates a crossbar between two LinkHinges on each end, or closes the remaining open holes in its geometry (where the crossbars would have attached).  The distance between the base of a LinkHinge and its nearest crossbar connection is specified by the variable:</p><p>   <strong>float linkCrossbeamSpacing = 0.1;</strong></p>
You can see the triangular geometry of the LinkHinges and the Link in figs 5 and 6, you can clearly see the discrete LinkHinges (descirbed in the last step) attached to the ends of the Link.<br>
<pre>
  UGeometry getGeometry(){

    //draw hinges
    UGeometry geo = new UGeometry();
    for (LinkHinge hinge : hinges){
      geo.add(hinge.getGeometry());
    }
    hinges = null;//remove from memory


    //draw connections bewtween hinges
    geo.quadStrip((UVertexList)connectors.get(0).get(0), (UVertexList)connectors.get(0).get(1));
    geo.quadStrip((UVertexList)connectors.get(1).get(1), (UVertexList)connectors.get(1).get(0));
    geo.quadStrip((UVertexList)connectors.get(2).get(0), (UVertexList)connectors.get(2).get(1));
    geo.quadStrip((UVertexList)connectors.get(3).get(1), (UVertexList)connectors.get(3).get(0));

    geo.quadStrip((UVertexList)connectors.get(0).get(2), (UVertexList)connectors.get(1).get(2));
    geo.quadStrip((UVertexList)connectors.get(2).get(2), (UVertexList)connectors.get(3).get(2));

    geo.quadStrip((UVertexList)connectors.get(0).get(3), (UVertexList)connectors.get(0).get(4));
    geo.quadStrip((UVertexList)connectors.get(1).get(4), (UVertexList)connectors.get(1).get(3));
    geo.quadStrip((UVertexList)connectors.get(2).get(3), (UVertexList)connectors.get(2).get(4));
    geo.quadStrip((UVertexList)connectors.get(3).get(4), (UVertexList)connectors.get(3).get(3));

   //draw crossbars or close holes
    if (crossbars[0]){
      geo.quadStrip((UVertexList)connectors.get(2).get(5), (UVertexList)connectors.get(0).get(5));
    } else {
      geo.triangleFan((UVertexList)connectors.get(2).get(5), true, true);
      geo.triangleFan((UVertexList)connectors.get(0).get(5), true, false);
    }
    if (crossbars[1]){
      geo.quadStrip((UVertexList)connectors.get(1).get(5), (UVertexList)connectors.get(3).get(5));
    } else {
      geo.triangleFan((UVertexList)connectors.get(1).get(5), true, true);
      geo.triangleFan((UVertexList)connectors.get(3).get(5), true, false);
    }

    return geo;
  }
}
</pre>


##Class: JointSection##

<p>I'm calling the parts that the Links rotate around the "Joints".  Each Joint is made up of many unit pieces called "JointSections".  A JointSection provides the place for a Link to connect.  The geometry of one JointSection is given in figs 1 and 2, and its connection with a Link is shown in figs 5 and 6.</p><p>Through some experimentation, I've found that a good amount of spacing between moving elements in an assembly is 0.01".  This is enough space for the 3D printer to print them as two separate, freely moving objects without leaving too much play in the connection:</p><p><strong>  float spacing = 0.01;</strong></p><p>The inner and outer radii of the JointSection (called jointRad and jointBevelRad respectively), are defined as:</p><p><strong>  float jointRad = innerRad-spacing;<br>
  float jointBevelRad = outerRad;</strong></p><p>Remember, the innerRad and outerRad variables were used to set the dimensions on the LinkHinge.  This way, there is 0.01" difference between the radius of the LinkHinge hole and the JointSection that fits inside it.  The width of each of the wider regions on the Joint (the jointBevel), is given by the following:</p><p><strong>  float jointBevelWidth = 0.01;</strong></p><p>The next variable was created out of convenience, it defines the width of the region with radius = jointRad, the skinner section of each JointSection.  This variable ensures that there is always 0.01" spacing between the sides of each LinkHinge and the nearest jointBevel.</p><p><strong>  float jointWidth = hingeWidth+2*spacing;</strong></p>
Each JointSection is initialized with a list of vertices that it should connect to, and a position PVector.  The JointSections will always line up along the x-axis and they have radial symmetry, so we don't need to think about their rotational position.  In initialization, the JointSection calculates an ArrayList of five UVertexLists that it will eventually link together in the getGeometry() function.<br>
<pre>
//JointSection class

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
*/

class JointSection{

  ArrayList<UVertexList> vlists;//storage

  JointSection(UVertexList connectingList, PVector location){

    vlists = new ArrayList<UVertexList>();
    vlists.add(connectingList);
    calculateGeometry(location);
  }

  void calculateGeometry(PVector location){

    float xOffset = 0;
    for (int i=0;i&lt;4;i++){
      UVertexList vlist = new UVertexList();
      float rad = 0;
      switch (i){
        case 0:
        rad = jointBevelRad;
        xOffset += jointBevelWidth;
        break;
        case 1:
        rad = jointRad;
        break;
        case 2:
        rad = jointRad;
        xOffset += jointWidth;
        break;
        case 3:
        rad = jointBevelRad;
        break;
      }
      for (int j=0;j&lt;resolution;j++){
        float theta = j*TWO_PI/resolution;
        vlist.add(location.x + xOffset, location.y + rad*sin(theta), location.z + rad*cos(theta));
      }
      vlist.close();
      vlists.add(vlist);
    }
  }
</pre>
<br>
getGeometry() is very simple in this class, the JointSection iterates over its ArrayList of UVertexLists and connects adjacent lists with the quadStrip() method.  Figs 3 and 4 show the triangles generated.<br>
<pre>
  UGeometry getGeometry(){

    UGeometry geo = new UGeometry();

    for (int i=1;i&lt;vlists.size();i++){
      geo.quadStrip(vlists.get(i),vlists.get(i-1));
    }
    return geo;
  }
</pre>
<br>
The JointSection is also responsible for passing the last UVertexList in its vlists to the next JointSection, so that the sections can be connected to each other.
<pre>
  UVertexList getConnectingVertices(){

    return vlists.get(vlists.size()-1);//return last element in vlists
  }
}</pre>


##Class: Joint##

The Joint class strings several JointSections together into one pin joint.<br>
<pre>//Joint class

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
*/

class Joint{

  ArrayList<UVertexList> vlists;//storage
  ArrayList<JointSection> sections;
  int numConnections;

  Joint(PVector location, int num, float centerWidth, int copies){

    vlists = new ArrayList<UVertexList>();
    sections = new ArrayList<JointSection>();
    numConnections = num;

    calculateGeometry(location, centerWidth, copies);
  }

  void calculateGeometry(PVector location, float centerWidth, int copies){

    float totalWidth = getTotalWidth(copies, centerWidth);
    float[] ends = {location.x - totalWidth/2, location.x + totalWidth/2};

    //calculate ends
    for (int i=0;i&lt;2;i++){
      UVertexList vlist = new UVertexList();
      for (int j=0;j&lt;resolution;j++){
        float theta = j*TWO_PI/resolution;
        vlist.add(ends[i], location.y + jointBevelRad*sin(theta), location.z + jointBevelRad*cos(theta));
      }
      vlist.close();
      vlists.add(vlist);
    }

    //calculate joint sections
    float xOffset = 0;
    for (int l=0;l&lt;copies;l++){
      for (int k=0;k&lt;numConnections;k++){
        PVector sectionLoc = new PVector(ends[0] + xOffset, location.y, location.z);
        UVertexList lastList = new UVertexList();
        if (k==0 && l==0){
          lastList.add(vlists.get(0));
        } else {
          lastList.add(sections.get(sections.size()-1).getConnectingVertices());
        }
        sections.add(new JointSection(lastList, sectionLoc));
        xOffset += jointBevelWidth + jointWidth;
      }
      xOffset += centerWidth + jointBevelWidth;
    }
  }

  float getTotalWidth(int copies, float centerWidth){
    return copies*(jointBevelWidth*(numConnections + 1) + jointWidth*numConnections) + centerWidth*(copies-1);
  }

  UGeometry getGeometry(){

    UGeometry geo = new UGeometry();

    for (JointSection section : sections){
      geo.add(section.getGeometry());
    }

    //close ends
    geo.quadStrip(vlists.get(1),sections.get(sections.size()-1).getConnectingVertices());
    geo.triangleFan(vlists.get(0), true, true);
    geo.triangleFan(vlists.get(1), true, false);

    sections = null;//remove from memory

    return geo;
  }
}
</pre>


##Class: Leg##

<p>Finally, the Leg class constructs a complete leg from Links and Joints.  This part is a little tricky because you have to be careful that no part of the Leg will collide with itself as it moves through a locomotion cycle.  This is a problem I still need to solve - my code will not take any arbitrary planar linkage design and solve for it's 3D structure, but I hope to eventually get there.  </p><p>It's actually an intersting <a href="http://en.wikipedia.org/wiki/Edge_coloring">edge coloring problem</a>, where you assign a different z offset to links that have the potential to collide.  The trick is to find the minimum number of z positions needed, in order to keep the linkage as planar as possible.</p><p>Again, the most recent version of this code is up on <a href="https://github.com/amandaghassaei/Genetic-Walkers">Github</a>.  I checked it and it should generate a leg STL when run.</p>