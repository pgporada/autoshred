#!/usr/bin/python
# AUTHOR: Phil Porada - philporada@gmail.com

from time import sleep
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("You need to run as sudo")

LED = 19
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED, GPIO.OUT)

GPIO.output(LED, GPIO.HIGH)
sleep(.2)
GPIO.output(LED, GPIO.LOW)

GPIO.cleanup()
