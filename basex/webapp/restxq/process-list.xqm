(:~
 : Diese Modul generiert die Ansicht für den Prozess-Manager.
 : @version 1.0
 : @author Florian Eckey
 :)
module namespace page = 'masterthesis/modules/web-page/requirements-manager';

import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace util="masterthesis/modules/utilities";
import module namespace cm ="masterthesis/modules/care-manager";
import module namespace diff="masterthesis/modules/care/model-differences";
import module namespace consistencymanager = 'masterthesis/modules/consistency-manager';

declare namespace c="care";

(:~
 : Diese Funktion erzeugt den HTML-Inhalt des Prozess-Managers. Der Inhalt wird in das UI-Template eingebunden.
 : @return Prozess-Manager (XHTML)
 :)
declare
  %rest:path("requirements-manager")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start()
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    ui:page(
      <div class="container-fluid">
        <div class="col-md-12">
          <h5 data-i18n="processlist.processmanager"></h5>        
        </div>
        <div class="col-md-8">
            {if(cm:get()) then 
               let $pkg-ids := distinct-values(for $path in db:list-details($cm:db-name) return substring-before($path,"/"))
               for $pkg-id in $pkg-ids
               let $packages := cm:get($pkg-id)
               let $latest-package := util:latest-element($packages)
               return page:package($latest-package)
             else <div class="text-center" style="margin-top:20px;"><b data-i18n="processlist.noprocess"></b></div>}
        </div>
        <div class="col-md-4">
            {page:upload-form()}
        </div>
      </div>
    )
};

(:~
 : Diese Funktion generiert die Ansischt eines Paketes im Prozess-Manager
 : @param $package CARE Paket / Prozess
 : @return Panel des Paketes (XHTML)
 :)
declare function page:package($package as element(c:Package)*) as element(div) {
   <div class="collapse-panel processw-collapse-panel">
    <div class="header" data-toggle="collapse" href="#collapse{$package/@Id}{$package/@VersionId}" aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt>{$package/@Name/string()}</dt>
      </dl>
    </div>
    <div class="collapse in process-panel" id="collapse{$package/@Id}{$package/@VersionId}">
      <div>
        <dl>
          <dt data-i18n="processlist.versions"></dt>
          <table class="table noindent" style="margin-bottom:10px">
            {for $pkg in cm:get($package/@Id) order by xs:dateTime($pkg/@Timestamp) descending return page:package-panel($package, $pkg)}
          </table>
          <div><a class="btn btn-cm bpm-btn" href="{$ui:prefix}/requirements-manager/delete-pkgs/{$package/@Id}" data-i18n="[title]processlist.deletealltitle;processlist.deleteall"></a></div>
        </dl>
      </div>
    </div>
  </div>
};

(:~
 : Diese Funktion generiert eine Tabellen-Zeile für die Ansischt der Version eines Prozesses im Prozess-Manager
 : @param $package Liste aller Versionen eines Paketes
 : @param $pkg Betrachtetes Paket
 : @return Tabellen-Zeile des Prozesses (XHTML)
 :)
declare function page:package-panel($package, $pkg) {
  let $compare-package := cm:package-before($pkg)
  let $inconsistencies := if($compare-package) then diff:Activities($pkg,$compare-package) else () 
  let $inconsistencies := for $act in $pkg/c:Activity return 
                            consistencymanager:check-consistency($act, $inconsistencies) return
  <tr style="{if($package/@Timestamp=$pkg/@Timestamp) then 'font-weight:bold' else ()}">
    <td>{if($inconsistencies) then <i data-i18n="[title]processlist.inconsistencies" class="glyphicon glyphicon-warning-sign text-warning" style="cursor:default;"/> else ()}</td>
    <td class="col-md-6">
       
<span class="de-only">{format-dateTime(xs:dateTime($pkg/@Timestamp), "[D]. [MNn] [Y], [H00]:[m00]:[s01]", "de", (), ())}{if($package/@Timestamp=$pkg/@Timestamp) then ' (neuste)' else ()}</span>
<span class="en-only" style="display:none;">{format-dateTime(xs:dateTime($pkg/@Timestamp), "[MNn] [D1o]  [Y], [H00]:[m00]:[s01]", "en", (), ())}{if($package/@Timestamp=$pkg/@Timestamp) then ' (newest)' else ()}</span>
      
    </td>
    <td class="col-md-2">
      <a class="re-link" href="{$ui:prefix}/requirements-manager/package/{$pkg/@Id}/{$pkg/@VersionId}" data-i18n="[title]processlist.elicitationtitle;processlist.elicitation"></a>
    </td>
    <td class="col-md-2">
      <a class="re-link" href="{$ui:prefix}/requirements-manager/list/{$package/@Id}/{$pkg/@VersionId}" data-i18n="[title]processlist.reqlisttitle;processlist.reqlist"></a>
    </td>
    <td class="col-md-3">
      <a class="re-link" href="{$ui:prefix}/requirements-manager/download-requirements/{$package/@Id}/{$pkg/@VersionId}" data-i18n="[title]processlist.downloadtitle;processlist.download"></a>
    </td>
    <td class="col-md-1">
      <a class="re-link" href="{$ui:prefix}/requirements-manager/delete-pkg/{$package/@Id}/{$pkg/@VersionId}" data-i18n="[title]processlist.deleteversiontitle"><span class="fui-cross"></span></a>
    </td>
 </tr>
};

(:~
 : Diese Funktion generiert das Panel zum Hochladen von Prozessen.
 : @return Upload-Panel (XHTML)
 :)
declare function page:upload-form() {
  <div class="collapse-panel actions-panel-header">
    <div class="header" data-toggle="collapse" aria-expanded="false" aria-controls="collapseExample" style="cursor:default">
      <dl class="palette">
        <dt data-i18n="processlist.upload"></dt>
      </dl>
    </div>
    <div class="collapse in" id="collapseActions">
      <div class="panel-box upload-panel">
      <div style="margin-bottom:10px;" data-i18n="processlist.uploadinfo"></div>
        <form action="{$ui:prefix}/data/upload" method="POST" enctype="multipart/form-data">
          <div align="center">
            <input type="file" name="files" multiple="multiple"/>
            <div data-i18n="processlist.uploadlng" style="font-size:0.8em;"></div>
            <input class="btn btn-sm upload-btn" data-i18n="[value]processlist.uploadbtn" type="submit"/>
          </div>
         </form>
         
       </div>
    </div>
  </div>
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Löschen eines Paketes in der Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Löschen übernimmt.
 : @param $pkg-id Die ID des Paketes, welches gelöscht werden soll
 : @return Redirekt auf den Prozess-Manager
 :)
declare %restxq:path("requirements-manager/delete-pkgs/{$pkg-id}")
        updating function page:delete-pkgs($pkg-id) {
            cm:delete-package($pkg-id)
            ,db:output(<restxq:redirect>/requirements-manager</restxq:redirect>)
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Löschen der Version eines Prozesses in der Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Löschen übernimmt.
 : @param $pkg-id Die ID des Paketes, welches gelöscht werden soll
 : @param $pkg-version Versions-ID des Prozesses, welcher gelöscht wird
 : @return Redirekt auf den Prozess-Manager
 :)
declare %restxq:path("requirements-manager/delete-pkg/{$pkg-id}/{$pkg-version}")
        updating function page:delete-pkgs($pkg-id, $pkg-version) {
            cm:delete-package($pkg-id,$pkg-version)
            ,db:output(<restxq:redirect>/requirements-manager</restxq:redirect>)
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Löschen der Version eines Prozesses in der Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Löschen übernimmt.
 : @param $pkg-id Die ID des Paketes, welches gelöscht werden soll
 : @param $pkg-version Versions-ID des Prozesses, welcher gelöscht wird
 : @return Redirekt auf den Prozess-Manager
 :)
declare %restxq:path("requirements-manager/download-requirements/{$pkg-id}/{$pkg-version}")
        %output:method("raw")
        function page:download-requirements($pkg-id, $pkg-version) {
           let $package := cm:get($pkg-id,$pkg-version)
           let $requirements := <Requirements xmlns="care">{$package/c:Activity/c:Requirements/c:Requirement}</Requirements> return
            (<restxq:response>
              <http:response status="200">
                <http:header name="Content-Disposition" value="attachment;filename=Export_{$package/@Name/string()}_V{$package/@Timestamp/string()}.xml"></http:header>
              </http:response>
            </restxq:response>
            ,serialize($requirements)
            ,<output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
              <output:omit-xml-declaration value="yes"/><output:method value="xml"/>
            </output:serialization-parameters>)
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Einfügen von Prozessen in die Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Einfügen übernimmt.
 : @param $files Die Dateien, welche hochgeladen werden
 : @return Redirekt auf den Prozess-Manager
 :)
declare
  %rest:POST
  %rest:path("/data/upload")
  %rest:form-param("files", "{$files}")
  updating function page:upload($files) {
    for $name in map:keys($files)
    let $content := $files($name)
    let $ext := substring-after($name,".") return 
    switch($ext)
      case "bpm" return cm:import-bizagi($content)   
      case "xpdl" return cm:import-xpdl($content)
      default return ()
    ,db:output(<restxq:redirect>/requirements-manager</restxq:redirect>)
};