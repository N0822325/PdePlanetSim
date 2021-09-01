static float G = 0.00000000000667408;

class celestialManager {
  
  Boolean drawTrackers = true;
  void toggleTrackers() { drawTrackers = !drawTrackers; }
  
  ArrayList<celestialObject> simObjList = new ArrayList<celestialObject>();
  
  void addSimObject(celestialObject obj, String id){
    obj.setID(id);
    simObjList.add(obj);
  }
  
  celestialObject getSimObject(String id){
    for(celestialObject thisObj: simObjList){
      if( thisObj.idMatches(id) ) return thisObj;
    }
    // if it can't find a match then ...
    return null;
  }
  
  int getNumSimObjects(){
    return simObjList.size();
  }
  
  celestialObject getSimObject(int n){
    return simObjList.get(n);
  }
  
  
  void drawAll(){
    
    randomSeed(1);
    for(celestialObject obj: simObjList){
      noStroke();
      float[] rgb = obj.getRGB();
      fill(rgb[0],rgb[1],rgb[2]);
      obj.drawMe();
      
      if(drawTrackers)
      {
        stroke(rgb[0],rgb[1],rgb[2]);
        obj.drawTracker();
      }
      
    }
  }
 
}


class celestialObject extends SimSphere
{
  
  ArrayList<SimRay> Tracker = new ArrayList<SimRay>();
  public int numTrackPoint = 1000;
  
  Boolean staticPos = false;
  void toggleMoveable() { staticPos = !staticPos; }
  
  float mass;
  float getMass() { return mass; }
  void setMass(float m) { mass = m; }
  
  float r = random(255), g = random(255), b = random(255);
  float[] getRGB() { return new float[] { r,g,b }; }
  
  public celestialObject(PVector cen, float rad) {
    init( cen,  rad);
    mass = rad;
  }
  public celestialObject(PVector cen, float rad, float mass) {
    init( cen,  rad );
    this.mass = mass;
  }
  
  void addTracker(PVector s)
  {
    Tracker.add( new SimRay(getOrigin(), s) );
    while (Tracker.size() > numTrackPoint) { Tracker.remove(0); }
  }
  void drawTracker()
  {
    for(SimRay s : Tracker) {
      s.drawMe(); 
    }
  }
  
  
  void gravitate(celestialObject other)
  {
    if (this == other) return;
      
      
    if (isCollideable && intersectsSphere(other)) {
      //if (a.getRadius() > b.getRadius()) { b.growRadius(-0.1); }
      
      PVector ricochet = PVector.sub(getOrigin(), other.getOrigin()).mult(collisionForce);
      applyForce(ricochet);
      other.applyForce(ricochet.mult(-1));
      
      //float diff = a.getRadius() - b.getRadius();
      //print(diff);
      
      //else { a.growRadius(-diff); b.growRadius(diff); }
      
      return;
    }
      
    float dist = sqrt( sq(getOrigin().x-other.getOrigin().x) 
                        + sq(getOrigin().y-other.getOrigin().y) 
                          + sq(getOrigin().z-other.getOrigin().z) );
                          
    // Gravitational Force = GravitationalConstant * mass of A * mass of B / by the distance squared
    float force = (1*getMass()*other.getMass()) / (pow(dist,2));
    
    float x = force * -(getOrigin().x-other.getOrigin().x);
    float y = force * -(getOrigin().y-other.getOrigin().y);
    float z = force * -(getOrigin().z-other.getOrigin().z);

    

    PVector splitForce = new PVector(x,y,z);
    applyForce(splitForce);
    
    update(time);
  }
  
  
  float count = 0;
  PVector f = new PVector(0,0,0);
  PVector s = new PVector(0,0,0);

  PVector getForce()
  {
    if(staticPos) { return new PVector(0,0,0); }
    return s;
  }
  void applyForce(PVector force)
  {
    // Acceleration = Force / Mass
    f.add(force.div(getMass()));
    // Velocity = Acceleraion * Time
    s = s.add(f.mult(time));
  }
  void setSpeed(float x, float y, float z) { s = new PVector(x,y,z); }
  void setSpeed(PVector newSpeed) { s = newSpeed; }
  
  void update(float time)
  {
    if(staticPos) { return; }
    
    
    
    addTracker(getOrigin().add(s));
    
    setTransformRel(1,0,0,0, s);
    
    
    //setTransformRel(1,0,0,0, s);
    //f = new PVector(0,0,0);
  }
}




class celestialSystem extends celestialManager
{
  int sizeofCelestials = 1;
  int numofCelestials = 1;
  void updateSystemInfo(int newSize, int newNum) { sizeofCelestials = newSize; numofCelestials = newNum; }
  
  void createIsolated()
  {
    float scale = sizeofCelestials * 500;
    
    for(int i = 0; i < numofCelestials; i++)
    {
      PVector loc = new PVector(-(i*scale)-5000,0,-(i*scale));
      //PVector loc = new PVector( random(scale,scale*1.5) * (random(0,1)*2-1)
      //                                ,random(scale,scale*1.5) * (random(0,1)*2-1)
      //                                  ,random(scale,scale*1.5) * (random(0,1)*2-1));
      
      float size = random(scale, scale*1.5)/10;
      
      celestialObject obj = new celestialObject(loc, size/10, size);
      //obj.setSpeed(random(0,0.0005),random(0,0.0005),random(0,0.0005));
      obj.levelOfDetail = 6;
      
      String name = "sun_"+i;
      addSimObject(obj, name);
      Suns.addItem(name);
    }
  }
  
  void clear()
  {
    simObjList.clear(); 
  }
  
  void createSystem(celestialSystem parent)
  {
    float scale = sizeofCelestials * 500;
    
    for(celestialObject c : parent.simObjList)
    {
      for(int i = 0; i < numofCelestials; i++)
      {
        String name = c.getID();
        name += name.indexOf("sun") != -1 ? name.indexOf("planet") != -1 ? " : moon_"+i : " : planet_"+i : ": unknown"+i;
        
        PVector offset = new PVector( random(scale,scale*1.5) * (random(0,1)*2-1)
                                        ,random(scale,scale*1.5) * (random(0,1)*2-1)
                                          ,random(scale,scale*1.5) * (random(0,1)*2-1));
                                          
        
        if(name.contains("moon")) {offset.div(100);}
        //else if(name.contains("planet")) {offset.mult(1.5);}
        
        float size = random(scale, scale*1.5)/10;
        
        PVector loc = c.getCentre().add(offset);
        celestialObject obj = new celestialObject(loc, size/10, size);
        obj.applyForce(new PVector(random(0,5),random(0,5),random(0,5)));
        obj.levelOfDetail = 6;
        
        
        addSimObject(obj, name);
        Suns.addItem(name);
      }
    }
    
  }
  
  
  
}




class System
{
  Boolean isActive = false;
  void toggleActive() { isActive = !isActive; } 
  
  celestialSystem sunManager = new celestialSystem();
  celestialSystem planetManager = new celestialSystem();
  celestialSystem moonManager = new celestialSystem();
  
  String[] getNames(String type)
  {
    //celestialSystem c = type == "Sun" ? sunManager : type == "Planet" ? planetManager : type == "Moon" ? moonManager : null;
    
    
    ArrayList<String> names = new ArrayList<String>();
    
    if(type == "Sun")
    {
      for(celestialObject s : sunManager.simObjList)
      {
        print(s.getID());
         names.add(s.getID());
      }
    }
    else if(type == "Planet")
    {
      for(celestialObject s : planetManager.simObjList)
      {
         names.add(s.getID());
      }
    }
    else if(type == "Moon")
    {
      for(celestialObject s : moonManager.simObjList)
      {
         names.add(s.getID());
      }
    }
    else {  }
    
    String[] out = {};
    int i = 0;
    for (String s : names)
    {
      out = addtoArray(i, out, s);
      i++;
    }
    
    
    return out;
  }
  
  private String[] addtoArray(int n, String arr[], String next)
  {
    String[] newArr = new String[n + 1];
    for(int i = 0; i < n; i++)
    {
      newArr[i] = arr[i]; 
    }
    
    newArr[n] = next;
    return newArr;
  }
  
  void createSystem(int sunCount, int planetCount, int moonCount)
  {
    randomSeed(millis());
    
    sunManager.updateSystemInfo(100,sunCount); sunManager.createIsolated();
    planetManager.updateSystemInfo(10,planetCount); planetManager.createSystem(sunManager);
    moonManager.updateSystemInfo(1,moonCount); moonManager.createSystem(planetManager);


    myUI.removeWidget("SunList"); myUI.removeWidget("PlanetList"); myUI.removeWidget("MoonList");
    
    int Width = 300;
    
    String[] sunItems = getNames("Sun");
    String[] planetItems = getNames("Planet");
    String[] moonItems = getNames("Moon");

    Suns = myUI.addMenu("SunList", Width,20, sunItems);
    Planets = myUI.addMenu("PlanetList", Width+100,20, planetItems);
    Moons = myUI.addMenu("MoonList", Width+200,20, moonItems);
    
    
  }
  
  void reset(int sunCount, int planetCount, int moonCount)
  {
    sunManager.clear();
    planetManager.clear();
    moonManager.clear();
    
    createSystem(sunCount, planetCount, moonCount);
  }
  
  
  void updateLineLength(int num)
  {
    for(celestialObject c : sunManager.simObjList) { c.numTrackPoint = num; }
    for(celestialObject c : planetManager.simObjList) { c.numTrackPoint = num; }
    for(celestialObject c : moonManager.simObjList) { c.numTrackPoint = num; }
  }
  
  int getNumObjects()
  { 
    return sunManager.getNumSimObjects() + planetManager.getNumSimObjects() + moonManager.getNumSimObjects();
  }
  
  celestialObject getObject(int n)
  {
    int ss = sunManager.getNumSimObjects(); int ps = planetManager.getNumSimObjects(); int ms = moonManager.getNumSimObjects();
    
    celestialObject a;
    if (n < ss) a = sunManager.getSimObject(n);
    else if (n-ss < ps) a = planetManager.getSimObject(n-ss);
    else a = moonManager.getSimObject(n-ss-ps);
    
    return a;
  }
  
  
  
  void Update()
  {
    if(!isActive) return;
    
    int size = getNumObjects();
    
    for(int n = 0; n < size; n++)
    {
      celestialObject a = getObject(n);
      
      for(int n2 = 0; n2 < size; n2++)
      {
        celestialObject b = getObject(n2);
        
        a.gravitate(b);
      }
    }

  }
  
  void Draw()
  {
    sunManager.drawAll();
    planetManager.drawAll();
    moonManager.drawAll();
  }
}




SimCamera myCamera;
SimpleUI myUI;

SimSphere trackBall;
celestialObject selected;
float time = 0.1;
float collisionForce = 0.1;
Boolean isCollideable = true;
Boolean updateAttribrutes = true;
Boolean TrackCam = false;
Menu Suns; Menu Planets; Menu Moons;

//GalaxyManager sunManager = new GalaxyManager();
System system = new System();





void setup(){
  size(900, 700, P3D);
  ////////////////////////////
  // create the SimCamera
  myCamera = new SimCamera();
  myCamera.setPositionAndLookat(vec(300,-100,10),vec(0,0,0));
  
  ////////////////////////////
  // create a 3D tarckball to see where we click
  trackBall = new SimSphere(2);
  
  ////////////////////////////
  // create the SimpleUI object
  // and add some items
  myUI = new SimpleUI();

  int speedHeight = 20;
  myUI.addLabel("Game Speed",780,speedHeight,"");
  myUI.addTextInputBox("Speed",780,speedHeight+30,"60");
  myUI.addToggleButton("Set Speed", 810,speedHeight+60);
  
  myUI.addLabel("Collision Force",780,speedHeight+100,"");
  myUI.addTextInputBox("collision",780,speedHeight+130,"0.1");
  myUI.addToggleButton("SetCollision", 810,speedHeight+160);
  myUI.addToggleButton("Toggle", 810,speedHeight+190);

  String[] sunItems = {}; String[] planetItems = {}; String[] moonItems = {};
  Suns = myUI.addMenu("SunList", 780,speedHeight+240, sunItems);
  Planets = myUI.addMenu("PlanetList", 780,speedHeight+260, planetItems);
  Moons = myUI.addMenu("MoonList", 780,speedHeight+280, moonItems);
  
  
  myUI.addSlider("Movement Speed", 20,10).setSliderValue(0.5);
  
  myUI.addToggleButton("Start/Stop", 20,50);
  myUI.addToggleButton("Reset", 90,50);
  
  int linesHeight = 110;
  
  myUI.addLabel("Trailing Lines",20,linesHeight,"");
  
  myUI.addTextInputBox("Line Length", 20,linesHeight+30,"1000");
  myUI.addRadioButton("Set Length", 120,linesHeight+30, "");
  
  
  myUI.addToggleButton("Sun", 20,linesHeight+60);
  myUI.addToggleButton("Planet", 90,linesHeight+60);
  myUI.addToggleButton("Moon", 160,linesHeight+60);
  
  
  int celestHeight = 230;
  
  myUI.addLabel("Celestials",20,celestHeight,"");
  myUI.addToggleButton("Set",95,celestHeight);
  
  myUI.addLabel("Suns",20,celestHeight+30,"");
  myUI.addTextInputBox("SunNo",70,celestHeight+30,"1");
  
  myUI.addLabel("Planets",20,celestHeight+60,"");
  myUI.addTextInputBox("PlanetNo",70,celestHeight+60,"5");
  
  myUI.addLabel("Moons",20,celestHeight+90,"");
  myUI.addTextInputBox("MoonNo",70,celestHeight+90,"2");
  
  myUI.addSlider("Gravity Strength", 20,celestHeight+120).setSliderValue(0.1);
  
  
  int selectedHeight = 400;
  myUI.addLabel("Selected",20,selectedHeight,"N/A");
  myUI.addLabel("Type",20,selectedHeight+30,"N/A");
  
  myUI.addLabel("Movement",20,selectedHeight+60,"");
  myUI.addRadioButton("Set Vector",95,selectedHeight+60, "");
  
  myUI.addLabel("X:",20,selectedHeight+90,"");
  myUI.addTextInputBox("X",65,selectedHeight+90,"0");
  myUI.addLabel("Y:",20,selectedHeight+120,"");
  myUI.addTextInputBox("Y",65,selectedHeight+120,"0");
  myUI.addLabel("Z:",20,selectedHeight+150,"");
  myUI.addTextInputBox("Z",65,selectedHeight+150,"0");
  
  myUI.addLabel("Mass:",20,selectedHeight+190,"");
  myUI.addTextInputBox("mass",70,selectedHeight+190,"0");
  myUI.addLabel("Radius:",20,selectedHeight+220,"");
  myUI.addTextInputBox("radius",70,selectedHeight+220,"0");
  myUI.addRadioButton("Set Traits",20,selectedHeight+250, "");
  myUI.addToggleButton("Lock Pos",90,selectedHeight+250);
  myUI.addRadioButton("Focus Cam",160,selectedHeight+250, "");
  
  
  
  //sunManager.createSystem(new PVector(0,0,0),0);
  //sunManager.x();
  system.createSystem(1, 5, 2);
}

float timer = 90;
float[] rgb = {25,0,25};

void draw(){
  timer += 0.1;

  background(abs(rgb[0] * sin(radians(timer))),rgb[1], abs(rgb[2] * sin(radians(timer))));
  lights();
  
  myCamera.update();
  //sunManager.Update();
  //sunManager.Draw();
  system.Update();
  system.Draw();
  
  
  //if(!sunManager.isActive) { updateAttribrutes = true; }
  if(selected != null && ( system.isActive || updateAttribrutes) ) {
    myUI.setText("Selected",selected.getID());
    String type = selected.getID().contains("moon") ? "Moon" : selected.getID().contains("planet") ? "Planet" : "Sun";
    myUI.setText("Type", type);
    
    myUI.setText("X",str(selected.getForce().x));
    myUI.setText("Y",str(selected.getForce().y));
    myUI.setText("Z",str(selected.getForce().z));
    
    myUI.setText("mass",str(selected.getMass()));
    myUI.setText("radius",str(selected.getRadius()));
    
    if(TrackCam) {
      //myCamera.setPositionAndLookat(selected.getCentre().add(new PVector(9000,0,0)), selected.getCentre());
      myCamera.setPositionAndLookat(myCamera.getPosition(), selected.getCentre());
    }
    
    updateAttribrutes = false;
  }
  
  //trackBall.drawMe();
  
  myCamera.startDrawHUD();
    // any 2d drawing has to happen between 
    // startDrawHUD and endDrawHUD
    myUI.update();
  myCamera.endDrawHUD();
}










// UI Events

void handleUIEvent(UIEventData uied){
  // here we just get the event to print its self
  // with "verbosity" set to 1, (2 = medium, 3 = high, 0 = do not print anything)
  uied.print(1);
  
  
  if(uied.eventIsFromWidget("Start/Stop") ){
    system.toggleActive();
  }
  
  if(uied.eventIsFromWidget("Reset") ){
    system.reset(int(myUI.getText("SunNo")), int(myUI.getText("PlanetNo")), int(myUI.getText("MoonNo")));
  }
  
  if(uied.eventIsFromWidget("Set") ){
    system.reset(int(myUI.getText("SunNo")), int(myUI.getText("PlanetNo")), int(myUI.getText("MoonNo")));
  }
  
  if(uied.eventIsFromWidget("Set Speed") ){
    frameRate(float(myUI.getText("Speed")));
  }
  if(uied.eventIsFromWidget("SetCollision") ){
    collisionForce = float(myUI.getText("collision"));
  }
  if(uied.eventIsFromWidget("Toggle") ){
    isCollideable = !isCollideable;
  }
  
  
  
  if(uied.eventIsFromWidget("Set Length") ){
    system.updateLineLength(int(myUI.getText("Line Length")));
  }
  if(uied.eventIsFromWidget("Sun") ){
    system.sunManager.toggleTrackers();
  }
  if(uied.eventIsFromWidget("Planet") ){
    system.planetManager.toggleTrackers();
  }
  if(uied.eventIsFromWidget("Moon") ){
    system.moonManager.toggleTrackers();
  }
  
  
  if(uied.eventIsFromWidget("Set Vector") ){
    
    if(selected != null) { selected.setSpeed( float(myUI.getText("X")), float(myUI.getText("Y")), float(myUI.getText("Z"))); }
  }
  
  if(uied.eventIsFromWidget("Set Traits") ){
    
    if(selected != null) { selected.setRadius( float(myUI.getText("radius"))); selected.setMass( float(myUI.getText("mass"))); }
  }
  if(uied.eventIsFromWidget("Lock Pos") ){
    if(selected != null) { selected.toggleMoveable(); }
  }
  if(uied.eventIsFromWidget("Focus Cam") ){
    if(selected != null) { TrackCam = !TrackCam; }
  }
  
  
  if(uied.eventIsFromWidget("Movement Speed") && uied.mouseEventType.equals("mouseReleased")){
    
    myCamera.forwardSpeed = uied.sliderValue * 1000;
    
  }
  if(uied.eventIsFromWidget("Gravity Strength") && uied.mouseEventType.equals("mouseReleased")){
    
    time = uied.sliderValue;
    
  }
  
  if(uied.eventIsFromWidget("SunList")){
    String s = Suns.getItem(mouseY);
    selected = system.sunManager.getSimObject(s);
    updateAttribrutes = true;
  }
  if(uied.eventIsFromWidget("PlanetList")){
    String s = Planets.getItem(mouseY);
    selected = system.planetManager.getSimObject(s);
    updateAttribrutes = true;
  }
  if(uied.eventIsFromWidget("MoonList")){
    String s = Moons.getItem(mouseY);
    selected = system.moonManager.getSimObject(s);
    updateAttribrutes = true;
  }
  
}




















// Selection

void updateTrackball(){ 
    if( myCamera.mouseInHUDArea() ) return;
    if(mouseButton == RIGHT) return;
    boolean pickedSomething = false;
    
    
    int numObjects = system.getNumObjects();    
    for(int n = 0; n < numObjects; n++){
      celestialObject obj = system.getObject(n);
      
      SimRay mr =  myCamera.getMouseRay();
      mr.setID("mouseRay");
       
      if(mr.calcIntersection( obj ) ){
        selected = obj;
        updateAttribrutes = true;
        
        PVector intersectionPt = mr.getIntersectionPoint();
        trackBall.setTransformAbs(1,0,0,0,intersectionPt);
        printRayIntersectionDetails(obj.getID(), mr);
        pickedSomething = true;
      }
      
    }  
    if(pickedSomething) return;
   
         
    // should no intersection happen, the trackball is drawn at z=1000 in eye space in the scene 
    SimRay mr =  myCamera.getMouseRay();
    PVector mp = mr.getPointAtDistance(1000);
    printRayIntersectionDetails("nothing", mr);
    trackBall.setTransformAbs(1,0,0,0,mp);
    
  }
  
  
  void printRayIntersectionDetails(String what, SimRay sr){
            
    PVector intersectionPt = sr.getIntersectionPoint();
    PVector intersectionNormal = sr.getIntersectionNormal();
    int hits = sr.getNumIntersections();
    println("That ray hit ", what ,"with " ,  hits , " intersections ");
    println("Intersection at ", intersectionPt);
    println("Surface Normal at ", intersectionNormal);
    println("ID of object hit ", sr.getColliderID());
  }

void mouseDragged(){
  updateTrackball();
}


void mousePressed(){
  updateTrackball();
}
