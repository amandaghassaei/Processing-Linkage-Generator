//LinkHinge class - the end of each link in the linkage - rounded corners with a hole that connects to joint

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
    for (int i=0;i<16;i++){
      vlists.add(new UVertexList());
    }
    hingeAngle = _hingeAngle;
    calculateGeometry(hingePos);
  }
  
  void calculateGeometry(PVector hingePos){
    
    //draw outer curved portion
    for (int i=resolution/4;i<=(3*resolution/4);i++){
      float theta = i*TWO_PI/resolution + hingeAngle;
      vlists.get(0).add(hingePos.x, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(1).add(hingePos.x, hingePos.y + outerRad*sin(theta), hingePos.z + outerRad*cos(theta));
      vlists.get(2).add(hingePos.x + hingeWidth, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(3).add(hingePos.x + hingeWidth, hingePos.y + outerRad*sin(theta), hingePos.z + outerRad*cos(theta));
    }
    
    //draw square inner part
    for (int i=0;i<=resolution/4;i++){
      float theta = i*TWO_PI/resolution + hingeAngle;
      vlists.get(4).add(hingePos.x, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
      vlists.get(6).add(hingePos.x + hingeWidth, hingePos.y + innerRad*sin(theta), hingePos.z + innerRad*cos(theta));
    }
    for (int i=3*resolution/4;i<=resolution;i++){
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
      if (i < connections.n){
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
      for(int i=0;i<4;i++){
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
}

