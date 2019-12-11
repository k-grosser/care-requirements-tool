(:~
 : Diese Modul generiert die Start-Seite der Webanwendung.
 : @version 1.2
 : @author Florian Eckey, Katharina Großer
 :)
module namespace page = 'masterthesis/modules/web-page';

import module namespace ui = 'masterthesis/modules/ui-manager';

(:~
 : Diese Funktion erzeugt den HTML-Inhalt der Startseite. Der Inhalt wird in das UI-Template eingebunden.
 : @return Startseite (XHTML)
 :)
declare
  %rest:path("care-webapp")
  updating function page:redirectstart() {
    db:output(<restxq:redirect>/care/en</restxq:redirect>)
};

(:~
 : Diese Funktion erzeugt den HTML-Inhalt der Startseite. Der Inhalt wird in das UI-Template eingebunden.
 : @return Startseite (XHTML)
 :)
declare
  %rest:path("care-webapp/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:care($lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    page:start($lng)
};

(:~
 : Diese Funktion erzeugt den HTML-Inhalt der Startseite. Der Inhalt wird in das UI-Template eingebunden.
 : @return Startseite (XHTML)
 :)
declare
  %rest:path("care/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    ui:page($lng,
      <div class="container">
          <div class="login">
            <div class="login-screen" style="width:81.3%;font-size:1.5em">
              <span data-i18n="home.welcome"></span> <span class="brand" data-i18n="brand"></span> ... 
               
               <div style="font-size:13pt">
               <span data-i18n="home.system"></span>
               
                <a href="{$ui:prefix}/requirements-manager/{$lng}" style="color:green" data-i18n="[html]home.go"></a>
               </div>
               <div style="font-size:13pt">
                <a href="{$ui:prefix}/setup/{$lng}" style="color:green" data-i18n="home.loadndelete"></a>
               </div>
               <div style="font-size:13pt">
                <a href="{$ui:prefix}/inspection/{$lng}" style="color:green" data-i18n="home.docs"></a><br/>
                
                <span data-i18n="[html]home.authors"></span><br/>
                </div>
                 
            </div>
          </div>
      </div>)
};

(:~
 : Diese Funktion stellt den REST-Aufrufe für die initiale Erstellung der Datenbanken dar
 : @return Redirekt auf die Startseite
 :)
declare
  %rest:path("setup/{$lng}")
  updating function page:setup($lng) {
    db:create("care-packages")
    ,db:create("inspection",<Inspections xmlns="inspections"/>,"inspections.xml")
    ,db:create("glossary",<Glossary xmlns="glossary"/>,"glossary.xml")
    ,db:output(<restxq:redirect>/care/{$lng}</restxq:redirect>)
  };

(:~
 : Diese Funktione stellt den REST-Aufrufe für das Löschen der Datenbanken dar
 : @return Redirekt auf die Startseite
 :)
declare
  %rest:path("setup/drop/{$lng}")
  updating function page:setup-drop($lng) {
    db:drop("care-packages")
    ,db:drop("inspectiosn")
    ,db:drop("glossary")
    ,db:output(<restxq:redirect>/care/{$lng}</restxq:redirect>)
  };