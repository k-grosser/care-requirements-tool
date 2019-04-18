//import i18next from 'i18next';

/*
* i18next internationalization framework
* init() to initialize settings and load translations
*/
// use plugins and options as needed, for options, detail see
// http://i18next.com/docs/
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
	      }
      }
    },
	en: {
		translation: {
			navi: {
	        	processmanager: '<i class="glyphicon glyphicon-briefcase"/> Process Manager',
		        reqlist: '<i class="glyphicon glyphicon-list"/> Requirements List',
		        glossary: '<i class="glyphicon glyphicon-book"/> Glossary'
			}
		}
	}
  }
}, function(err, t) {
  
  // initialized and ready to go!
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
  
  updateContent();
  
});

function updateContent() {
  $('.nav').localize();
}

function setLngDE(){
	$('#lng-label-en').removeClass('label label-success');
	$('#lng-label-de').addClass('label label-success');
	$('#lang-en').removeClass('activeLng');
	$('#lang-de').addClass('activeLng');
  
 	$('#lng-label-en-big').removeClass('label label-default');
	$('#lng-label-de-big').addClass('label label-default');
	$('#lang-en-big').removeClass('activeLng');
	$('#lang-de-big').addClass('activeLng');
  
	i18next.changeLanguage('de');
}

function setLngEN(){
	$('#lng-label-de').removeClass('label label-success');
	$('#lng-label-en').addClass('label label-success');
	$('#lang-de').removeClass('activeLng');
	$('#lang-en').addClass('activeLng');
  
	$('#lng-label-de-big').removeClass('label label-default');
	$('#lng-label-en-big').addClass('label label-default');
	$('#lang-de-big').removeClass('activeLng');
	$('#lang-en-big').addClass('activeLng');
  
	i18next.changeLanguage('en');
}

i18next.on('languageChanged', () => {
  updateContent();
});