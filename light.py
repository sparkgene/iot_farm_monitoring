#!/usr/bin/python
import smbus
import decimal

bus = smbus.SMBus(1)
luxRead = bus.read_i2c_block_data(0x23,0x11)
#lux = str((luxRead[0] << 8 | luxRead[1]))
lux = str(luxRead[1] + (256 * luxRead[0]))
lux = str(decimal.Decimal(lux).quantize(decimal.Decimal('.01'), rounding=decimal.ROUND_UP))

print("Lux: "+lux)

