////calculate offset for each leg
//
//class LegGroup{
//  
//  ArrayList<Leg> legs;//storage
//  
//  LegGroup (PVector location){
//    
//    legs = new ArrayList<Leg>();
//    for (int i=0;i<numLegs;i++){
//      PVector legLocation = new PVector(location.x+i*(legSpacing+legWidth),location.y,location.z);
//      legs.add(new Leg(legLocation));
//    } 
//  }
//  
//  UGeometry getGeometry(){
//    UGeometry geo = new UGeometry();
//    for (Leg leg : legs){
//      geo.add(leg.getGeometry());
//    }
//    return geo;
//  }
//  
//}
