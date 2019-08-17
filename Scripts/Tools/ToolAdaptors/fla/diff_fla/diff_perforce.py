import sys
import os
import os.path
import subprocess
import _winreg
import time


def binary_compare(a, b):
	sub = subprocess.Popen(["FC", "/B", a, b], stdout=subprocess.PIPE)
	sub.communicate()
	return sub.returncode != 1

def getRegistryKeyValue(rootKey, path, propertyName):
	value = None
	try:
		registry_key = _winreg.OpenKey(_winreg.HKEY_LOCAL_MACHINE, path)
		value, index = _winreg.QueryValueEx(registry_key, propertyName)
	except:
		pass
	return value

def deleteIfExists(path):
	if os.path.exists(path):
		os.remove(path)

def compareFlaFiles(a, b):
	if binary_compare(a, b):
		showError("Files are identical")
		return

	flash_path = getRegistryKeyValue(_winreg.HKEY_LOCAL_MACHINE, "SOFTWARE\\Adobe\\Flash\\9.0", "ApplicationPath")
	if (flash_path == None):
		showError("Adobe Photoshop CS5 not found!")
		return

	flash_path = os.path.join(flash_path, "flash.exe")

	# clearing access token (for communication between this script and jsfl)
	dir_path =  os.path.split(sys.argv[0])[0]
	access_token_path = os.path.join(dir_path, "_accessToken")
	deleteIfExists( access_token_path )

	# generating JSFL
	jsfl_path = os.path.join(dir_path, "_FlaToXML.jsfl")
	with open( os.path.join(dir_path, "FlaToXML.jsfl") ) as source:
		with open( jsfl_path, 'w' ) as destination:
			# replacing file content
			for line in source:
				destination.write(line)
			destination.write( "flaToXML(\"{0}\");\n".format(escapeSlashes(a) ) )
			destination.write( "flaToXML(\"{0}\");\n".format(escapeSlashes(b) ) )
			destination.write( "createToken(\"{0}\");\n".format(escapeSlashes(access_token_path)) )
	
	print "running .jsfl", access_token_path
	sub = subprocess.Popen([flash_path, jsfl_path], stdout=subprocess.PIPE)

	safety_counter = 0
	jsfl_success = False
	dt = 0.1
	max_wait_time = 15
	while safety_counter < max_wait_time and not jsfl_success:
		jsfl_success = os.path.exists(access_token_path)
		safety_counter = safety_counter + dt
		time.sleep(dt)

	print ".jsfl finished"

	#cleaning up
	deleteIfExists( jsfl_path )
	deleteIfExists( access_token_path )

	if jsfl_success:
		xmlA = os.path.splitext(a)[0] + ".xml"
		xmlB = os.path.splitext(b)[0] + ".xml"
		subprocess.Popen(["p4merge", xmlA, xmlB], stdout=subprocess.PIPE)
	else:
		showError("jsfl failed to finish in {0} seconds.".format(max_wait_time) )

def escapeSlashes(s):
	return s.replace("\\", "\\\\")

def showError(message):
	print "Failed to compare .fla files: "+message
	print "Press enter to continue"
	raw_input()

assert len(sys.argv) == 3
compareFlaFiles(sys.argv[1], sys.argv[2])
