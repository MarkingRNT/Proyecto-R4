//CÓDIGO DE LA PANTALLA
import processing.serial.*; // Librería para comunicación
import java.awt.event.KeyEvent; // Para leer la información de la comunicación
import java.io.IOException;
Serial Puerto;

//Variables globales
String angulo="";
String distancia="";
String VelocidadAngular="";
String datos="";
String EstadoObjeto;
float DistanciaPix;
int iAngulo, iDistancia, iVelocidadAngular;
int coma=0;
PFont Arial;


void setup() {
  
 size (1750, 980); // cambiar para resolución optima (width, height)
 smooth(); //no crear dientes de sierra en las líneas
 Puerto = new Serial(this,"COM5", 9600); //comunicación serial con el puerto(para recibir los datos de Arduino IDE)
 Puerto.bufferUntil('.'); //Se lee hasta el punto (Angulo,distancia,Velocidad Angular.)
 Arial = createFont("Arial",20); // Fuente a usar
}


void draw() {
  
  fill(98,245,31); //establece un color, en este caso verde, para las llamadas posteriores.
  textFont(Arial);
  // simular blur y desvanecimiento de la linea
  noStroke();
  fill(0,4,0); //color de fondo
  rect(0, 0, width, height-height*0.065);
  
  fill(98,245,31); // verde

  //Dibujamos todos los elementos que forman nuestro radar visual.
  DibujarRadar();
  Linea();
  LineaObjeto();
  DibujarTexto();
} //fin draw


//Función para la comunicación processing
void serialEvent (Serial Puerto) { 

  //Se lee hasta el punto y se mete en un string
  datos = Puerto.readStringUntil('.');
  datos = datos.substring(0,datos.length()-1); //Agarra el print "(angulo,distancia,Velocidad Angular.)"
  
  //Se agarra el print y se lee todas las comas que hay
  coma = datos.indexOf(","); 
 
  angulo= datos.substring(0, coma); // Se lee desde el comienzo del print hasta la primera coma, agarando solo "angulo"
  distancia= datos.substring(coma+1, coma+2); // Se lee desde la primera coma hasta la segunda coma, agarrando solo "distancia"
  VelocidadAngular= datos.substring(coma+2, datos.length()); // Se lee desde la segunda coma hasta el final del print, agarrando solo "Velocidad Angular"
  
  
  print(angulo);
  

  // Convertir a entero.
  iAngulo = int(angulo);
  iDistancia = int(distancia);
}//fin serialEvent


//Función para dibujar los arcos y las líneas que forman el radar.
void DibujarRadar() {
  
  pushMatrix();
  // Mover de coordenadas 0,0 a sus coordenadas correspondientes.
  translate(width/2,height-height*0.074); 

  noFill();
  strokeWeight(2);
  stroke(98,245,31);

  // dibujar los arcos del radar
  arc(0,0,(width-width*0.0625),(width-width*0.0625),PI,TWO_PI);
  arc(0,0,(width-width*0.27),(width-width*0.27),PI,TWO_PI);
  arc(0,0,(width-width*0.479),(width-width*0.479),PI,TWO_PI);
  arc(0,0,(width-width*0.687),(width-width*0.687),PI,TWO_PI);

  // dibujar las líneas que cortan los arcos
  line(-width/2,0,width/2,0);
  line(0,0,(-width/2)*cos(radians(30)),(-width/2)*sin(radians(30)));
  line(0,0,(-width/2)*cos(radians(60)),(-width/2)*sin(radians(60)));
  line(0,0,(-width/2)*cos(radians(90)),(-width/2)*sin(radians(90)));
  line(0,0,(-width/2)*cos(radians(120)),(-width/2)*sin(radians(120)));
  line(0,0,(-width/2)*cos(radians(150)),(-width/2)*sin(radians(150)));
  line((-width/2)*cos(radians(30)),0,width/2,0);
  popMatrix();
}//fin DibujarRadar


//Función que dibuja al objeto detectado
void LineaObjeto() {

  pushMatrix();
  translate(width/2,height-height*0.074); 
  strokeWeight(9);
  stroke(255,10,10); // red color

  // Conversor de cm a pixeles
  DistanciaPix = iDistancia*((height-height*0.1666)*0.025); 
  
  // Limitar rango a 40 cm (maximo del radar)
  if(iDistancia<40){
    
       // Se dibuja el objeto dependiendo de su ángulo y distancia
        line(DistanciaPix*cos(radians(iAngulo)),DistanciaPix*sin(radians(iAngulo)), (width-width*0.505)*cos(radians(iAngulo)), -(width-width*0.505)*sin(radians(iAngulo)));
  }
  popMatrix();
} //fin LineaObjeto


//Función que dibuja la línea representando al sensor
void Linea() {

  pushMatrix();
  strokeWeight(9);
  stroke(30,250,60); //otro tono de verde.
  translate(width/2,height-height*0.074); 
  line(0,0,(height-height*0.12)*cos(radians(iAngulo)),-(height-height*0.12)*sin(radians(iAngulo))); // Dibuja la línea según el ángulo.

  popMatrix();
} //fin Linea
  

//Función que dibuja todo el texto que aparece.
void DibujarTexto() {
  pushMatrix();
  
  //Si detecta un objeto a menos de 40 cm, cambia de enunciado.
  if(iDistancia>40) {
    EstadoObjeto = "Fuera de rango";
  }
  else {
    EstadoObjeto = "En rango";
  }
  
  fill(0,0,0); //Negro
  noStroke();
  rect(0, height-height*0.0648, width, height);
  fill(98,245,31);
  textSize(25);
  
  //Distancia que representan los arcos
  text("10cm",width-width*0.3854,height-height*0.0833);
  text("20cm",width-width*0.281,height-height*0.0833);
  text("30cm",width-width*0.177,height-height*0.0833);
  text("40cm",width-width*0.0729,height-height*0.0833);
  
  //Atributos destacables cuando se detecta un objeto
  textSize(40);

  text("Objeto: " + EstadoObjeto, width-width*0.98, height-height*0.0277);
  text("Angulo: " + iAngulo +" °", width-width*0.75, height-height*0.0277);
  text("Velocidad Angular: " + VelocidadAngular +" rad/s", width-width*0.57, height-height*0.0277);
  text("Distancia: ", width-width*0.23, height-height*0.0277);

  if(iDistancia<40) {
    text("        " + iDistancia +" cm", width-width*0.16, height-height*0.0277);
  }

 //Los grados que representan las líneas que cortan los arcos
  textSize(25);
  fill(98,245,60);

  translate((width-width*0.4994)+width/2*cos(radians(30)),(height-height*0.0907)-width/2*sin(radians(30)));
  rotate(-radians(-60));
  text("30°",0,0);
  resetMatrix();

  translate((width-width*0.503)+width/2*cos(radians(60)),(height-height*0.0888)-width/2*sin(radians(60)));
  rotate(-radians(-30));
  text("60°",0,0);
  resetMatrix();

  translate((width-width*0.507)+width/2*cos(radians(90)),(height-height*0.0833)-width/2*sin(radians(90)));
  rotate(radians(0));
  text("90°",0,0);
  resetMatrix();

  translate(width-width*0.513+width/2*cos(radians(120)),(height-height*0.07129)-width/2*sin(radians(120)));
  rotate(radians(-30));
  text("120°",0,0);
  resetMatrix();

  translate((width-width*0.5104)+width/2*cos(radians(150)),(height-height*0.0574)-width/2*sin(radians(150)));
  rotate(radians(-60));
  text("150°",0,0);
  popMatrix(); 
} //fin DibujarTexto
