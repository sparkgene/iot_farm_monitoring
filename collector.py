#!/usr/bin/python

import sys
import os
import smbus
import decimal
from time import gmtime, strftime
import Adafruit_DHT
import RPi.GPIO as GPIO


class FarmCondition:

    def __init__(self):
        self.humidity = None
        self.temperature = None
        self.lux = None
        self.moisture = None

    def get_DHT11(self):
        try:
            humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, 4)
            if humidity is not None:
                self.humidity = "{0:0.1f}".format(humidity)
            if temperature is not None:
                self.temperature = "{0:0.1f}".format(temperature)
        except:
            pass
        return self.humidity, self.temperature

    def get_GY30(self):
        try:
            bus = smbus.SMBus(1)
            data = bus.read_i2c_block_data(0x23,0x11)
            self.lux = str((data[0] << 8 | data[1]))
        except:
            pass

        return self.lux

    def get_YL69(self):
        # change these as desired - they're the pins connected from the
        # SPI port on the ADC to the Cobbler
        SPICLK = 18
        SPIMISO = 23
        SPIMOSI = 24
        SPICS = 25

        # set up the SPI interface pins
        GPIO.setup(SPIMOSI, GPIO.OUT)
        GPIO.setup(SPIMISO, GPIO.IN)
        GPIO.setup(SPICLK, GPIO.OUT)
        GPIO.setup(SPICS, GPIO.OUT)

        self.moisture = self.readadc(0, SPICLK, SPIMOSI, SPIMISO, SPICS)
        return self.moisture

    def readadc(self, adcnum, clockpin, mosipin, misopin, cspin):
        if ((adcnum > 7) or (adcnum < 0)):
            return -1
        GPIO.output(cspin, True)

        GPIO.output(clockpin, False)  # start clock low
        GPIO.output(cspin, False)   # bring CS low

        commandout = adcnum
        commandout |= 0x18  # start bit + single-ended bit
        commandout <<= 3  # we only need to send 5 bits here
        for i in range(5):
            if (commandout & 0x80):
                GPIO.output(mosipin, True)
            else:
                GPIO.output(mosipin, False)
            commandout <<= 1
            GPIO.output(clockpin, True)
            GPIO.output(clockpin, False)

        adcout = 0
        # read in one empty bit, one null bit and 10 ADC bits
        for i in range(12):
            GPIO.output(clockpin, True)
            GPIO.output(clockpin, False)
            adcout <<= 1
            if (GPIO.input(misopin)):
                adcout |= 0x1

        GPIO.output(cspin, True)

        adcout >>= 1     # first bit is 'null' so drop it
        return adcout

if __name__ == "__main__":
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)
    farm = FarmCondition()
    h, t = farm.get_DHT11()
    l = farm.get_GY30()
    m = farm.get_YL69()

    print("{0},{1},{2},{3},{4}".format(strftime('%Y-%m-%d %H:%M:%S', gmtime()), h, t, l, m))
