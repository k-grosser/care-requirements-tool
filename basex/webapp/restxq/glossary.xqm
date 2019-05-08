(:~
 : Diese Modul generiert die Ansicht für das Glossar. 
 : @author Florian Eckey, Katharina Großer
 : @version 1.1
 :)
module namespace page = 'masterthesis/modules/care/glossary-view';

import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace gl ="masterthesis/modules/care/glossary";

declare namespace g="glossary";

(:~
 : Diese Funktion erzeugt den HTML-Inhalt des Glossars Assstenzansicht. Der Inhalt wird in das UI-Template eingebunden.
 : @return Glossar-Ansicht (XHTML)
 :)
declare %restxq:path("glossary/{$lng}")
        %restxq:GET
        %output:method("html")
        %output:version("5.0")
  function page:glossary($lng) {
    ui:page($lng, <div class="container-fluid">
              <div class="col-md-12">
                <h5>Glossar</h5>        
              </div>
              <div class="col-md-8">       
                  {page:view-elements($gl:db/g:Entry)}
              </div>
              <div class="col-md-4"> 
                 {page:panel()}
                 {page:insert-form()}
              </div>
            </div>)
};

(:~
 : Diese Funktion generiert das Panel, in dem Aktionen des Glossars ausgeführt werden können. 
 : @return Aktionen-Panel (XHTML)
 :)
declare function page:panel() {
  <div class="collapse-panel actions-panel-header">
    <div class="header" data-toggle="collapse" href="#collapseActions" aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt>Aktionen</dt>
      </dl>
    </div>
    <div class="collapse in" id="collapseActions">
      <div class="panel-box">
        <a href="{$ui:prefix}/glossary/delete" class="list-group-item no-border">Glossar löschen<span class="glyphicon glyphicon-trash pull-right"/></a>
      </div>
    </div>
  </div>
};

(:~
 : Diese Funktion generiert die Tabelle, in der sich die Glossar-Einträge befinden.
 : @param $subds Liste der anzuzeigenden Glossar-Einträge
 : @return Tabelle der Glossar-Einträge (XHTML)
 :)
declare function page:view-elements($subds) {
  <div id="myTabContent">            
    {if(count($subds)>0) then <table class="table table-hover noindent">
      <thead>
        <tr style="cursor:default">
          <th style="width:20%">Fachbegriff</th>
          <th style="width:70%">Erklärung</th>
          <th></th>
         </tr>
      </thead>
      <tbody>
      {for $ts in $subds order by $ts/@Timestamp descending return page:glossary-list-item($ts)}
       </tbody>
    </table> 
    else 
      <div class="text-center" style="margin-top:20px;"><b>Keine Einträge im Glossar geladen</b></div>}
  </div>
};

(:~
 : Diese Funktion generiert das ein Zeile in der Tabelle der Glossar-Einträge.
 : @param $item Glossar-Eintrag, zu dem die Zeile generiert wird
 : @return Zeile im Glossar (XHTML)
 :)
declare function page:glossary-list-item($item) {
    <tr id="id{$item/@Id}">
      <td>{$item/g:Key/string()}</td>
      <td>{$item/g:Value/string()}</td>
      <td><a href="{$ui:prefix}/glossary/delete/{$item/@Id}" class="glyphicon glyphicon-remove pull-right"/></td>
    </tr> 
};

(:~
 : Diese Funktion generiert das Panel, in dem ein neuer Glossar-Eintrag erfasst werden kann.
 : @return Panel zum Hinzufügen von Glossar-Einträgen (XHTML)
 :)
declare function page:insert-form() {
  <div id="insert-form" class="collapse-panel actions-panel-header">
    <div class="header" data-toggle="collapse" href="#collapseInput" aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt>Fachbegriff eintragen</dt>
      </dl>
    </div>
    <div class="collapse in" id="collapseInput">
      <div class="panel-box">
        <form class="form" action="{$ui:prefix}/glossary/insert" method="POST">
          <div class="input-group">
          <span class="input-group-btn">
            <input type="text" id="key" name="key" placeholder="Fachbegriff" tabindex="1" class="form-control" style="width:100%"/>
            
            <textarea placeholder="Erklärung" id="value" name="value" tabindex="2" class="form-control" style="height:200px"/>
            </span>
            </div>
              <button class="btn btn-default" tabindex="3" style="width:100%"><span class="glyphicon glyphicon-ok"/></button>
          
        </form>
      </div>
    </div>
  </div>
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Einfügen eines neuen Glossar-Eintrags in die Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Einfügen übernimmt.
 : @param $key Die ID des Paketes, zu der die Aktivitätenliste angezeigt wird
 : @param $value Versions-ID des Paketes, zu der die Aktivitätenliste angezeigt wird
 : @param $category (depricated) Das Eintragen einer Kategorie wird aktuell nicht von dem Formular unterstützt
 : @return Redirekt auf die Glossar-Ansicht
 :)
declare %restxq:path("glossary/insert")
        %restxq:POST
        %restxq:form-param("key","{$key}","")
        %restxq:form-param("value","{$value}","")
        %restxq:form-param("category","{$category}","PROCESS")
        %output:method("html")
        updating function page:insert($key,$value,$category) {
             gl:save(gl:new-entry($key,$value,$category)),db:output(<restxq:redirect>/glossary</restxq:redirect>)
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Löschen eines Glossar-Eintrags aus der Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Löschen übernimmt.
 : @param $id ID des Glossar-Eintrags
 : @return Redirekt auf die Glossar-Ansicht
 :)
declare %restxq:path("glossary/delete/{$id}")
        updating function page:delete-id($id) {
           gl:delete($id),db:output(<restxq:redirect>/glossary</restxq:redirect>)
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Löschen des gesamten Glossars dar. Sie ruft eine Funktion im REPO auf, welche das Löschen übernimmt.
 : @return Redirekt auf die Glossar-Ansicht
 :)
declare %restxq:path("glossary/delete")
        updating function page:delete() {
           gl:delete()
           ,db:output(<restxq:redirect>/glossary</restxq:redirect>)
};