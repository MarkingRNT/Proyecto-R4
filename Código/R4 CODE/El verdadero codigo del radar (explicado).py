 from machine import Pin, ADC, PWM, time_pulse_us, I2C  # Se agrega la libreria de la Raspberry pi pico
from imu import MPU6050      # Se agrega la libreria del MPU6050
import utime        # Se agrega la libreria sobre los periodos de tiempo

servo = PWM(Pin(5))  # Activa el pin 5 como el pin PWM del servomotor
servo.freq(50)       # La frecuencia del servo es 50 Hz
adc = ADC(Pin(27))   # Activa el pin 27 como el pin ADC del potenciometro

trig = Pin(3, Pin.OUT)    # Activa el pin 3 como el TRIG del HC-SR04
echo = Pin(2, Pin.IN)     # Activa el pin 2 como el ECHO del HC-SR04

i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=400000)    # Activa el pin 1 como el SCL y el pin 0 como el SDA del MPU6050
imu = MPU6050(i2c)

direccion = 1   # Si la direccion es 1, el servo gira hacia la derecha o izquierda; si es -1, gira hacia el otro lado
angulo = 0     # Hace que el servo empiece en 0°

def sleep_time(value, in_min, in_max, out_min, out_max):
    return ((value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)  #Funcion para el tiempo de cada angulo

def map_angle_to_duty(angle):
    return int((angle / 180) * (6500 - 2500) + 2500)   # Funcion para convertir el angulo del servo en duty

def medir_distancia():  # Funcion para medir la distancia entre el HC-SR04 y el objeto detectado
    trig.low()
    utime.sleep_us(5)  # El sensor manda una señal hacia el objeto
    trig.high()
    utime.sleep_us(10) # Cuando esta señal llega al objeto, este rebota y vuelve al sensor
    trig.low()
    
    duracion = time_pulse_us(echo, Pin.high)  # Determina la duracion entre que la señal sale y vuelve al sensor
    distancia = (duracion / 2) / 29.1         # Se calcula la distancia
    
    if distancia < 5 or distancia > 40:
        raise ValueError('Fuera de rango (5 - 40 cm)') #Si la distancia no esta entre 5 y 40 cm, pone que esta fuera de rango
    
    return distancia

while True:
    pot_value = adc.read_u16()   # Lee el valor del potenciometro (de 0 a 65355)
    tiempo_cada_angulo = sleep_time(pot_value, 0, 65535, 0.001, 0.2)  # Se determina el tiempo que el servo hace cada angulo
    
    if direccion ==1:   # Si la direccion es 1, el servo gira de 0° hasta 180°
        angulo += 1
        if angulo > 180:
            angulo = 180
            direccion = -1    # Cuando el servo llega a los 180°, la direccion cambia y gira de 180° hasta 0°
    
    else:
        angulo -= 1
        if angulo < 0: 
            angulo = 0
            direccion = 1  # Cuando el servo llega a los 0°, la direccion cambia y gira de 0° hasta 180°, generandose un bucle
    
    servo.duty_u16(map_angle_to_duty(angulo))  # Se determina el duty del servomotor
    utime.sleep(tiempo_cada_angulo)
    
    try:
        distancia_redondeada = "{:.2f}".format(medir_distancia())
        distancia_medida = float(distancia_redondeada)  # Se agrega la variable de la distancia entre el objeto y el radar
        velocidad_angular = round(imu.gyro.z,2)    # Se agrega la variable de la velocidad a la que gira el radar
        # Se imprimen los datos que se obtuvieron: El angulo, la distancia y la velocidad angular
        print("Angulo: ", angulo, ". Distancia: ", distancia_medida, "Velocidad de giro en el eje Z: ", velocidad_angular)
    
    except ValueError as e:
        velocidad_angular = round(imu.gyro.z,2)
        # Se imprimen los datos que se obtuvieron: El angulo, la velocidad angular y cuando el objeto esta fuera del rango
        print("Angulo: ", angulo, ", Distancia: ", e, "Velocidad de giro en el eje Z: ", velocidad_angular)
    