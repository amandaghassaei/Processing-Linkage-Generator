Processing-Linkage-Generator
===============

mechanical walking mechanisms designed in Processing, exported to STL for 3D Printing via ModelBuilder Library

<p>A very long time ago, I started writing an Instructable about generating a 3D printable linkage from processing.  Eventually that project grew in other directions and I abandoned all my Processing code.  I already wrote a lot about it and since it might be useful to someone, so I've included some explanation here. </p><p>The next several steps will describe the Processing sketch used to transform the information describing the geometry of a leg into a 3D printable model of the leg.  This is still very much a work in progress, but it is a nice example of how to use the <a href="https://github.com/mariuswatz/modelbuilder">Modelbuilder library</a>.</p>

Class: LinkHinge
===============

<p>The first class I designed in this project is the class which deals with the geometry of something I'm calling a "LinkHinge", this is the end piece of a link that allows a link to rotate around a joint.  As you can see in the images above, the LinkHinge has a rounded edge with a hole, and a square end that connects to the rest or the link.  The dimensions of each feature on the LinkHinge is specified by the variables:</p><p><strong>  float innerRad = 0.05;<br>
  float outerRad = 0.08;<br>
  float hingeWidth = 0.08;</strong></p><p>whose units are in inches.  The number of points defined around the circular portion of the LinkHinge is given by the following variable:</p><p>  <strong> int resolution = 64;</strong></p><p>This number may be increased to increase the density of points on the mesh, making the rounded features less faceted, or it may be decreased to decrease the overall size of the resulting STL file.  This number must always be divisible by four.</p>
<pre>&lt;strong&gt;//LinkHinge class

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
*/

class LinkHinge {

  ArrayList&lt;UVertexList&gt; vlists;//storage for vertices
  float hingeAngle;//angle of rotation of hinge

  LinkHinge(PVector hingePos, float _hingeAngle){

    vlists = new ArrayList&lt;UVertexList&gt;();//data for hinge geometry is stored in 16 vertex lists
    for (int i=0;i&lt;16;i++){
      vlists.add(new UVertexList());
    }
    hingeAngle = _hingeAngle;//angle of hinge in yz plane
    calculateGeometry(hingePos);
  }</pre><p>
The LinkHinge class is initialized with an <a href="http://processing.org/reference/ArrayList.html">ArrayList</a> of 16 <a href="http://workshop.evolutionzone.com/code/modelbuilder/javadoc/unlekker/modelbuilder/UVertexList.html">UVertexList</a>s, these lists will store all the vertices of the LinkHinge, and will be used to create the geometry of the part.  Two parameters are passed in when an instance of the class is created, "hingePos" and "hingeAngle".  hingePos is a 3 dimensional coordinate (<a href="http://processing.org/reference/PVector.html">PVector</a>) which sets the position of the hinge in space.  hingeAngle is the angle of rotation of the hinge in the yz plane (the direction of the hole cutout in the hinge is always perpendicular to the yz plane, all joints run parallel to the x axis).</p>
In all of the classes that deal directly with generating the geometry of the STL, I've broken up calculating the vertices and creating the geometry of the shape from the vertices into two functions: "calculateGeometry" and "getGeometry".  In calculateGeomerty, the vertices are calculated for two distinct sections of the LinkHinge, the outer curved portion (figs 1 and 2) and the square portion that attaches to the rest of the link (figs 3 and 4).<br>
<pre>&lt;strong&gt;
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
<pre>&lt;strong&gt;
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
<pre>&lt;strong&gt;
  ArrayList getConnectingVertices(boolean inverse, boolean opposite){

    ArrayList&lt;UVertexList&gt; connectingLists = new ArrayList&lt;UVertexList&gt;();

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

