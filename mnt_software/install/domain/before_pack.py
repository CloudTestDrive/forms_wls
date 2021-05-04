import os, sys
v_forms="true"
v_reports="false"
v_wls_domain_path=os.environ['WLS_DOMAIN_PATH']
v_server_name=os.environ['SERVER_NAME']
v_machine_name=os.environ['MACHINE_NAME']

def error(infoText):
    printHeader( "ERROR: " + infoText )
    dumpStack() 
    exit  

def printHeader(headerText):
    print ""
    print "============================================================================="
    print headerText
    print "============================================================================="
    print ""

def printInfo(infoText):
    print "Info: "+infoText

printHeader("Add forms custom offline features")
printHeader("readDomain")
try:
    readDomain(v_wls_domain_path)
    printInfo( "readDomain successful")
except:
    error( "readDomain failed" )

printHeader("customize")
try:
  setStartupGroup(v_server_name,'FORMS-MAN-SVR')
  setServerGroups(v_server_name,['FORMS-MAN-SVR'])
  forms_instance = 'forms_'+v_server_name
  create(forms_instance, 'SystemComponent')
  cd('/SystemComponent/'+forms_instance)
  cmo.setComponentType('FORMS')
  # I do not know why but it needs both...
  set('Machine', v_machine_name)
  cmo.setMachine(v_machine_name)
except:
    error( "add forms custom offline features failed" )

printInfo("updateDomain")
try:
    printInfo("... this can take up to 5 minutes")
    activate()
    updateDomain()
    closeDomain()
    printHeader("Extend Domain Forms: End")
except:
   error( "Domain could not be saved" )