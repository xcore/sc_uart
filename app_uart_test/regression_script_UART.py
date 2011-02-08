#!/usr/bin/python
import os
path = "/workspace/xmos_uart/app_uart_test"

def run_command(log):
	#log.write("CLEANING..\n")
	#log.write(os.popen("xmake clean").read())
	#os.popen("xmake clean").read()
	#log.write("BUILDING..\n")
	#log.write(os.popen("xmake all").read())
	#os.popen("xmake all").read()
	#log.write("TESTING..\n")

	os.system("xmake clean")
	os.system("xmake all")
	
	#log.write("TESTING..\n")
	log.write("\t\t\t\t\t\t")
	executable="bin/XC-1/app_uart_test.xe"
	command="xsim " + executable + " --plugin LoopbackPort.dll \"-xe " + executable + \
	    " -port stdcore[0] XS1_PORT_1A 1 0 " + \
	    " -port stdcore[0] XS1_PORT_1B 1 0\""

	log.write(os.popen(command).read())


import sys
print sys.argv
str1=sys.argv

log = open('log.txt','a')
log.write("********************************************************************")
log.write("\n");
log.write("BAUD-RATE  BITSPERBYTE  PARITY  STOPBITS ")
log.write("\n");
log.write("********************************************************************")
log.write("\n");

if (len(str1) > 1) :
	print'Single Test'
	regression=0;
	if(len(str1) == 9):
		hdr = open('src/UART_test.h','w')
		if (sys.argv[1] == '-baud_rate'):
			bitrate_int = int(sys.argv[2])
			print (bitrate_int + 1)
			hdr.write("#define BIT_RATE ")
			hdr.write(sys.argv[2])
			hdr.write("\n")
		else:
			print'script.py -buad_rate <baud_rate> -bitsperbyte <bitsperbyte> -parity <parity> -stopbit <stopbit>'
		if (sys.argv[3] == '-bitsperbyte'):
			bitsperbyte_int=int(sys.argv[4])
			print (bitsperbyte_int + 1)
			hdr.write("#define BITS_PER_BYTE ")
			hdr.write(sys.argv[4])
			hdr.write("\n")
		else:
			print'script.py -buad_rate <baud_rate> -bitsperbyte <bitsperbyte> -parity <parity> -stopbit <stopbit>'	
		if (sys.argv[5] == '-parity'):
			parity_int=int(sys.argv[6])
			print (parity_int + 1)
			hdr.write("#define SET_PARITY ")
			hdr.write(sys.argv[6])
			hdr.write("\n")
		else:
			print'script.py -buad_rate <baud_rate> -bitsperbyte <bitsperbyte> -parity <parity> -stopbit <stopbit>'	
		if (sys.argv[7] == '-stopbit'):
			stopbit_int=int(sys.argv[8])
			print (stopbit_int + 1)
			hdr.write("#define STOP_BIT ")
			hdr.write(sys.argv[8])
			hdr.write("\n")
		else:
			print'script.py -buad_rate <baud_rate> -bitsperbyte <bitsperbyte> -parity <parity> -stopbit <stopbit>'
		log.write(str(sys.argv[2]))
		log.write("\t\t")
		log.write(str(sys.argv[4]))
		log.write("\t\t")
		log.write(str(sys.argv[6]))
		log.write("\t\t")
		log.write(str(sys.argv[8]))
		#log.write("\n")		
		hdr.close()
		run_command(log)
	else:
		hdr = open('src/UART_test.h','w')
		hdr.write("#define BIT_RATE ")
		hdr.write("96000")
		hdr.write("\n")
		hdr.write("#define BITS_PER_BYTE ")
		hdr.write("8")
		hdr.write("\n")
		hdr.write("#define SET_PARITY ")
		hdr.write("2")
		hdr.write("\n")
		hdr.write("#define STOP_BIT ")
		hdr.write("1")
		hdr.write("\n")
		if(sys.argv[1]=='-runtime_parameter_change'):
			hdr.write("#define RUNTIME_PARAMETER_CHANGE")
			log.write("__________<script.py> -runtime_parameter_change________\n")
			log.write("96000")
			log.write("\t\t")
			log.write("8")
			log.write("\t\t")
			log.write("2")
			log.write("\t\t")
			log.write("1")
			hdr.close()
			run_command(log)
		else:
			if(sys.argv[1]=='-check_buffering'):
				log.write("__________<script.py> -check_buffering________\n")
				log.write("96000")
				log.write("\t\t")
				log.write("8")
				log.write("\t\t")
				log.write("2")
				log.write("\t\t")
				log.write("1")	
				hdr.write("# define CHECK_BUFFERING ")
				hdr.close()
				run_command(log)
			else:
				if(sys.argv[1]=='-test_parity'):
					log.write("__________<script.py> -test_parity________\n")
					log.write("96000")
					log.write("\t\t")
					log.write("8")
					log.write("\t\t")
					log.write("2")
					log.write("\t\t")
					log.write("1")						
					hdr.write("# define TEST_PARITY ")
					hdr.close()
					run_command(log)
				else:
					print'Invalid argument.Argument should be either "runtime_parameter_change" OR "check_buffering" OR "test_parity" '
		
else:
	print'Regrression'
	regression=1;
	print(regression)

if(regression):

	tlist=open("testlist.txt",'r')
	bitrate=tlist.readline()
	while(bitrate != ''):
		hdr = open('src/UART_test.h','w')
  		bitrate_int=int(bitrate)
		#print (bitrate_int + 1)
		hdr.write("#define BIT_RATE ")
		hdr.write(bitrate)
		bitsperbyte=tlist.readline()
		bitsperbyte_int=int(bitsperbyte)
		#print (bitsperbyte_int + 1)
		hdr.write("#define BITS_PER_BYTE ")
		hdr.write(bitsperbyte)
		parity=tlist.readline()
		parity_int=int(parity)
		#print (parity_int + 1)
		hdr.write("#define SET_PARITY ")
		hdr.write(parity)
		stopbit=tlist.readline()
		stopbit_int=int(stopbit)
		#print (stopbit_int + 1)
		hdr.write("#define STOP_BIT ")
		hdr.write(stopbit)
		bitrate=tlist.readline()
		log.write(str(bitrate_int))
		log.write("\t\t")
		log.write(str(bitsperbyte_int))
		log.write("\t\t")
		log.write(str(parity_int))
		log.write("\t\t")
		log.write(str(stopbit_int))
		hdr.close()
		run_command(log)
	
	tlist.close()

log.close()


	