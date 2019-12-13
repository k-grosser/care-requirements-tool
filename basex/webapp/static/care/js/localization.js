/*
* This script manages the internationalization of all views
* @version: 1.0
* @author: Katharina Großer
*/

/*
* i18next internationalization framework
* init() to initialize settings and load translations
* use plugins and options as needed
* @see http://i18next.com/docs/
*/
i18next.init({
  lng: 'de',
  debug: true,
  resources: {
    de: {
		translation: {
			navi: {
	        	processmanager: '<i class="glyphicon glyphicon-briefcase"/> Prozess-Manager',
		        reqlist: '<i class="glyphicon glyphicon-list"/> Anforderungsliste',
		        glossary: '<i class="glyphicon glyphicon-book"/> Glossar'
	      },
      home: {
          welcome: 'Willkommen bei',
          system: 'System zur Unterstützung bei der Konsistenzhaltung von Prozessmodellierung und textueller Anforderungsdokumentation.',
          go: 'Los geht&#39;s!',
          loadndelete: '>> Datenbank löschen & neu laden',
          docs: '>> Code Dokumentation',
          authors: 'Entwickelt von <a style="color:green" href="https://www.xing.com/profile/Florian_Eckey" target="_blank">Florian&#160;Eckey</a> &#38; <a style="color:green" href="https://www.uni-koblenz-landau.de/de/koblenz/fb4/ist/rgse/staff/katharina-grosser" target="_blank">Katharina&#160;Großer</a>'
      },
      processlist: {
        processmanager: 'Prozess-Manager',
        noprocess: 'Keine Prozesse für die Anforderungserhebung geladen',
        versions: 'Versionen',
        deletealltitle: 'Alle Versionen dieses Prozesses und die zugehörigen Anforderungen löschen',
        deleteall: 'Prozess und Anforderungen löschen',
        inconsistencies: 'Inkonsistenzen gefunden',
        elicitationtitle: 'zur Liste der Aktivitäten dieses Prozesses',
        elicitation: 'Anforderungserhebung',
        reqlisttitle: 'zur Liste aller Anforderungen dieses Prozesses',
        reqlist: 'Anforderungsliste',
        download: 'Anforderungen herunterladen',
        downloadtitle: 'zum Herunterladen der Anforderungsliste zu diesem Prozess',
        deleteversiontitle: 'Version löschen',
        upload: 'BPMN hochladen',
        uploadinfo: 'Hier können Sie BPMN Prozessmodelle hochladen, zu denen Sie Anforderungen erheben wollen:',
        uploadbtn: 'hochladen',
        uploadlng: 'Bitte achten Sie darauf das die Sprache des Modells (DE oder EN) der eingestellten Sprache des $t(brand) Tools entspricht.'
      },
      docu: {
        graphtitle: 'GraphML der Modulstruktur generieren',
        graph: 'Modulstruktur generieren',
        modul: 'Modul',
        uri: 'URI',
        func: 'Funktionen',
        path: 'Pfad',
        doc: 'Dokumentation',
        desc: 'Beschreibung',
        nodesc: 'Keine Beschreibung vorhanden.',
        version: 'Version',
        noversion: 'Keine Version eingetragen.',
        author: 'Autor',
        noauthor: 'Kein Autor eingetragen.',
        imports: 'Importierte Module:',
        noimports: 'Module importiert keine anderen Module',
        usage: 'Wird verwendet in:',
        nousage: 'Modul wird nicht verwendet.',
        ns: 'Namespaces',
        prefix: 'Präfix',
        nons: 'Keine Namespaces deklariert.',
        variables: 'Variablen',
        novariables: 'Keine Variablen enthalten.',
        para: 'Parameter',
        nofunc: 'Keine Funktionen enthalten.',
        nomodul: 'Kein Modul gefunden.',
        back: 'Zurück zur Modulübersicht',
        sig: 'Signatur',
        nosig: 'Keine Signatur vorhanden.',
        ret: 'Rückgabe',
        noret: 'Kein Rückgabewert dokumentiert.',
        anno: 'Annotationen',
        name: 'Name',
        type: 'Typ',
        val: 'Wert'
      },
      activitylist: {
        activitylist: 'Aktivitätenliste',
        activity: 'Aktivität',
        reqs: 'Erhobene Anforderungen',
        noactivity: 'Keine Aktivitäten gefunden',
        changes: 'Änderung gefunden',
        deleted: 'Aktivität entfernt',
        add: 'Aktivität hinzugefügt'
      },
      elicit: {
        backtolist: 'Zur Aktivitätenliste',
        reqlisttt: 'Hier befindet sich die Liste aller Anforderungen, die aus der aktuell betrachteten Aktivität abgeleitet wurden. Treten Änderungen zur Vorversion auf, hovern Sie bitte über die orange-farbigen Texte, um die konkrete Änderung zu erfahren.',
        template: 'Hier können Anforderungen mit Hilfer der SOPHIST MASTER Satzschablone eingegeben werden. Als default wird der FunktionsMASTER angezeigt. Für den BedingungsMASTER drücken Sie Strg + B. Nochmaliges drücken von Strg + B wecheslt die Arten des BedingungsMASTERs. Für den detaillierten FunktionsMASTER drücken Sie Strg + Leer. Die Vorschläge für die Satzbausteine leiten sich aus den Kontextinformationen ab.',
        consistency: 'Die Liste der Inkonsistenzen zeigt alle Validierungsfehler und Unterschiede zur Vorgänger-Version an. Diese müssen behoben werden. Ist der Balken grün, sind die Anforderungen und das BPMN Prozessmodell konsistent.',
        info: 'Hier befinden sich alle für die Erhebung von Anforderungen relevanten Kontextinformationen der aktuell betrachteten Aktivität.',
        context: 'Kontextinformationen der Aktivität',
        name: 'Name',
        activitytype: 'Activität-Typ',
        role: 'Rolle',
        doc: 'Datenobjekte',
        pre: 'Vorgänger',
        sys: 'Datenspeicher',
        system: 'System'
      },
      diff: {
        act: 'Die Aktivität ',
        del: ' wurde entfernt.',
        add: ' wurde hinzugefügt.',
        elicit: ' Erheben Sie neue Anforderungen!',
        actname: 'Der Name der Aktivität',
        changefrom: ' hat sich von ',
        to: ' nach ',
        changeto: ' geändert.',
        resp: 'Die Zuständigkeit der Aktivität',
        acttype: 'Der Typ der Aktivität',
        doc: 'Das Datenobjekt ',
        ds: 'Der Datenspeicher',
        pre: 'Der Vorgänger ',
        changeinto: ' hat sich in ',
        docstate: 'Der Zustand des Datenobjekts ',
        prename: 'Der Name des Vorgängers ',
        pretype: 'Der Typ des Vorgängers ',
        preresp: 'Die Zuständigkeit (Rolle) des Vorgängers ',
        pretrans: 'Der Wert der Transition des Vorgängers ',
        perf: 'Der beteiligte Akteur (Poolname) der Aktivität'
      },
      reqlist: {
        noreqs: 'noch keine Anforderungen erhoben',
        edit: 'Anforderung bearbeiten',
        del: 'Anforderung löschen'
      },
	  bpmn: {
		  usertask: 'Benutzeraktivität',
		  servicetask: 'Systemaktivität',
		  receivetask: 'Empfangende Aktivität',
		  sendtask: 'Sendende Aktivität',
		  scripttask: 'Skript Aktivität',
		  manualtask: 'Manuelle Aktivität',
		  businessruletask: 'Aktivität mit Geschäftsentscheidung',
		  untypedtask: 'Aktivität (ohne Typ)'
	  },
       brand: 'CARE' //BeeP&#0178;R
      }
    },
	en: {
		translation: {
			navi: {
	        	processmanager: '<i class="glyphicon glyphicon-briefcase"/> Process Manager',
		        reqlist: '<i class="glyphicon glyphicon-list"/> Requirements List',
		        glossary: '<i class="glyphicon glyphicon-book"/> Glossary'
			},
      home: {
          welcome: 'Welcome to',
          system: 'a system to support the consistency of business process modelling and natural language requirements.',
          go: 'Go!',
          loadndelete: '>> Delete database & reload',
          docs: '>> Code documentation',
          authors: 'Developed by <a style="color:green" href="https://www.xing.com/profile/Florian_Eckey" target="_blank">Florian&#160;Eckey</a> &#38; <a style="color:green" href="https://www.uni-koblenz-landau.de/de/koblenz/fb4/ist/rgse/staff/katharina-grosser" target="_blank">Katharina&#160;Großer</a>'
      },
      processlist: {
        processmanager: 'Process Manager',
        noprocess: 'No process loaded for elicitation',
        versions: 'Versions',
        deletealltitle: 'Delete all versions of this process and all corresponding requirements',
        deleteall: 'Delete Process and Requirements',
        inconsistencies: 'Inconsistencies found',
        elicitaiontitle: 'to the list of this processes activities',
        elicitation: 'Requirements Elicitation',
        reqlisttitle: 'to the list of all requirements of this process',
        reqlist: 'Requirements List',
        download: 'Download Requirements',
        downloadtitle: 'to the download of all requirements of this process',
        deleteversiontitle: 'delete version',
        upload: 'Upload BPMN',
        uploadinfo: 'Here you can upload BPMN process models to elicit requirements from:',
        uploadbtn: 'upload',
        uploadlng: 'Please make sure the language of the model (DE or EN) matches the selected language of $t(brand).'
      },
      docu: {
        graphtitle: 'Generate GraphML of module structure',
        graph: 'Generate Module Structure',
        modul: 'Module',
        uri: 'URI',
        func: 'Functions',
        path: 'Path',
        doc: 'Documentation',
        desc: 'Description',
        nodesc: 'No description available.',
        version: 'Version',
        noversion: 'No version available.',
        author: 'Author',
        noauthor: 'No author available.',
        imports: 'Module Imports:',
        noimports: 'No imports of other modules.',
        usage: 'Used in:',
        nousage: 'Not used in other modules.',
        ns: 'Namespaces',
        prefix: 'Prefix',
        nons: 'No namespace declared.',
        variables: 'Variables',
        novariables: 'No variables defined.',
        para: 'Parameter',
        nofunc: 'No functions defined.',
        nomodul: 'No module found.',
        back: 'Back to Module Overview',
        sig: 'Signature',
        nosig: 'No signature available.',
        ret: 'Return',
        noret: 'No return value documented',
        anno: 'Annotations',
        name: 'Name',
        type: 'Type',
        val: 'Value'
      },
      activitylist: {
        activitylist: 'List of Activities',
        activity: 'Activity',
        reqs: 'Requirements Elicited',
        noactivity: 'No activities found',
        changes: 'Changes detected',
        deleted: 'Activity deleted',
        add: 'Activity added'
      },
      elicit: {
        backtolist: 'Back to Activity List',
        reqlisttt: 'This is the list of all requirements elicited from the currently selected activity. If changes to the previous version are detected, you can get information about the nature of the change by hovering over the text parts higlighted in orange.',
        template: '',
        consistency: '',
        info: 'Here you find all neccessary context information to elicit requirements from the currently selected activity.',
        context: 'Activity´s Context Information',
        name: 'Name',
        activitytype: 'Activity Type',
        role: 'Role',
        doc: 'Data Objects',
        pre: 'Predecessor',
        sys: 'Data Stores',
        system: 'System'
      },
      diff: {
        act: 'The activity ',
        del: ' has been deleted.',
        add: ' has been added.',
        elicit: ' Elicit new requirements!',
        actname: 'The activity´s name',
        changefrom: ' changed from',
        to: ' to ',
        changeto: '.',
        resp: 'The activity´s performer',
        acttype: 'The activity´s type',
        doc: 'The data object ',
        ds: 'The data store ',
        pre: 'The predecessor ',
        changeinto: ' has changed to ',
        docstate: 'The data object´s state ',
        prename: 'The predecessor´s name ',
        pretype: 'The type of the predecessor ',
        preresp: 'The performer of the predecessor ',
        pretrans: 'The transition value of the predecessor ',
        perf: 'The activity´s performer (pool name)'
      },
      reqlist: {
        noreqs: 'no requirements elicited, yet',
        edit: 'edit requirement',
        del: 'delete requirement'
      },
	  bpmn: {
		  usertask: 'User Task',
		  servicetask: 'Service Task',
		  receivetask: 'Receiving Task',
		  sendtask: 'Sending Task',
		  scripttask: 'Script Task',
		  manualtask: 'Manual Task',
		  businessruletask: 'Business Rule Task',
		  untypedtask: '(untyped) Activity'
	  },
      brand: 'CARE' //BeeP&#0178;R
		}
	}
  }
}, function(err, t) {
  // initialized and ready to go!
  //jQuery plugin
  jqueryI18next.init(i18next, $, {
    tName: 't', // --> appends $.t = i18next.t
    i18nName: 'i18n', // --> appends $.i18n = i18next
    handleName: 'localize', // --> appends $(selector).localize(opts);
    selectorAttr: 'data-i18n', // selector for translating elements
    targetAttr: 'i18n-target', // data-() attribute to grab target element to translate (if different than itself)
    optionsAttr: 'i18n-options', // data-() attribute that contains options, will load/set if useOptionsAttr = true
    useOptionsAttr: false, // see optionsAttr
    parseDefaultValueFromContent: true // parses default values from content ele.val or ele.text
  });
   //initial localization
   updateContent();
});

/*
* Updates view content with localization
*/
function updateContent() {
  //localize
  $('.brand').localize();
  $('.nav').localize();
  $('#main-content').localize();
  
  //recalculate tooltips
  $('[data-toggle="tooltip"]').tooltip('destroy');
  $('[data-toggle="tooltip"]').tooltip(); 
}

/*
* Manages language dependend GUI elements and triggers localization for German 
*/
function setLngDE(){
  //language menue
	$('#lang-en').removeClass('activeLng');
	$('#lang-de').addClass('activeLng');
  $('#lang-en').addClass('care-link');
  $('#lang-de').removeClass('care-link');
  
  //language specific GUI elements
  $('.en-only').hide();
  $('.de-only').show();
  
  //change language for localization (triggers update)
	i18next.changeLanguage('de');
}

/*
*  Manages language dependend GUI elements and triggers localization for English
*/
function setLngEN(){
  //language menue
	$('#lang-de').removeClass('activeLng');
	$('#lang-en').addClass('activeLng');
  $('#lang-de').addClass('care-link');
  $('#lang-en').removeClass('care-link')
  
  //language specific GUI elements
  $('.en-only').show();
  $('.de-only').hide();
  
  //change language for localization (triggers update)
	i18next.changeLanguage('en');
}

/*
* Listener for language change events, triggers update
*/
i18next.on('languageChanged', () => {
  updateContent();
});