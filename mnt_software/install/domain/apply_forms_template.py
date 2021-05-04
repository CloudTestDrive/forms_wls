
        # <FORMS_WLS_STACK>
        readDomain(wls_domain_home)
        v_forms = "true"
        v_reports = "true"
        selectTemplate('Oracle HTTP Server (Collocated)')
        if v_forms == "true":
           selectTemplate('Oracle Forms')
        if v_reports == "true":
           selectTemplate('Oracle Reports Application')
           selectTemplate('Oracle Reports Server')
        loadTemplates()
        # reconfigure the Nodemamanger of AdminServerMachine
        cd('/Machines/AdminServerMachine/NodeManager/AdminServerMachine')
        cmo.setListenAddress(thisHost)
        updateDomain()
        closeDomain()
        # create an instance of reptools1 and rep_server1
        if v_reports == "true":
          createReportsToolsInstance(instanceName='reptools1',machine='AdminServerMachine')
          createReportsServerInstance(instanceName='rep_server1',machine='AdminServerMachine')
        # </FORMS_WLS_STACK>

