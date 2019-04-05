int screen=0;//Keep track of current screen value
int score=0;//Keep track of score
float crossbarY;//A value to store the crossbar y
boolean zoomed=false;//Boolean to store the current zoom state
boolean justSwitched=false;
ArrayList<PVector> missedShots;//Holds all the missed shot locations
ParticleSystem ps;//Explosion effect
Skeet s;//Skeet object
PImage menuBackground;//Image backgrounds
PImage mainBackground;
PImage gameOverBackground;
PVector mouse;//For mouse location relative to origin
PVector img;//Location of image when zoomed in
PVector origin;//Location of the zoomed in origin

void setup(){
  fullScreen(P2D);//Make it full screen and run using a 2d renderer
  frameRate(60);//Set frame rate
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);

  missedShots=new ArrayList<PVector>();//Initialize all the objects
  mouse=new PVector();
  img=new PVector(width/2, height/2);
  origin=new PVector();
  ps=null;
  s=new Skeet();
  crossbarY=height*3/20;
  
  menuBackground=loadImage("menuBackground.png");//Load in the background images
  mainBackground=loadImage("mainBackground.png");
  gameOverBackground=loadImage("gameOverBackground.png");
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
    calculateMouseLoc();//Calculate the mouse object
    if(zoomed){
      scale(2);//Scale everything by 2
      translate(origin.x,origin.y);//Translate the origin to 2x the opposite of the mouse (So the locations make them appear correctly on the screen)
    }
    s.run();//Run the skeet
    drawCrossbar();//Draw the crossbar
    drawTargets();//Draw the targets
    drawCrosshair();//Draw the crosshair if you can are in the shootable area
    if(ps!=null){
      ps.run();//Run the Particle System, as long as it has a value
    }
  }
  else if(screen==2){//Game End Screen
    if(justSwitched){
      drawGameOverBackground();
      justSwitched=false;
    }
    ps.run();
    if(ps.system.size()==0){
      drawGameOverBackground();
      PVector fireworkLoc=new PVector(random(0,width),random(0, height/3));
      ps=new ParticleSystem(fireworkLoc);
    }
    textSize(55);
    fill(0,0,255);
    text("You Win!",width/2-20,height/2);
    if(mouseX>width*0.026078&&mouseX<width*0.280842&&mouseY>height*0.809428&&mouseY<height*0.937813){//Within the sign
      fill(0,255,0);
    }
    text("Play!",width*0.12,height*0.89);
  }
}

void mousePressed(){
  if(screen==0){//Menu Screen
    if(mouseX>width*0.026078&&mouseX<width*0.280842&&mouseY>height*0.809428&&mouseY<height*0.937813){//Within the sign
      screen=1;//Load the game
    }
  }
  
  else if(screen==1&&mouseButton==LEFT){//Shoot
    if(mouse.y<crossbarY){//Above crossbar
      if(mouse.x>s.position.x-(s.getWidth()/2)&&mouse.x<s.position.x+(s.getWidth()/2)&&mouse.y>s.position.y-(s.getHeight()/2)&&mouse.y<s.position.y+(s.getHeight()/2)){//If you click within the skeet
        ps=new ParticleSystem(new PVector(mouse.x, mouse.y), new PVector(s.getWidth(), s.getHeight()), color(209,113,4));//Add a particle effect
        score++;//Increase score
        s.reset();
        if(score==5){//Check for win condition
          win();
        }
      }
      else{
        score=0;
        missedShots.add(new PVector(mouse.x, mouse.y));//Add a missed shot
      }
    }
 }
  
  else if(screen==1&&mouseButton==RIGHT){//Right clicked
    if(!zoomed){
      zoom(mouse.x,mouse.y);//Only call zoom if you aren't zoomed
    }
    zoomed=!zoomed;//Switch the zoom state
  }
  
  else{//Game Over Screen
    if(mouseX>width*0.026078&&mouseX<width*0.280842&&mouseY>height*0.809428&&mouseY<height*0.937813){//Within the sign
      ps=null;
      screen=0;//Reset the game
    }
  }
}

void mouseMoved(){
  if(zoomed){
    origin.add(pmouseX-mouseX,pmouseY-mouseY);
    if(origin.x>width/4){//Make sure the game stays in bounds. Divide by 4 because the coordinates are scaled up by 2 when drawn
      origin.x=width/4;
    }
    if(origin.y>height/4){
      origin.y=height/4;
    }
    if(origin.x<-width/4){
      origin.x=-width/4;
    }
    if(origin.y<-height/4){
      origin.y=-height/4;
    }
      img.set(origin.x*2,origin.y*2);//Set by 2 since img set isn't scaled
  }
}

void calculateMouseLoc(){
  if(screen==1){
    mouse.set(mouseX-width/2, mouseY-height/2);//Mouse location relative to center of screen
    if(zoomed){
      mouse.set((mouse.x-origin.x*2)/2, (mouse.y-origin.y*2)/2);//Mouse location relative to the zoom origin
    }
  }
}

void zoom(float x, float y){
  origin.set(-x, -y);//Negative because we want it to start drawing the shapes farther away from the mouse
  img.set(origin.x*2,origin.y*2);//Calculate and change the background image position based on where you zoomed
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
  image(gameOverBackground,width/2,height/2,width,height);
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
  if(mouse.y>crossbarY){//If below the crosshair bar
    noFill();
    stroke(color(255,0,0));
    strokeWeight(3);
    line(mouse.x-10,mouse.y-10,mouse.x+10,mouse.y+10);
    line(mouse.x+10,mouse.y-10,mouse.x-10,mouse.y+10);
    stroke(0);
    strokeWeight(1);
  }
}

void win(){
  missedShots=new ArrayList<PVector>();//Clear out missed shots
  score=0;//Reset Score
  screen=2;
  zoomed=false;
  PVector fireworkLoc=new PVector(random(0,width),random(0, height/3));
  ps=new ParticleSystem(fireworkLoc);//Add a particle effect
  translate(-width/2,-height/2);
  justSwitched=true;
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
    position.set(random(-width/2,width/2), height/2+10);//Generate randomly at bottom
    if(position.x<-width/4){//If on left side
      velocity.set(random(0,width/250),-1*(height/120));//Right x velocity
    }
    else if(position.x<width/4){//If in middle
      velocity.set(random(-1*width/250,width/200),-1*(height/120));//Random x velocity
    }
    else{//On right side
      velocity.set(random(-1*width/250,0),-1*(height/120));//Left x velocity
    }
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
  PVector pposition=new PVector();//Previous position
  float life=255;
  float initialLife=255;
  color c;
  boolean skeet=false;
  boolean trace=false;//use the line
  
  Particle(float x, float y, color col, boolean skeet){//Clay explosion
    position.set(x,y);
    if(skeet){
      velocity.set(random(-1,1),random(-1,1));
    }
    else{
      velocity.set(random(-5,5),random(-5,5));
      life=00;
      initialLife=1000;
      trace=true;
    }
    acceleration=s.acceleration.copy();
    c=col;
  }
  
  void run(){
    update();
    display();
  }
  
  void update(){
    life-=5;
    velocity.add(acceleration);
    pposition=position.copy();
    position.add(velocity);
  }
  
  void display(){
    noStroke();
    fill(c,(life/initialLife)*255);
    ellipse(position.x,position.y,5,5);
    if(trace){
      strokeWeight(5);
      stroke(c);
      line(pposition.x,pposition.y,position.x,position.y);
    }
    stroke(0);
  }
}



class ParticleSystem{
  ArrayList<Particle> system=new ArrayList<Particle>();
  PVector position=new PVector();
  PVector dimensions=new PVector();
  color c;

  ParticleSystem(PVector p, PVector d, color col){//Clay constructor
    position=p.copy();
    c=col;
    dimensions=d.copy();
    for(int i=0;i<(0.05*dimensions.x*dimensions.y);i++){
      system.add(new Particle(random(position.x-(dimensions.x/3),position.x+(dimensions.x/3)),random(position.y-(dimensions.y/3),position.y+(dimensions.y/3)), c, true));
    }
  }
  
  ParticleSystem(PVector p){//Firework constructor
    position=p.copy();
    for(int i=0;i<100;i++){
      system.add(new Particle(p.x, p.y, color(random(0,255),random(0,255),random(0,255)),false));
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
