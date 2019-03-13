Skeet s;
ArrayList<PVector> missedShots;
ParticleSystem ps=new ParticleSystem();
int score=0;

void setup(){
  fullScreen(P2D);
  frameRate(60);
  s=new Skeet();
  missedShots=new ArrayList<PVector>();
}

void draw(){
  drawBackground();
  s.run();//Run the skeet
  drawTarget();
  ps.run();
}

void drawBackground(){
  background(color(91,201,239));
  fill(color(25, 153, 9));
  rect(0,height*2/3,width,(height-(height*2/3)));
}

void mousePressed(){
  if(mouseY<height*2/3){
    if(mouseX>(s.position.x-(s.getWidth()/2))&&mouseX<(s.position.x+(s.getWidth()/2))&&mouseY>(s.position.y-(s.getHeight()/2))&&mouseY<(s.position.y+(s.getHeight()/2))){
      ps=new ParticleSystem(new PVector(mouseX, mouseY), new PVector(s.getWidth(),s.getHeight()));
      s.reset();
      score++;
      if(score==10){
        win();
      }
    }
    else{
      missedShots.add(new PVector(mouseX, mouseY));
    }
  }
  println(score);
}

void drawTarget(){
  for(PVector m:missedShots){
    stroke(color(255,0,0));
    strokeWeight(1);
    noFill();
    circle(m.x,m.y,20);
    line(m.x-10,m.y,m.x+10,m.y);
    line(m.x,m.y-10,m.x,m.y+10);
    stroke(0);
    strokeWeight(1);
  }
}

void win(){
  missedShots=new ArrayList<PVector>();
  score=0;
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
    if(position.x<-10||position.x>width+10||position.y<-10||((position.y>height*2/3)&&velocity.y>0)){//Check for offscreen or off horizon
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

  ParticleSystem(){
  
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
