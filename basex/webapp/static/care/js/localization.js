/*
* This script manages the internationalization of all views
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
  $('.brand').localize();
  $('.nav').localize();
  $('#main-content').localize();
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
  
  //deprecated flag labels
	$('#lng-label-en').removeClass('label label-success');
	$('#lng-label-de').addClass('label label-success');
	$('#lng-label-en-big').removeClass('label label-default');
	$('#lng-label-de-big').addClass('label label-default');
	$('#lang-en-big').removeClass('activeLng');
	$('#lang-de-big').addClass('activeLng');
  
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
  
  //deprecated flag labels
	$('#lng-label-de').removeClass('label label-success');
	$('#lng-label-en').addClass('label label-success');
	$('#lng-label-de-big').removeClass('label label-default');
	$('#lng-label-en-big').addClass('label label-default');
	$('#lang-de-big').removeClass('activeLng');
	$('#lang-en-big').addClass('activeLng');
  
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
  //moment.locale(lng);
  updateContent();
});