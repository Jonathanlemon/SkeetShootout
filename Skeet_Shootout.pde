int screen=0;//Keep track of current screen value
int score=0;//Keep track of score
float crossbarY;//A value to store the crossbar y
boolean zoomed=false;//Boolean to store the current zoom state
ArrayList<PVector> missedShots;//Holds all the missed shot locations
ParticleSystem ps;//Explosion effect
Skeet s;//Skeet object
PImage menuBackground;//Image backgrounds
PImage mainBackground;
PImage gameOverBackground;
PVector realMouse;//For mouse location relative to origin
PVector img;//Location of image when zoomed in
PVector origin;//Location of the zoomed in origin

void setup(){
  fullScreen(P2D);//Make it full screen and run using a 2d renderer
  frameRate(60);//Set frame rate
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);

  missedShots=new ArrayList<PVector>();//Initialize all the objects
  realMouse=new PVector();
  img=new PVector();
  origin=new PVector();
  ps=new ParticleSystem();
  s=new Skeet();
  crossbarY=height*3/20;
  
  menuBackground=loadImage("menuBackground.png");//Load in the background images
  mainBackground=loadImage("mainBackground.png");
  //gameOverBackground=loadImage("gameOverBackground.png");
}

void draw(){
  if(screen==0){//Menu Screen
    drawMenuBackground();
  }
  else if(screen==1){//Game Screen
    translate(width/2,height/2);//Set origin to middle (resets after every draw)
    drawMainBackground();
    fill(255,200,0);
    text("Score: "+score,-width/2,-height/2+50);//Draw Score
    calculateMouseLoc();//Calculate the realMouse object
    if(zoomed){
      scale(2);//Scale everything by 2
      translate(origin.x,origin.y);//Translate the origin to 2x the opposite of the mouse (So the locations make them appear correctly on the screen)
    }
    s.run();//Run the skeet
    drawCrossbar();//Draw the crossbar
    drawTargets();//Draw the targets
    drawCrosshair();//Draw the crosshair if you can are in the shootable area
    ps.run();//Run the Particle Systems
  }
  else if(screen==2){//Game End Screen
    drawGameOverBackground();
  }
}

void mousePressed(){
  if(screen==0){//Menu Screen
    if(mouseX>width*0.026078&&mouseX<width*0.280842&&mouseY>height*0.809428&&mouseY<height*0.937813){//Within the sign
      screen=1;//Load the game
    }
  }
  
  else if(screen==1&&mouseButton==LEFT){//Shoot
    if(realMouse.y<crossbarY){//Above crossbar
      if(realMouse.x>s.position.x-(s.getWidth()/2)&&realMouse.x<s.position.x+(s.getWidth()/2)&&realMouse.y>s.position.y-(s.getHeight()/2)&&realMouse.y<s.position.y+(s.getHeight()/2)){//If you click within the skeet
        ps=new ParticleSystem(new PVector(realMouse.x, realMouse.y), new PVector(s.getWidth(),s.getHeight()));//Add a particle effect
        score++;//Increase score
        s.reset();
        if(score==10){//Check for win condition
          win();
        }
      }
      else{
        score=0;
        missedShots.add(new PVector(realMouse.x, realMouse.y));//Add a missed shot
      }
    }
 }
  
  else if(screen==1&&mouseButton==RIGHT){//Right clicked
    if(!zoomed){
      zoom(realMouse.x,realMouse.y);//Only call zoom if you aren't zoomed
    }
    zoomed=!zoomed;//Switch the zoom state
  }
  
  else{//Game Over Screen
  
  }
}

void calculateMouseLoc(){
  if(screen==1){
    realMouse.set(mouseX-width/2, mouseY-height/2);//Mouse location relative to center of screen
    if(zoomed){
      realMouse.set((realMouse.x-origin.x*2)/2, (realMouse.y-origin.y*2)/2);//Mouse location relative to the zoom origin
    }
  }
}

void zoom(float x, float y){
  origin.set(-x, -y);//Negative because we want it to start drawing the shapes farther away from the mouse
  img.set(-realMouse.x*2, -realMouse.y*2);//Calculate and change the background image position based on where you zoomed
  if(img.x>width/2){//Make sure the image stays within bounds
    img.x=width/2;
  }
  if(img.y>height/2){
    img.y=height/2;
  }
  if(img.x<-width/2){
    img.x=-width/2;
  }
  if(img.y<-height/2){
    img.y=-height/2;
  }
}

void drawMenuBackground(){
  image(menuBackground,width/2,height/2,width,height);
  textSize(55);
  if(mouseX>width*0.026078&&mouseX<width*0.280842&&mouseY>height*0.809428&&mouseY<height*0.937813){//Within the sign
    fill(0,255,0);
  }
  else{
    fill(0,0,255);
  }
  text("Play!",width*0.12,height*0.89);
}

void drawMainBackground(){
  if(zoomed){
    image(mainBackground,img.x,img.y,width*2,height*2);//Display large image
  }
  else{
    image(mainBackground,0,0,width,height);//Display normal image
  }
}

void drawGameOverBackground(){
  //image(gameOverBackground,width/2,height/2,width,height);
}

void drawCrossbar(){//Draw the crosshair no-shoot zone
  fill(150);
  rect(0,crossbarY,4000,height*0.2/20);//Goes across very far
}

void drawTargets(){
  for(PVector m:missedShots){
    noFill();
    stroke(color(255,0,0));
    circle(m.x,m.y,20);
    line(m.x-10,m.y,m.x+10,m.y);
    line(m.x,m.y-10,m.x,m.y+10);
    stroke(0);
  }
}

void drawCrosshair(){
  if(realMouse.y>crossbarY){//If below the crosshair bar
    noFill();
    stroke(color(255,0,0));
    strokeWeight(3);
    line(realMouse.x-10,realMouse.y-10,realMouse.x+10,realMouse.y+10);
    line(realMouse.x+10,realMouse.y-10,realMouse.x-10,realMouse.y+10);
    stroke(0);
    strokeWeight(1);
  }
}

void win(){
  missedShots=new ArrayList<PVector>();//Clear out missed shots
  score=0;//Reset Score
  screen=2;
  zoomed=false;
}

class Skeet{
  PVector position=new PVector();
  PVector velocity=new PVector();
  PVector acceleration=new PVector();//Used so it slows down vertically as it goes
  float size;//Used for the size as it goes farther away
  float w;
  float h;
  
  Skeet(){
    reset();
  }
  
  void run(){
    update();
    display();
    check();
  }
  
  void update(){
    velocity.add(acceleration);//Update the vectors
    position.add(velocity);
    if(size>5){
      size=size-size*0.008;//Make it smaller as it goes, but not too small
    }
    w=size*2;//Update the display variables
    h=size;
  }
  
  void display(){
    fill(color(209,113,4));
    ellipse(position.x,position.y,w,h);
    fill(color(155, 111, 24));
    ellipse(position.x,position.y,w/2,h/2);
  }
  
  void check(){
    if((position.y>crossbarY)&&velocity.y>0){//Check for offscreen or off horizon
      score=0;
      reset();
    }
  }
  
  void reset(){
    translate(-origin.x,-origin.y);//Reset to middle so the spawning works correctly
    position.set(random(-width/2,width/2), height/2+10);//Generate randomly at bottom
    if(position.x<-width/4){//If on left side
      velocity.set(random(0,width/200),-1*(height/100));//Random x velocity
    }
    else if(position.x<width/4){//If in middle
      velocity.set(random(-1*width/200,width/200),-1*(height/100));//Random x velocity
    }
    else{//On right side
      velocity.set(random(-1*width/200,0),-1*(height/100));//Random x velocity
    }
    translate(origin.x,origin.y);//re-translate
    acceleration.set(0, (float)height/15000);
    size=height/20;
    w=size*2;
    h=size;
  }
  
  float getWidth(){
    return w;
  }
  
  float getHeight(){
    return h;
  }
}



class Particle{
  PVector position=new PVector();
  PVector velocity=new PVector();
  PVector acceleration=new PVector();
  int life;
  
  Particle(float x, float y){
    position.set(x,y);
    velocity.set(random(-1,1),random(-1,1));
    acceleration=s.acceleration.copy();
    life=255;
  }
  
  void run(){
    update();
    display();
  }
  
  void update(){
    life=life-5;
    velocity.add(acceleration);
    position.add(velocity);
  }
  
  void display(){
    noStroke();
    fill(color(209,113,4),life);
    ellipse(position.x,position.y,5,5);
    stroke(0);
  }
}



class ParticleSystem{
  ArrayList<Particle> system=new ArrayList<Particle>();
  PVector position=new PVector();
  PVector dimensions=new PVector();

  ParticleSystem(){//Blank Constructor for Initialization
  
  }

  ParticleSystem(PVector p, PVector d){
    position=p.copy();
    dimensions=d.copy();
    for(int i=0;i<(0.05*dimensions.x*dimensions.y);i++){
      system.add(new Particle(random(position.x-(dimensions.x/3),position.x+(dimensions.x/3)),random(position.y-(dimensions.y/3),position.y+(dimensions.y/3))));
    }
  }
  
  void run(){
    for(Particle p:system){
      p.run();
    }
    for(int i=0;i<system.size();i++){//If dead remove the particle
      if(system.get(i).life<0){
        system.remove(i);
        i--;
      }
    }
  }
}
