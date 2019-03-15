int screen=0;
int score=0;
ArrayList<PVector> missedShots;
ParticleSystem ps;
Skeet s;
PImage menuBackground;
PImage mainBackground;
PImage gameOverBackground;

void setup(){
  fullScreen(P2D);//Make it full screen and run using a 2d renderer
  frameRate(60);//Set frame rate

  missedShots=new ArrayList<PVector>();
  ps=new ParticleSystem();
  s=new Skeet();
  
  menuBackground=loadImage("menuBackground.png");
  mainBackground=loadImage("mainBackground.png");
  gameOverBackground=loadImage("gameOverBackground.png");
}

void draw(){
  if(screen==0){//Menu Screen
    drawMenuBackground();
  }
  else if(screen==1){//Game Screen
    drawMainBackground();
    s.run();//Run the skeet
    drawCrosshairBar();
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
      screen=1;
    }
  }
  else if(screen==1){//Game Screen
    if(mouseY<height*13/20){
      if(mouseX>(s.position.x-(s.getWidth()/2))&&mouseX<(s.position.x+(s.getWidth()/2))&&mouseY>(s.position.y-(s.getHeight()/2))&&mouseY<(s.position.y+(s.getHeight()/2))){
        ps=new ParticleSystem(new PVector(mouseX, mouseY), new PVector(s.getWidth(),s.getHeight()));
        score++;
        s.reset();
        if(score==5){
          win();
        }
      }
      else{
        score=0;
        missedShots.add(new PVector(mouseX, mouseY));
      }
    }
  }
  else if(screen==2){//Game Over Screen
  
  }
  
}

void drawMenuBackground(){
  image(menuBackground,0,0,width,height);
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
  image(mainBackground,0,0,width,height);
  fill(255,0,0);
  text(score,0,40);
}

void drawCrosshairBar(){//Draw the crosshair no-shoot zone
  fill(150);
  rect(0,height*13/20,width,height*0.2/20);
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
  if(mouseY>height*13/20){//If on the top half of the screen
    noFill();
    stroke(color(255,0,0));
    strokeWeight(3);
    line(mouseX-10,mouseY-10,mouseX+10,mouseY+10);
    line(mouseX+10,mouseY-10,mouseX-10,mouseY+10);
    stroke(0);
    strokeWeight(1);
  }
}

void drawGameOverBackground(){
  image(gameOverBackground,0,0,width,height);
}

void win(){
  missedShots=new ArrayList<PVector>();//Clear out missed shots
  score=0;//Reset Score
  screen=2;
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
    if(position.x<-10||position.x>width+10||position.y<-10||((position.y>height*13/20)&&velocity.y>0)){//Check for offscreen or off horizon
      score=0;
      reset();
    }
  }
  
  void reset(){
    position.set(random(0,width), height+10);//Generate randomly at bottom
    if(position.x<width/3){//If on left third
      velocity.set(random(0,width/200),-1*(height/100));//Random x velocity
    }
    else if(position.x<width*2/3){//If in middle
      velocity.set(random(-1*width/200,width/200),-1*(height/100));//Random x velocity
    }
    else{//On right side
      velocity.set(random(-1*width/200,0),-1*(height/100));//Random x velocity
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
    for(int i=0;i<system.size();i++){
      if(system.get(i).life<0){
        system.remove(i);
        i--;
      }
    }
  }
}
